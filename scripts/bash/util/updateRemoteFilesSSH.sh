#!/bin/sh

#####
# Script para atualizar/copiar/replicar arquivos 
#    de configuração/scrpts/etc em servidores remotos
# ----------------------------------
# Autor: Rafael Torres - Tuelho
# eMail: rafaelcba at gmail dot com
# Data : agosto de 2008
#####


# CONSTANTES
readonly TMPDIR=/tmp/updateFiles

# variaveis
sshUser="$1"
pathOrigem="$2"
pathDestino="$3"
srvOrigem="$4"
listaSrvRemotos="$5"

echo ">>> lista de servidores remotos: $listaSrvRemotos"

uso()
{
	echo ". updateRemoteFilesSSH.sh <userSSH> <path de origem> <path de destino> <srv de origem> \"<lista de srvs destino separados por espaco...>\""
}

# testa os parametros passados
if [ "$#" != "5" ]; then
   uso
   exit 1
fi

# copia o(s) arquivos desejados no servidor de origem...
mkdir -p $TMPDIR
scp -qr $sshUser@$srvOrigem:$pathOrigem $TMPDIR
echo ">>> o(s) seguinte(s) arquivo(s)/dir(s):"
echo `ls $TMPDIR/*`
echo ">>> foram baixados e copiados para: $TMPDIR"

echo ">>> enviando via ssh..."

# percorre a lista de servidores remotos..
for srv in `echo ${listaSrvRemotos}`
do
	scp -r $TMPDIR/* $sshUser@$srv:$pathDestino/
	#echo "ssh -r $TMPDIR/* $sshUser@$srv:$pathDestino/"
done

echo ">>> fim do envio!"

echo "removendo $TMPDIR..."
rm -Rf $TMPDIR

