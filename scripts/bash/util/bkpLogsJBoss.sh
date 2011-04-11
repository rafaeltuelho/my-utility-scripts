#!/bin/sh

# diretorio raiz de dos logs de cada ambiente
RAIZ="/mnt/logs"
LOG_DESENV="DESENV"
LOG_HOMOLOGA="HOMOLOGA"
LOG_PRODUCAO="PRODUCAO"

DATA=`date +%d%m%Y`
BKP_DIR="/tmp"
FILE_NAMES="server-*.log.*"

findSubDir ()
{
   currentDIR=$1
   baseName=`basename $currentDIR`
   tarName="${BKP_DIR}/jbossLogs-${baseName}-${DATA}.tar.gz"

#   echo "$0 entrei currentDIR=$currentDIR..."

   numSubDir=`find $currentDIR -type d | wc -l`
   numLogFiles=`find $currentDIR -maxdepth 1 -type f -name $FILE_NAMES | wc -l`
#   echo "numSubDir=$numSubDir"
#   echo "numLogFiles=$numLogFiles"

   read

   if [ $numSubDir -gt 1  ];
   then

      for subdir in `find $currentDIR -type d`
         do 
            currentDIR=$subdir
            baseName=`basename $currentDIR`
            tarName="${BKP_DIR}/jbossLogs-${baseName}-${DATA}.tar.gz"

            numLogFiles=`find $subdir -maxdepth 1 -type f -name $FILE_NAMES | wc -l`

#            echo "> currentDIR=$currentDIR"
#            echo "> numLogFiles=$numLogFiles"

            if [ $numLogFiles -gt 0 ]; then
#               echo "> tar --remove-files -zcvf ${tarName} ${currentDIR}/${FILE_NAMES}"
               tar --remove-files -zcvf ${tarName} ${currentDIR}/${FILE_NAMES}
            fi
         
#            echo "> subdir=$subdir"
#            echo "> currentDIR=$currentDIR"

            if [ "$subdir" != "$currentDIR" ]; 
            then
               echo ">> recursividade!!!"
               findSubDir $subdir
            fi
         done

   else
      if [ $numLogFiles -gt 0 ]; then 
#         echo "tar --remove-files -zcvf ${tarName} ${currentDIR}/${FILE_NAMES}"
         tar --remove-files -zcvf ${tarName} ${currentDIR}/${FILE_NAMES}
      fi
   fi 
   
   return
}

#echo "$0"

for dir in `ls $RAIZ`
do 
#   echo $dir

   if [ \( -d "$RAIZ/$dir" \) -a \
        \( "$dir" == "$LOG_DESENV" -o "$dir" == "$LOG_HOMOLOGA" -o "$dir" == "$LOG_PRODUCAO" \) ]
   then
      findSubDir "$RAIZ/$dir"
   fi

done

