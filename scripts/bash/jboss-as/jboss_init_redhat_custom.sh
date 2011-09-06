#!/bin/sh
# chkconfig: 345 90 10
# description: JBoss EAP 5 Service
#
# JBoss Control Script
# To use this script run it as root - it will switch to the specified user
#
# Either modify this script for your requirements or just ensure that
# the following variables are set correctly before calling the script.

# JBoss Home
  JBOSS_HOME="/home/rsoares/opt/jboss-eap-5.1.1-JBM/jboss-as"
# Ports Binding set
  JBOSS_SERVICE_BIND=${JBOSS_SERVICE_BIND:-"ports-default"}
# define o profile (nome da instancia) usada para iniciar o jboss
  JBOSS_PROFILE=${JBOSS_PROFILE:-"production"}
# define o ip onde jboss farah o bind
  JBOSS_BIND_ADDR=${JBOSS_BIND_ADDR:-"127.0.0.1"}
# porta do JNDI service do JBoss (usada para shutdown)
  JBOSS_JNP_PORT=${JBOSS_JNP_PORT:-"1099"}
# LOG4J Level (FATAL ERROR WARN INFO DEBUG TRACE ALL OFF) 
  JBOSS_LOG_LEVEL=${JBOSS_LOG_LEVEL:-"INFO"}
# Dir. de logs
  JBOSS_LOG_DIR=${JBOSS_LOG_DIR:-"$JBOSS_HOME/server/$JBOSS_PROFILE/log"}
# define the user under which	 jboss will run, or use 'RUNASIS' to run as the current user
  JBOSS_USER=${JBOSS_USER:-"jboss"}
# clear work and tmp dirs?
  CLEAR_WORK_TMP="Y"

# Clustering Configs
# Fill these only when using profiling supporting clustering. Otherise they'll be ignored by the script
#    -g, --partition=<name>        HA Partition name (default=DefaultDomain)
#    -m, --mcast_port=<ip>         UDP multicast port; only used by JGroups
#    -u, --udp=<ip>                UDP multicast address
#    -Djboss.default.jgroups.stack=udp|udp-async|udp-sync|tcp|tcp-sync
  CLUSTER_PARTITION=${CLUSTER_PARTITION:-"DefaultPartition"}
  CLUSTER_JGROUPS_STACK=${CLUSTER_JGROUPS_STACK:-"udp"}
  CLUSTER_UDP_MCAST_ADDR=${CLUSTER_UDP_MCAST_ADDR:-"228.11.11.11"}
  CLUSTER_UDP_MCAST_PORT=${CLUSTER_UDP_MCAST_PORT:-"55225"}

# JMX Credentials
  JMX_CREDETIALS_FILE="$JBOSS_HOME/server/$JBOSS_PROFILE/conf/props/jmx-console-users.properties"
  JMX_USER=$(cat $JMX_CREDETIALS_FILE | grep -v '#' | cut -d '=' -f 1 | head -n 1)
  JMX_PWD="$(cat $JMX_CREDETIALS_FILE | grep -v '#' | cut -d '=' -f 2 | head -n 1 | tr -d '\r')"

  JBOSS_ADMIN_USER=${JMX_USER:-"admin"}
  JBOSS_ADMIN_PWD=${JMX_PWD:-"admin"}

# make sure java is in your path
  JAVAPTH=${JAVAPTH:-"$JAVA_HOME/bin"}
# define the classpath for the shutdown class
  JBOSSCP=${JBOSSCP:-"$JBOSS_HOME/bin/shutdown.jar:$JBOSS_HOME/client/jnet.jar"}

# define the script to use to start jboss
# test if the profile has cluster support
if [ -e $JBOSS_HOME/server/$JBOSS_PROFILE/deploy/cluster ]; then
   JBOSSSH="$JBOSS_HOME/bin/run.sh -c $JBOSS_PROFILE -b $JBOSS_BIND_ADDR -g $CLUSTER_PARTITION -Djboss.default.jgroups.stack=$CLUSTER_JGROUPS_STACK"

   if [[ "$CLUSTER_JGROUPS_STACK" =~ udp* ]]; then
     JBOSSSH="$JBOSSSH -u $CLUSTER_UDP_MCAST_ADDR -m $CLUSTER_UDP_MCAST_PORT "
   fi

else
  JBOSSSH=${JBOSSSH:-"$JBOSS_HOME/bin/run.sh -c $JBOSS_PROFILE -b $JBOSS_BIND_ADDR "}
fi

# get the current user
  CURRENT_USER=`whoami`

if [ "$JBOSS_USER" = "RUNASIS" -o "$JBOSS_USER" = "$CURRENT_USER"  ]; then
  SUBIT=""
