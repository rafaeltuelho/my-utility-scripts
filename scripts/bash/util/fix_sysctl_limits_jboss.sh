#!/bin/bash

# The machine tunning

# Recupera a qtd. de MEM total em KBytes
MEMTOTAL=$(cat /proc/meminfo | grep "MemTotal" | awk '{ print $2}')

# Obtem o tamanho da HugePage em KBytes
HUGEPAGESIZE=$(cat /proc/meminfo | grep "Hugepagesize" | awk '{ print $2}')

#Percentual da MEM. total reservado para o SO
PERCENTMEM=`echo "scale=2; (20/100) * $MEMTOTAL" | bc | cut -f1 -d.` # nesse caso serah reservado 20% do total para o SO

# Caso a mem. disponivel seja igual ou inferior a 12GB reserva 30% para o SO
if [ $MEMTOTAL -le 12582912 ] ; then
  PERCENT=`echo "$PERCENT * 3" | bc `
fi

# Memoria que sera usada para LagePages
MEMADJUST=`echo "($MEMTOTAL - $PERCENTMEM)" | bc`

# Maximo de segmentos de mem. compartilhada permitida em Bytes
SHMMAX=`echo "$MEMTOTAL * 1024" | bc`

# Quantidade maxima de HugePages
MAXHUGEPAGE=`echo "$MEMADJUST/$HUGEPAGESIZE" | bc `

# Quantidade de mem. alocada para o usuario dono do processo que farah uso das HugePages
MEMLOCK=`echo "$MAXHUGEPAGE * $HUGEPAGESIZE" | bc`

# salva um bkp do arq original
cp -f /etc/sysctl.conf /etc/sysctl.conf.ori

cat > /etc/sysctl.conf <<EOF
net.ipv4.ip_forward = 0
net.ipv4.conf.default.rp_filter = 1
net.ipv4.conf.default.accept_source_route = 0
kernel.sysrq = 0
kernel.core_uses_pid = 1
net.ipv4.tcp_syncookies = 1
kernel.msgmnb = 65536
kernel.msgmax = 65536

# Red Hat tuning - Memory for JVM/JBOSS process
vm.nr_hugepages = $MAXHUGEPAGE

kernel.shmmax = $SHMMAX

# Controls the maximum number of shared memory segments, in pages
kernel.shmall = 4294967296

# Red Hat tuning - Network
net.ipv4.tcp_tw_recycle = 1
#net.ivp4.tcp_tw_reuse = 1
#net.ipv4.tcp_keepalive_probes = 5
#net.core.somaxconn = 5000
#net.ipv4.tcp_fin_timeout = 30
#net.ipv4.tcp_keepalive_time = 1800
#net.core.rmem_max = 8388608 
#net.core.wmem_max = 8388608 

# Parametros indicados pelo Fabio da System TI (Storage Netapp)
net.ipv4.tcp_max_syn_backlog = 1024
net.core.netdev_max_backlog = 5000
net.ipv4.tcp_mem = 378240 504320 756480
net.ipv4.tcp_wmem = 4096 16384 4194304
net.ipv4.tcp_rmem = 4096 87380 4194304

# root permission to access the shared memory
vm.hugetlb_shm_group = 0

EOF


# salva um bkp do arq original
cp -f /etc/security/limits.conf /etc/security/limits.conf.ori

cat > /etc/security/limits.conf <<EOF

# /etc/security/limits.conf
#
#Each line describes a limit for a user in the form:
#
#<domain>        <type>  <item>  <value>
#
#Where:
#<domain> can be:
#        - an user name
#        - a group name, with @group syntax
#        - the wildcard *, for default entry
#        - the wildcard %, can be also used with %group syntax,
#                 for maxlogin limit
#
#<type> can have the two values:
#        - "soft" for enforcing the soft limits
#        - "hard" for enforcing hard limits
#
#<item> can be one of the following:
#        - core - limits the core file size (KB)
#        - data - max data size (KB)
#        - fsize - maximum filesize (KB)
#        - memlock - max locked-in-memory address space (KB)
#        - nofile - max number of open files
#        - rss - max resident set size (KB)
#        - stack - max stack size (KB)
#        - cpu - max CPU time (MIN)
#        - nproc - max number of processes
#        - as - address space limit
#        - maxlogins - max number of logins for this user
#        - maxsyslogins - max number of logins on the system
#        - priority - the priority to run user process with
#        - locks - max number of file locks the user can hold
#        - sigpending - max number of pending signals
#        - msgqueue - max memory used by POSIX message queues (bytes)
#        - nice - max nice priority allowed to raise to
#        - rtprio - max realtime priority
#
#<domain>      <type>  <item>         <value>
#

#*               soft    core            0
#*               hard    rss             10000
#@student        hard    nproc           20
#@faculty        soft    nproc           20
#@faculty        hard    nproc           50
#ftp             hard    nproc           0
#@student        -       maxlogins       4

#Tuning Jboss environment
root  -  nofile 999999 
root  -  memlock $MEMLOCK

EOF

# Apply the configuration
/sbin/sysctl -p
