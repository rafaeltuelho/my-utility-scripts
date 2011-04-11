#!/bin/sh
#
# $Id: jboss_init_redhat.sh 63830 2007-07-04 21:34:47Z dbhole $
#
# JBoss Control Script
#
# To use this script run it as root - it will switch to the specified user
#
# Here is a little (and extremely primitive) startup/shutdown script
# for RedHat systems. It assumes that JBoss lives in /usr/local/jboss,
# it's run by user 'jboss' and JDK binaries are in /usr/local/jdk/bin.
# All this can be changed in the script itself. 
#
# Either modify this script for your requirements or just ensure that
# the following variables are set correctly before calling the script.

### configuracoes especificas para o INEP ###
# credenciais administrativas do jboss (definidas em JBOSS_HOME/server/<profile>/conf/props/jmx-console-users.properties)
  JBOSS_ADMIN_USER=${JBOSS_ADMIN_USER:-"admin"}
  JBOSS_ADMIN_PWD=${JBOSS_ADMIN_PWD:-"admin"}
# porta do JNDI service do JBoss (usada para shutdown)
  JBOSS_JNP_PORT=${JBOSS_JNP_PORT:-"1099"}
# A SEGUNTE VARIAVEL SOH FAZ SENTIDO PARA JBOSS-EAP-5.X
# para jboss-eap-4.x o service bind deve ser configurado no arquivo JBOSS_HOME/server/<profile>/conf/jboss-service.xml
# define o service bind (conjunto de portas dos conectores http, ejb, jms, etc) usado para a instancia do jboss
#   pode ser (ports-default, ports-01, ports-02, ports-03)
  JBOSS_SERVICE_BIND=${JBOSS_SERVICE_BIND:-"ports-default"}
# Define o nivel de log do jboss
#   o nivel de log obedece os niveis do LOG4J (FATAL ERROR WARN INFO DEBUG TRACE ALL OFF) 
  JBOSS_LOG_LEVEL=${JBOSS_LOG_LEVEL:-"INFO"}
# define o profile (nome da instancia) usada para iniciar o jboss
  JBOSS_CONF=${JBOSS_CONF:-"$2"}
# define o ip onde jboss farah o bind
  JBOSS_HOST=${JBOSS_HOST:-"$3"}
### configuracoes especificas para o INEP ###

#define where jboss is - this is the directory containing directories log, bin, conf etc
#JBOSS_HOME=${JBOSS_HOME:-"/usr/local/jboss"}
JBOSS_HOME=${JBOSS_HOME:-"/java/servers/jboss/jboss-as"}

#define the user under which jboss will run, or use 'RUNASIS' to run as the current user
#JBOSS_USER=${JBOSS_USER:-"jboss"}
JBOSS_USER=${JBOSS_USER:-"root"}

#make sure java is in your path
JAVAPTH=${JAVAPTH:-"$JAVA_HOME/bin"}

#configuration to use, usually one of 'minimal', 'default', 'all', 'production'
#JBOSS_CONF=${JBOSS_CONF:-"production"}
JBOSS_CONF=${JBOSS_CONF:-"$JBOSS_CONF"}

#if JBOSS_HOST specified, use -b to bind jboss services to that address
JBOSS_BIND_ADDR=${JBOSS_HOST:+"-b $JBOSS_HOST"}

#define the classpath for the shutdown class
#JBOSSCP=${JBOSSCP:-"$JBOSS_HOME/bin/shutdown.jar:$JBOSS_HOME/client/jnet.jar"}
JBOSSCP=${JBOSSCP:-"$JBOSS_HOME/bin/shutdown.jar:$JBOSS_HOME/client/jnet.jar"}

#define the script to use to start jboss
#JBOSSSH=${JBOSSSH:-"$JBOSS_HOME/bin/run.sh -c $JBOSS_CONF $JBOSS_BIND_ADDR"}
JBOSSSH=${JBOSSSH:-"$JBOSS_HOME/bin/run.sh -c $JBOSS_CONF $JBOSS_BIND_ADDR"}

if [ "$JBOSS_USER" = "RUNASIS" ]; then
  SUBIT=""
else
  SUBIT="su - $JBOSS_USER -c "
fi

if [ -n "$JBOSS_CONSOLE" -a ! -d "$JBOSS_CONSOLE" ]; then
  # ensure the file exists
  touch $JBOSS_CONSOLE
  if [ ! -z "$SUBIT" ]; then
    chown $JBOSS_USER $JBOSS_CONSOLE
  fi 
fi

if [ -n "$JBOSS_CONSOLE" -a ! -f "$JBOSS_CONSOLE" ]; then
  echo "WARNING: location for saving console log invalid: $JBOSS_CONSOLE"
  echo "WARNING: ignoring it and using /dev/null"
  JBOSS_CONSOLE="/dev/null"
