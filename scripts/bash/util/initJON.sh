#!/bin/bash

case "$1" in
start)
   sudo /etc/init.d/postgresql start
   ~/opt/rhq-agent/bin/rhq-agent-wrapper.sh start
   ~/opt/jon-server-2.4.0.GA/bin/rhq-server.sh start
   sleep 3

   echo -n "Iniciar VMs? "
   read RESPOSTA

   if [ "x$RESPOSTA" == "s" ]; then
      echo "   iniciando VMS..."
      VBoxManage startvm RHEL-01 --type headless
      sleep 10

      VBoxManage startvm RHEL-02 --type headless
      sleep 10

      VBoxManage startvm RHEL-03-WebServer --type headless
   fi

   ;;
stop)
   sudo /etc/init.d/postgresql stop
   ~/opt/rhq-agent/bin/rhq-agent-wrapper.sh kill
   ~/opt/jon-server-2.4.0.GA/bin/rhq-server.sh stop

   
   echo "   desligando VMS..."
   VBoxManage controlvm RHEL-01 poweroff
   VBoxManage controlvm RHEL-02 poweroff
   VBoxManage controlvm RHEL-03-WebServer poweroff

   ;;
*)
   echo "use: initJON.sh start|stop"
esac

