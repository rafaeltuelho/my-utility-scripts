#!/bin/sh

if [ `id -u` != 0 ]; then
	echo "O instalador precisa de privilégios de root"
	exit 1
fi

JBOSS_URL="http://172.29.0.135/pkg/jboss/env-java-linux-jbossas.tar.gz"
JBOSS_FILENAME="/tmp/env-java-linux-jbossas.tar.gz"
SCRIPT_KERNEL_URL="http://172.29.0.135/pkg/jboss/configura_kernel.sh"
SCRIPT_KERNEL="configura_kernel.sh"

# USAGE: perguntar <PERGUNTA> <VALOR PADRAO> <TOKEN PARA SUBSTITUICAO> <ARQUIVO DE SUBSTITUICAO>
function fazer_substituicao {
	echo -n "$1 [$2]: "
	read RESPOSTA

	if [ "x$RESPOSTA" == "x" ]; then
		RESPOSTA="$2"
	fi

	sed -i "s|@$3@|$RESPOSTA|g" "$4"
}

# baixa e executa o script de configuracao do kernel redhat.
wget -N $SCRIPT_KERNEL_URL /root

echo -n "Deseja executar o script de tuning do kernel para o JBossAS (sim/nao)?"
read RESPOSTA

if [ "$RESPOSTA" == "sim" ]; then
   /bin/bash /root/$SCRIPT_KERNEL
fi

if [ -e "/java" ]; then

	echo -n "Diretório /java já existe. Deseja remover e reinstalar (sim/nao)? "
	read RESPOSTA
	if [ "$RESPOSTA" == "sim" ]; then
        	if [ -e "$JBOSS_FILENAME" ]; then
			echo -n "$JBOSS_FILENAME jah existe. Deseja refazer o download (sim/nao)?"
			read RESPOSTA
			
			if [ "$RESPOSTA" == "sim" ]; then
				rm -f $JBOSS_FILENAME
				wget -N $JBOSS_URL -O "$JBOSS_FILENAME"
			fi
                fi

		rm -rf "/java"
                rm -f /etc/init.d/jon-agent
                rm -f /etc/init.d/jboss
                rm -f /var/log/jboss

		tar zxvf "$JBOSS_FILENAME" -C "/"
	fi
else
	wget -N $JBOSS_URL -O "$JBOSS_FILENAME"
	rm -rf "/java"
        rm -f /etc/init.d/jon-agent
        rm -f /etc/init.d/jboss
        rm -f /var/log/jboss

	tar zxvf "$JBOSS_FILENAME" -C "/"
fi

echo "Selecione a versão Java:"
select OPT in `ls /java/jvms`; do

	if [ ! -e /java/jdk ]; then
	   ln -s "/java/jvms/$OPT" "/java/jdk"
	fi

	break
done


echo "Selecione a versão JBoss a ser instalada:"
select OPT in `ls /java/servers/`; do
	JBOSS_HOME="/java/servers/$OPT/jboss-as"

	# copia scripts template para alterar	
	cp "$JBOSS_HOME/templates/jboss.sh" "$JBOSS_HOME/bin/jboss_initd.sh"

	sed -i "s|@JBOSS_HOME@|$JBOSS_HOME|g" "$JBOSS_HOME/bin/jboss_initd.sh"
	
	if [ ! -e /etc/init.d/jboss ]; then
	   ln -s "$JBOSS_HOME/bin/jboss_initd.sh" "/etc/init.d/jboss"
	fi

	break
done

# modifica o PATH
echo 'export JAVA_HOME=/java/jdk' >> /etc/profile
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> /etc/profile

# aplica as alteracoes no profile
source /etc/profile

# adiciona ponto de montagem NFS

mkdir -p '/mnt/logs'

echo '172.29.0.230:/vol/logs /mnt/logs nfs rw,bg,hard,nointr,rsize=32768,wsize=32768,tcp,vers=3,timeo=600 2 2' >> /etc/fstab
mount -a

if [ ! -e /var/log/jboss ]; then
   ln -s '/mnt/logs/PRODUCAO/enem' '/var/log/jboss'
fi

# configuracao do jboss_init

echo ""
echo "Configuração do script de inicialização jboss"

HOSTNAME=`hostname -s`
fazer_substituicao "Nome da configuration" "server-jboss-$HOSTNAME" JBOSS_CONF "$JBOSS_HOME/bin/jboss_initd.sh"
JBOSS_CONF_HOME="$JBOSS_HOME/server/$RESPOSTA"