fi

#define what will be done with the console log
JBOSS_CONSOLE=${JBOSS_CONSOLE:-"/dev/null"}


if [ "x$JBOSS_SERVICE_BIND" != "x" ]; then
   JBOSS_JVM_PROP="-Djboss.service.binding.set=$JBOSS_SERVICE_BIND"
fi

if [ "x$JBOSS_LOG_LEVEL" != "x" ]; then
   JBOSS_JVM_PROP="$JBOSS_JVM_PROP -Djboss.server.log.threshold=$JBOSS_LOG_LEVEL"
fi

JBOSS_CMD_START="cd $JBOSS_HOME/bin; $JBOSSSH $JBOSS_JVM_PROP"
JBOSS_CMD_STOP=${JBOSS_CMD_STOP:-"java -classpath $JBOSSCP org.jboss.Shutdown --shutdown -s jnp://$JBOSS_HOST:$JBOSS_JNP_PORT -u $JBOSS_ADMIN_USER -p $JBOSS_ADMIN_PWD"}
JBOSS_CMD_HALT=${JBOSS_CMD_HALT:-"java -classpath $JBOSSCP org.jboss.Shutdown -H 1       -s jnp://$JBOSS_HOST:$JBOSS_JNP_PORT -u $JBOSS_ADMIN_USER -p $JBOSS_ADMIN_PWD"}

if [ -z "`echo $PATH | grep $JAVAPTH`" ]; then
  export PATH=$PATH:$JAVAPTH
fi

if [ $# != 3  ]; then
   echo "usage: $0 (start <instance_name ip>|stop <instance_name ip>|restart <instance_name ip>|kill <instance_name ip>|help)"
   exit 1
fi


if [ ! -d "$JBOSS_HOME" ]; then
  echo JBOSS_HOME does not exist as a valid directory : $JBOSS_HOME
  exit 1
fi

function cleanWorkTmp()
{
        # clean tmp and work dirs
        echo "clean work and tmp dirs from ${JBOSS_CONF}..."

        rm -Rf "$JBOSS_HOME/server/${JBOSS_CONF}/work"
        rm -Rf "$JBOSS_HOME/server/${JBOSS_CONF}/tmp"
}

function jbossPID()
{
    # try get the JVM PID
    local jbossPID="x"
    jbossPID=$(ps -eo pid,cmd | grep "org.jboss.Main" | grep "${JBOSS_HOST}" | grep "${JBOSS_SERVICE_BIND}" | grep -v grep | cut -c0-6)

    echo "$jbossPID"
}

case "$1" in
start)
    cd $JBOSS_HOME/bin

    # verifica se a instancia jah estah em execucao
    PID=$(jbossPID)
    if [ "x$PID" = "x" ]
    then
       echo "starting JBoss (instance $JBOSS_CONF at $JBOSS_HOST)..."
       echo "   using service bind: $JBOSS_SERVICE_BIND"
       #echo "CMD: $JBOSS_CMD_START"

       if [ -z "$SUBIT" ]; then
          eval $JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &
       else
          $SUBIT "$JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &" 
       fi
    else
       echo "JBoss (instance $JBOSS_CONF at $JBOSS_HOST) is running [PID $PID]"
    fi
    ;;
stop)
    echo "stop JBoss (instance $JBOSS_CONF at $JBOSS_HOST)..."

    if [ -z "$SUBIT" ]; then
        $JBOSS_CMD_STOP
    else
        #echo "CMD: $JBOSS_CMD_STOP"
        $SUBIT "$JBOSS_CMD_STOP"
    fi 

    sleep 15

    # try get the JVM PID
    PID=$(jbossPID)
    if [ "x$PID" = "x" ]
    then
       echo "JBoss (instance $JBOSS_CONF at $JBOSS_HOST) stopped!"
    else
       echo "process still running..."
       echo "killing JBoss (JVM process) [PID $PID]"
       kill -9 $PID
    fi

    cleanWorkTmp
    ;;
kill)
    echo "trying halt the JVM process..."
    #echo "CMD: $JBOSS_CMD_HALT"

    $SUBIT "$JBOSS_CMD_HALT" &

    sleep 15

    # try get the JVM PID
    PID=$(jbossPID)
    if [ "x$PID" = "x" ]
    then
       echo "JBoss (instance $JBOSS_CONF at $JBOSS_HOST) not runing! JVM process not found!"
    else
       echo "process still running..."
       echo "killing JBoss (JVM process) [PID $PID]"
       kill -9 $PID
    fi

    cleanWorkTmp
    ;;
restart)
    $0 stop $2 $3
    $0 start $2 $3
    ;;
*)
    echo "usage: $0 (start <instance_name ip>|stop <instance_name ip>|restart <instance_name ip>|kill <instance_name ip>|help)"
esac

