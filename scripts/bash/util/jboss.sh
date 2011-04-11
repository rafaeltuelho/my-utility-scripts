#!/bin/sh
#
# chkconfig: 345 90 10
# description: JBoss App Server (Script para start|stop|restart|kill em um instancia do JBoss AS)
# processname: jboss-eap4.2
# pidfile: /var/run/jboss-eap4.2.pid

### configuracoes especificas para o INEP ###
# credenciais administrativas do jboss (definidas em JBOSS_HOME/server/<profile>/conf/props/jmx-console-users.properties)
export  JBOSS_ADMIN_USER=admin
export  JBOSS_ADMIN_PWD=admin
# porta do JNDI service do JBoss (usada para shutdown)
export  JBOSS_JNP_PORT=1099
# A SEGUNTE VARIAVEL SOH FAZ SENTIDO PARA JBOSS-EAP-5.X
# para jboss-eap-4.x o service bind deve ser configurado no arquivo JBOSS_HOME/server/<profile>/conf/jboss-service.xml
# define o service bind (conjunto de portas dos conectores http, ejb, jms, etc) usado para a instancia do jboss
#   pode ser (ports-default, ports-01, ports-02, ports-03)
export  JBOSS_SERVICE_BIND="ports-default"
# Define o nivel de log do jboss
#   o nivel de log obedece os niveis do LOG4J (FATAL ERROR WARN INFO DEBUG TRACE ALL OFF) 
export  JBOSS_LOG_LEVEL="INFO"
# define o profile (nome da instancia) usada para iniciar o jboss
JBOSS_CONF=default
# define o ip onde jboss farah o bind
JBOSS_HOST=172.29.0.56
# PATH do dir. de instalacao do JBoss 
export  JBOSS_HOME="/java/servers/jboss-eap-4.2/jboss-as"
# nome do script de controle do jboss
export  JBOSS_CTRL_SCRIPT="jboss_init_redhat_INEP.sh"
# usuario que ira executar o jboss
export  JBOSS_USER="root"
# PATH de instalcao do java (JDK)
export JAVA_HOME="/java/jdk"
### configuracoes especificas para o INEP ###

case "$1" in
start)
    $JBOSS_HOME/bin/$JBOSS_CTRL_SCRIPT start $JBOSS_CONF $JBOSS_HOST
    ;;
stop)
    $JBOSS_HOME/bin/$JBOSS_CTRL_SCRIPT stop $JBOSS_CONF $JBOSS_HOST
    ;;
kill)
    $JBOSS_HOME/bin/$JBOSS_CTRL_SCRIPT kill $JBOSS_CONF $JBOSS_HOST
    ;;
restart)
    $JBOSS_HOME/bin/$JBOSS_CTRL_SCRIPT restart $JBOSS_CONF $JBOSS_HOST
    ;;
*)
    echo "usage: $0 (start|stop|restart|kill)"
esac

# TODO 
# Funcao para montar menu interativo
# que permite a escolha de qual JBoss, instancia e IP 
# usado durante o processo de start/stop/restart
#function listaServers()
#{
        # lista os jboss instalados
	#find /java/servers/ -type f -name run.sh | fgrep -i jboss
        # listas as instancias (profilers) do jboss selecionado 
        #ls -l /java/servers/jboss-eap-4.2/jboss-as/server/	
        # lista os IPs configurados no HOST
	#ifconfig | perl -nle'/dr:(\S+)/ && print $1'
#}