if [ -a "$JBOSS_CONF_HOME" ]; then
	echo -n "Instancia $JBOSS_CONF_HOME jah existe! Deseja remover (sim/nao)?"
	read RESPOSTA

	if [ "$RESPOSTA" == "sim" ]; then
		rm -rf $JBOSS_CONF_HOME
	fi
fi

IP=`ifconfig | perl -nle'/dr:(\S+)/ && print $1' |  head -n1`
IP=${IP:-"127.0.0.1"}

fazer_substituicao "IP o JBoss deve usar" "$IP" JBOSS_IP "$JBOSS_HOME/bin/jboss_initd.sh"

chkconfig --add jboss

echo "Selecione o template da instancia (configuration/profile) do JBoss:"
select CONF in `ls $JBOSS_HOME/templates/ | grep config`; do
        cp -r "$JBOSS_HOME/templates/$CONF" "$JBOSS_CONF_HOME"
	break;
done

# configuracao do run.conf

echo ""
echo "Configuração de propriedades run.conf"

# se houve tuning no kernel p/ large pages, pega a qtd de mem. do /etc/security/limits.conf
MEM_LIMIT=`grep memlock /etc/security/limits.conf | grep -v '#' | awk '{ print $4 }'`


if [ -n "$MEM_LIMIT" ]
then
   # considera 2g para o SO
   MEM_LIMIT=`echo "$MEM_LIMIT - 2097152" | bc`
   MEM_LOCK=`echo "($MEM_LIMIT - 524288) / 1024 / 1024" | bc`
fi

MEM_TOTAL=`grep MemTotal /proc/meminfo | awk '{ print $2 }'`
MEM_TOTAL=`echo "($MEM_TOTAL - 524288) / 1024 / 1024" | bc`

# Se encotrar o memlock (tuning) o tamanho sugerido para o HEAP eh o memlock, 
# caso contrario serah  o tamnho da RAM - 1G
HEAP_SIZE=${MEM_LOCK:-"$MEM_TOTAL"}

NEW=$(( $HEAP_SIZE / 3 ))

fazer_substituicao "Tamanho da memória heap" "${HEAP_SIZE}g" JBOSS_HEAP "$JBOSS_CONF_HOME/run.conf"

fazer_substituicao "Tamanho da new generation" "${NEW}g" JBOSS_NEW_SIZE "$JBOSS_CONF_HOME/run.conf"

# Usar LargePages na JVM?
echo -n "Deseja ativar o uso de LargePages no HEAP da JVM (sim/nao)?"
read RESPOSTA

if [ "$RESPOSTA" == "sim" ]; then
   LARGE_PAGES="-XX:+UseLargePages"
fi

LARGE_PAGES=${LARGE_PAGES:-"-XX:-UseLargePages"}

fazer_substituicao "Habilita o LargePages" "$LARGE_PAGES" USE_LARGE_PAGES "$JBOSS_CONF_HOME/run.conf"

CPUS=`getconf _NPROCESSORS_ONLN`
CPUS=${CPUS:-"1"}
JBOSS_WEB_FILE_CONF=`find $JBOSS_CONF_HOME/deploy/ -type f -name server.xml | grep web | egrep '(\.sar|\.deployer)'`

fazer_substituicao "Quantidades de CPUs" "$CPUS" JBOSS_CPUS "$JBOSS_CONF_HOME/run.conf" 

fazer_substituicao "Valor do MaxThreads" "$(( $CPUS * 250  ))" JBOSS_MAX_THREADS "$JBOSS_WEB_FILE_CONF"

MIN_SPARE_THREADS=$(( $RESPOSTA / 10))
fazer_substituicao "Valor do MinSpareThreads" "$MIN_SPARE_THREADS" MIN_SPARE_THREADS "$JBOSS_WEB_FILE_CONF"

MAX_SPARE_THREADS=$(( $MIN_SPARE_THREADS * 2))
fazer_substituicao "Valor do MaxSpareThreads" "$MAX_SPARE_THREADS" MAX_SPARE_THREADS "$JBOSS_WEB_FILE_CONF"

# configuração do JON
echo ""
echo -n "Instalar agente JON? (sim/nao): "
read INSTALAR_JON

if [ "$INSTALAR_JON" != "sim" ]; then
	exit 0
fi

if [ ! -e /etc/init.d/jon-agent ]; then
   ln -s "/java/tools/rhq-agent/bin/rhq-agent-wrapper.sh" "/etc/init.d/jon-agent"
fi

chkconfig --add jon-agent

echo ""
echo "Executando script de configuração do agente..."

sh "/java/tools/rhq-agent/bin/rhq-agent.sh" -ul

exit 0
