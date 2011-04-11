#/bin/bash

# Configuracoes

# Caminho para onde os arquivos serao copiados
PATH_DESTINO="/media/backup"

# Caminho onde este script foi instalado
MY_PATH="/usr/local/backup"

############################################################
#   NAO RECOMENDO MEXER NOS CODIGOS A PARTIR DESTE PONTO   #
############################################################

AGORA=`date +%Y%m%d-%H%M%S`
ULTIMOFILE="$MY_PATH/bkp-ultimo"
CTRLFILE="$MY_PATH/ctrl-file"
DIR2BKP="$MY_PATH/dir2bkp"
AGORAESTATICO="$AGORA"

# Se o diretorio de destino nao existir, entao o backup nao sera feito
if [ ! -d $PATH_DESTINO ]
	then
		exit 0
fi

# Se for a primeira vez que o backup for feito sera criado o arquivo com o ultimo backup
# com uma data qualquer e o backup completo sera realizado.

if [ ! -f $ULTIMOFILE ]
	then
		echo 20000101-010101 > $ULTIMOFILE
		mkdir $PATH_DESTINO/20000101-010101
fi

ULTIMO=`cat $MY_PATH/bkp-ultimo`

mkdir -p $PATH_DESTINO/$AGORAESTATICO

for DIRS in `cat $DIR2BKP`
	do
		/usr/bin/rsync -R -a --delete --delete-excluded --link-dest=$PATH_DESTINO/$ULTIMO $DIRS $PATH_DESTINO/$AGORAESTATICO
done

echo $AGORAESTATICO > $ULTIMOFILE
