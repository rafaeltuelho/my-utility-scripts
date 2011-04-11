#!/bin/bash

clear
while [ 1 ] ; do
        echo ""
        echo "Numero de conexoes ESTAB. na porta 80 (http): `netstat -tan  | grep 80 | grep ESTABLISHED | wc -l`"
        echo "Numero de conexoes TOTAL na porta 80 (http): `netstat -tan  | grep 80 | wc -l`"
        echo "Numero de conexoes TOTAL na porta 1521 (oracle): `netstat -tan  | grep 1521 | grep ESTABLISHED | wc -l`"
        #echo "Load do servidor: `uptime | awk '{print $8}' | cut -d, -f1`"
        echo "Uptime: `uptime`"
        echo "Utilizacao de Memoria: `free -g | grep Mem: | awk '{print $3}'` GB"

        echo ""
        echo "-----------------------------------"
        echo ""

        echo "Utilizacao de Memoria pelos processos JAVA"

        ps -ylC java --sort:rss | tr -s ' ' ' ' | cut -f3 -d' ' > /tmp/PID_java
        echo "MEM" > /tmp/MEM_java
        echo "NOF" > /tmp/NOF_java

        total=0
        for mem in `ps -ylC java --sort:rss | tr -s ' ' ' ' | cut -f8 -d' ' | grep -v RSS`; do
                mb=`expr $mem / 1024`
                total=`expr $mem + $total`
                echo "$mb MB" >> /tmp/MEM_java

        done

        for pid in `ps -ylC java --sort:rss | tr -s ' ' ' ' | cut -f3 -d' ' | grep -v PID`; do
                echo "`lsof -p $pid | wc -l`" >> /tmp/NOF_java

        done

        paste /tmp/PID_java /tmp/MEM_java /tmp/NOF_java
        echo "Total de mem. utilizado pelas JVMs: `expr \( $total / 1024 \) / 1024` GB"
        sleep 10


done
