#!/bin/sh
#
# JBoss Control Script
#
# chkconfig:  45 92 08
# description: JBoss Application Server
# Version: 13
#
# Modified by hba (at) conduct.no
#

if [ -f /etc/default/jboss ]; then 
  . /etc/default/jboss
fi

# Define where jboss is - this is the directory containing directories log, bin, conf etc
JBOSS_HOME=${JBOSS_HOME:-"/usr/local/jboss/jboss-as"}

# Define the user under which jboss will run, or use 'RUNASIS' to run as the current user
JBOSS_USER=${JBOSS_USER:-"RUNASIS"}

# Configuration to use, usually one of 'minimal', 'default', 'all'
JBOSS_CONF=${JBOSS_CONF:-"default"}

# If JBOSS_HOST specified, use -b to bind jboss services to that address
JBOSS_BIND_ADDR=${JBOSS_HOST:+"-b $JBOSS_HOST"}

# JNDI address and port
JBOSS_JNDI_PORT=${JBOSS_JNDI_PORT:-"1099"}
JBOSS_JNDI_ADDR=${JBOSS_HOST:+"-s jnp://$JBOSS_HOST:$JBOSS_JNDI_PORT"}

# JMX console credentials
ADMIN_USER_OPT=${JBOSS_ADMIN_USER:+"-u $JBOSS_ADMIN_USER"}
ADMIN_PASS_OPT=${JBOSS_ADMIN_PASS:+"-p $JBOSS_ADMIN_PASS"}

if [ ! -z $JAVA_HOME ]; then
  JAVA=$JAVA_HOME/bin/java
else
  JAVA=java
fi

# Define classpaths for startup and shutdown
JBOSS_CLASSPATH=${JBOSS_CLASSPATH:-"$JBOSS_HOME/bin/run.jar:$JAVA_HOME/lib/tools.jar"}
JBOSS_SHUTDOWN_CLASSPATH=${JBOSS_SHUTDOWN_CLASSPATH:-"$JBOSS_HOME/bin/shutdown.jar:$JBOSS_HOME/client/jnet.jar"}

JAVA_OPTS=${JAVA_OPTS:-"-Xms128m -Xmx512m -XX:MaxPermSize=256m -Dorg.jboss.resolver.warning=true -Dsun.rmi.dgc.client.gcInterval=3600000 \
 -Dsun.rmi.dgc.server.gcInterval=3600000 -Dsun.lang.ClassLoader.allowArraySyntax=true -Djava.net.preferIPv4Stack=true -server"}

JBOSS_ENDORSED_DIRS=${JBOSS_ENDORSED_DIRS:-"$JBOSS_HOME/lib/endorsed"}
JBOSS_PIDFILE=${JBOSS_PIDFILE:-"/var/run/jboss/jboss.pid"}

JBOSS_CONSOLE=${JBOSS_CONSOLE:-"/dev/null"}

##
## End of configurable options
##

if [ "$JBOSS_USER" = "RUNASIS" -o "$USER" = "$JBOSS_USER" ]; then
  SUBIT=""
else
  SUBIT="su - $JBOSS_USER -c "
fi

if [ ! -d "$JBOSS_HOME" ]; then
  echo "JBOSS_HOME does not exist as a valid directory : $JBOSS_HOME"
  exit 1
fi

function status {
  RUNNING_PID=0
  if [ -f $JBOSS_PIDFILE ]; then
    TMP_PID=`cat $JBOSS_PIDFILE`
    TMP_PID_CHECK=`ps -p $TMP_PID -o pid=`
    if [ "$TMP_PID_CHECK" != "" ]; then
      RUNNING_PID=$TMP_PID
      return 0  # running
    else
      return 1  # stopped, but pid file exists 
    fi
  fi
  return 3 # stopped
}

function stop {
  echo "stopping jboss..."

  status
  if [ $? -ne 0 ]; then
    echo "nothing to stop, jboss is not running.  aborting."
    exit 100
  fi

  STOP_CMD="$JAVA -classpath $JBOSS_SHUTDOWN_CLASSPATH org.jboss.Shutdown --shutdown $JBOSS_JNDI_ADDR $ADMIN_USER_OPT $ADMIN_PASS_OPT"
  
  if [ ! -z "$SUBIT" ]; then
    $SUBIT "$STOP_CMD"
  else
    $STOP_CMD
  fi
  RES=$?
  
  if [ $RES -ne 0 ]; then
    echo
    echo "If shutdown failed, please make sure that \$JBOSS_ADMIN_PASS and \$JBOSS_ADMIN_USER reflects your JMX Console admin credentials."
    echo "Use \"$0 force-stop\" to force a shutdown."
    exit $RES
  fi
  
  RUNNING_PID=1
  while [ $RUNNING_PID -ne 0 ]; do
    sleep 1
    status
    echo -n .
  done  
  
  rm -f $JBOSS_PIDFILE
}

function force_stop {
  echo -n "forcibly stopping jboss... "

  status
  if [ $? -ne 0 ]; then 
    echo "jboss is not running.  aborting."
  else
    CHILD_PID=`ps --ppid $RUNNING_PID -o pid=`
    GRANDCHILD_PID=`ps --ppid $CHILD_PID -o pid=`
    ALL_PIDS="$RUNNING_PID $CHILD_PID $GRANDCHILD_PID"
    echo "(pids $ALL_PIDS)"
    kill $ALL_PIDS && rm -f $JBOSS_PIDFILE 2>/dev/null
    sleep 3
    kill -9 $ALL_PIDS 2>/dev/null && rm -f $JBOSS_PIDFILE
  fi
}

function start {
  echo "starting jboss..."

  status
  if [ $? -eq 0 ]; then
    echo "jboss (pid $RUNNING_PID) is already running. aborting."
    exit 100
  fi

  START_CMD="$JAVA $JAVA_OPTS -Djava.endorsed.dirs=$JBOSS_ENDORSED_DIRS -classpath $JBOSS_CLASSPATH \
         org.jboss.Main -c $JBOSS_CONF $JBOSS_BIND_ADDR" 

  if [ ! -z "$SUBIT" ]; then
    $SUBIT "( $START_CMD > $JBOSS_CONSOLE 2>&1 )" &
    $SUBIT "( echo $! > $JBOSS_PIDFILE )" 
  else
    $START_CMD > $JBOSS_CONSOLE 2>&1 &
    echo $! > $JBOSS_PIDFILE
  fi
  sleep 1
  status
  if [ $? -ne 0 ]; then
    echo "jboss failed to start. please check the logs."
    exit 1
  fi
}


case "$1" in
start)
    start
    ;;
stop)
    stop
    ;;
force-stop)
    force_stop
    ;;
restart)
    $0 stop && sleep 1 && $0 start
    ;;
force-restart)
    $0 force-stop && sleep 1 && $0 start
    ;;
status)
    status
    RET=$?
    if [ $RET -eq 0 ]; then
      echo "jboss (pid $RUNNING_PID) is running..."
    elif [ $RET -eq 1 ]; then
      echo "jboss is dead but pidfile ($JBOSS_PIDFILE) exists..."
    else
      echo "jboss is stopped."
    fi
    exit $RET
    ;;
*)
    echo "usage: $0 (start|stop|force-stop|restart|force-restart|status|help)"
esac