else
  SUBIT="su - $JBOSS_USER -c "
  SUBIT="su -l $JBOSS_USER -c "
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

JBOSS_JVM_PROP="-Djboss.service.binding.set=$JBOSS_SERVICE_BIND"
JBOSS_JVM_PROP="$JBOSS_JVM_PROP -Djboss.server.log.threshold=$JBOSS_LOG_LEVEL"
JBOSS_JVM_PROP="$JBOSS_JVM_PROP -Djboss.server.log.dir=$JBOSS_LOG_DIR"

JBOSS_CMD_START="$JBOSSSH $JBOSS_JVM_PROP"

JBOSS_CMD_STOP=${JBOSS_CMD_STOP:-"java -classpath $JBOSSCP org.jboss.Shutdown --shutdown \
                                  -s jnp://$JBOSS_BIND_ADDR:$JBOSS_JNP_PORT \
                                  -u $JBOSS_ADMIN_USER -p $JBOSS_ADMIN_PWD"}

if [ -z "`echo $PATH | grep $JAVAPTH`" ]; then
   export PATH=$PATH:$JAVAPTH
fi

if [ $# != 1  ]; then
   echo "usage: $0 start|stop|restart|kill|status "
   exit 1
fi

if [ ! -d "$JBOSS_HOME" ]; then
   echo JBOSS_HOME does not exist as a valid directory : $JBOSS_HOME
   exit 1
fi

function twiddleStatus()
{
   # use twiddle to get some server status 
   TWIDDLE_CMD="$JBOSS_HOME/bin/twiddle.sh -s jnp://$JBOSS_BIND_ADDR:$JBOSS_JNP_PORT -u $JBOSS_ADMIN_USER -p $JBOSS_ADMIN_PWD"
   TWIDDLE_CMD_GET="$TWIDDLE_CMD get"
   TWIDDLE_CMD_QRY="$TWIDDLE_CMD query"
   TWIDDLE_CMD_IVK="$TWIDDLE_CMD invoke"
 
   SERVER_MBEAN="jboss.system:type=Server"
   SERVER_INFO_MBEAN="jboss.system:type=ServerInfo"
   JBOSS_WEB_THREADPOOL_MBEAN="jboss.web:type=ThreadPool,name=http-0.0.0.0-8009"
   JBOSS_WEB_GLOBAL_REQUEST_PROCESSOR_MBEAN="jboss.web:type=GlobalRequestProcessor,name=http-0.0.0.0-8009"
   JBOSS_WEB_DEPLOYMENTS_MBEAN="jboss.web.deployment:*"
   JBOSS_JCA_MBEAN="jboss.jca:*"
   WEB_APP_MBEAN="jboss.web:type=Manager,path="

   #Server Info
   echo "      |--- $($TWIDDLE_CMD_GET $SERVER_MBEAN VersionName)"
   echo "      |--- $($TWIDDLE_CMD_GET $SERVER_MBEAN VersionNumber)"
   echo "      |--- $($TWIDDLE_CMD_GET $SERVER_MBEAN StartDate)"
   echo "      |--- $($TWIDDLE_CMD_GET $SERVER_INFO_MBEAN JavaVersion)"
   echo "          JVM Flags"

   if [ -e "$JAVA_HOME/bin/jinfo" ]; then
      $JAVA_HOME/bin/jinfo -flags $PID 2>&1 | grep "run.sh" | tr ' ' '\n'
   fi

   echo " "
   echo "      |--- $($TWIDDLE_CMD_GET $SERVER_INFO_MBEAN ActiveThreadCount)"

   MaxMemInBytes=`$TWIDDLE_CMD_GET $SERVER_INFO_MBEAN MaxMemory | cut -d '=' -f 2`
   MaxMemInMB=`echo "($MaxMemInBytes/1024/1024)" | bc`
   echo "      |--- MaxMemory = $MaxMemInMB MB"

   FreeMemInBytes=`$TWIDDLE_CMD_GET $SERVER_INFO_MBEAN FreeMemory | cut -d '=' -f 2`
   FreeMemInMB=`echo "($FreeMemInBytes/1024/1024)" | bc`
   echo "      |--- FreeMemory = $FreeMemInMB MB"

   #HTTP ThreadPool
   echo " "
   echo "   JBossWEB "
   echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_THREADPOOL_MBEAN maxThreads)" | egrep -v "ERROR|at |Exception"
   echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_THREADPOOL_MBEAN currentThreadCount)" | egrep -v "ERROR|at |Exception"
   echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_THREADPOOL_MBEAN currentThreadsBusy)" | egrep -v "ERROR|at |Exception"

   #HTTP GlobalRequestProcessor
   echo "      |--- $($TWIDDLE_CMD_GET $JBOSS_WEB_GLOBAL_REQUEST_PROCESSOR_MBEAN requestCount)" | egrep -v "ERROR|at |Exception"

   #WebApps 
   echo "      |--- Webapps "
       
   for WEB_APP in `$TWIDDLE_CMD_QRY $JBOSS_WEB_DEPLOYMENTS_MBEAN | cut -d '=' -f 2 | grep -v 'ROOT'`
   do
      echo "      |------ $WEB_APP"
      echo "      |---------> $($TWIDDLE_CMD_GET "${WEB_APP_MBEAN}${WEB_APP},host=localhost" activeSessions)" | egrep -v "ERROR|at |Exception"
   done

   echo " "

   #DataSources
   echo "   Data Sources "
       
   for DS in `$TWIDDLE_CMD_QRY $JBOSS_JCA_MBEAN | grep ManagedConnectionPool`
   do
      echo "      |--- `echo $DS | cut -d ',' -f 2`"
      echo "      |---------> $($TWIDDLE_CMD_GET $DS MaxSize)" | egrep -v "ERROR|at |Exception"
      echo "      |---------> $($TWIDDLE_CMD_GET $DS AvailableConnectionCount)" | egrep -v "ERROR|at |Exception"
      echo "      |---------> $($TWIDDLE_CMD_GET $DS InUseConnectionCount)" | egrep -v "ERROR|at |Exception"
      echo "      |---------> Test Connection: $($TWIDDLE_CMD_IVK $DS testConnection)" | egrep -v "ERROR|at |Exception"
   done
}

