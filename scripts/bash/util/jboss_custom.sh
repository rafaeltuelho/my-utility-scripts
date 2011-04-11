#!/bin/sh
#
# chkconfig: 345 90 10
# description: JBoss App Server (Script para start|stop|restart|kill|status em um instancia do JBoss AS)
# processname: jboss

# define o profile (nome da instancia) usada para iniciar o jboss
  JBOSS_NODE="node12"
# define o ip onde jboss farah o bind
  JBOSS_BIND_ADDR="0.0.0.0"
# Incremento do conjunto de portas
  JBOSS_PORTS_OFFSET="1200"
# Niveis do LOG4J (FATAL ERROR WARN INFO DEBUG TRACE ALL OFF) 
  JBOSS_LOG_LEVEL="INFO"
# nome do script de controle do jboss
  JBOSS_CTRL_SCRIPT="/opt/jboss-eap-5.0.1/jboss-as/bin/jboss_init_redhat_custom.sh"

case "$1" in
start)
    $JBOSS_CTRL_SCRIPT "start"   $JBOSS_NODE $JBOSS_BIND_ADDR $JBOSS_PORTS_OFFSET $JBOSS_LOG_LEVEL
    ;;
stop)
    $JBOSS_CTRL_SCRIPT "stop"    $JBOSS_NODE $JBOSS_BIND_ADDR $JBOSS_PORTS_OFFSET $JBOSS_LOG_LEVEL
    ;;
kill)
    $JBOSS_CTRL_SCRIPT "kill"    $JBOSS_NODE $JBOSS_BIND_ADDR $JBOSS_PORTS_OFFSET $JBOSS_LOG_LEVEL
    ;;
restart)
    $JBOSS_CTRL_SCRIPT "restart" $JBOSS_NODE $JBOSS_BIND_ADDR $JBOSS_PORTS_OFFSET $JBOSS_LOG_LEVEL
    ;;
status)
    $JBOSS_CTRL_SCRIPT "status"  $JBOSS_NODE $JBOSS_BIND_ADDR $JBOSS_PORTS_OFFSET $JBOSS_LOG_LEVEL
    ;;
*)
    echo "usage: $0 (start|stop|restart|kill|status)"
esac

