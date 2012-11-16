#!/bin/bash

###
# Script used to replace some text for another one in many files (given a file pattern used in search) 
#
# author: rafaelcba at gmail dot com
###

DIR_PATH=$1
FILE_SEARCH_PATTERN=$2
OLD_STRING=$3
NEW_STRING=$4

LAST_REPLY="S"

askToContinue(){
   if [[ ! $LAST_REPLY =~ ^[Aa]$  ]]
   then
      read -p "continue? ([Y]es/[n]o/[A]ll) " -n1
      echo

      LAST_REPLY=$REPLY
      if [[ ! $REPLY =~ ^[Yy]$ ]]
      then
         continue
      fi
   fi
}

usage(){
   echo
   echo -e "\r invalid call!"
   echo -e "   usage: ./replaceText    "
   echo
   echo -e "\r NOTES:"
   echo -e "\r\t 1) don't use the pattern '*', instead specify a file extension (eg: '*.sh', '*.txt', '*.properties', '*.xml')"
   echo -e "\r\t 2) for text containing special chars you have to scape them with '\'"
   echo
   echo -e "   eg: ./replaceText \"/opt/Oracle/Middleware\" \"*.xml\" \"Oracle\\/Middleware\\/\" \"Oracle\\/Middleware11g\\/\""
   echo
   exit
}

[[ ! "$#" = "4" ]] && usage

for file_name in `find "$DIR_PATH" -type f -name "$FILE_SEARCH_PATTERN"`
do
  #Testa se o arquivo contem o texto a ser substituido
  file $file_name | grep -i "text" > /dev/null
  [[ "$?" -eq "1"  ]] && continue
  grep $OLD_STRING $file_name > /dev/null
  [[ "$?" -eq "1"  ]] && continue

  echo -e "\r\r\r change the file: $file_name \r"
  askToContinue

  echo -e "\t replace [$OLD_STRING] by [$NEW_STRING] \r"

  if [ -d $DIR_PATH  ];
  then
     sed -i.BAK -e "s/${OLD_STRING}/${NEW_STRING}/g" $file_name

     echo -e "\t\t diff $file_name $file_name.BAK"
     echo -e "\r ----------------------------------------"
     diff $file_name $file_name.BAK
     echo -e "\r ----------------------------------------"
  else
     echo -e "\r $PATH_DIR does not exists!"
     exit
  fi

done