function cleanWorkTmp()
{
   # clean tmp and work dirs
   echo "clean work and tmp dirs from ${JBOSS_PROFILE}..."

   rm -Rf "$JBOSS_HOME/server/${JBOSS_PROFILE}/work"
   rm -Rf "$JBOSS_HOME/server/${JBOSS_PROFILE}/tmp"
}

function jbossPID()
{
   # try get the JVM PID
   local jbossPID="x"
   jbossPID=$(ps -eo pid,cmd | grep "org.jboss.Main" | grep "${JBOSS_BIND_ADDR} " | grep "${JBOSS_PROFILE}" | grep -v grep | cut -c1-6)
   echo "$jbossPID"
}

case "$1" in
start)
   cd $JBOSS_HOME/bin

   # verifica se a instancia jah estah em execucao
   PID=$(jbossPID)
   if [ "x$PID" = "x" ]
   then
      echo "starting JBoss (instance $JBOSS_PROFILE at $JBOSS_BIND_ADDR)..."
      echo "   using service bind: $JBOSS_SERVICE_BIND"

      #echo "JBOSS_CMD_START=$JBOSS_CMD_START"

      if [ -z "$SUBIT" ]; then
         eval $JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &
      else
         $SUBIT "$JBOSS_CMD_START >${JBOSS_CONSOLE} 2>&1 &" 
      fi
   else
      echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BIND_ADDR) is already running [PID $PID]"
   fi
   ;;
stop)
   echo "stop JBoss (instance $JBOSS_PROFILE at $JBOSS_BIND_ADDR)..."

   if [ -z "$SUBIT" ]; then
       $JBOSS_CMD_STOP
   else
       #echo "CMD: $JBOSS_CMD_STOP"
       $SUBIT "$JBOSS_CMD_STOP"
   fi 

   sleep 10

   if [ "$CLEAR_WORK_TMP" = "Y" ]; then
      cleanWorkTmp
   fi

   ;;
kill)
   echo "trying halt the JVM process..."

   # try get the JVM PID
   PID=$(jbossPID)
   if [ "x$PID" = "x" ]
   then
      echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BIND_ADDR) not runing! JVM process not found!"
   else
      echo "process still running..."
      echo "killing JBoss (JVM process) [PID $PID]"
      kill -9 $PID
   fi

   if [ "$CLEAR_WORK_TMP" = "Y" ]; then
      cleanWorkTmp
   fi

   ;;
restart)
   $0 stop
   $0 start
   ;;
status)
   clear

   # try get the JVM PID
   PID=$(jbossPID)
   if [ "x$PID" = "x" ]
   then
      echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BIND_ADDR) not runing! JVM process not found!"
   else
      echo " "
      echo "JBoss (instance $JBOSS_PROFILE at $JBOSS_BIND_ADDR) runing!"
      echo "   JBoss (JVM process) [PID $PID] is UP"
      echo " "
      echo "   Some server status:"

      twiddleStatus
   fi
   ;;
*)
   echo "usage: $0 start|stop|restart|kill|status"
esac

