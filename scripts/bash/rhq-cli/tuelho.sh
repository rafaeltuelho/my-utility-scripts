#!/bin/bash
#
# groupcontrol
# ------------
# This is a simple wrapper script for all the java script scripts in this folder.
# Start this script with some parameters to automate group handling from within the
# command line.
# 
# With groupcontrol you can do the following:
#   deploy: Deploys an application to all AS instances specified by group name
#   create: Create a new group
#   delete: Delete an existing group
#   start : start all EAP instances specified by group name
#   stop  : stop all EAP instances specified by group name
#   add   : Add a new EAP instance to the specified group
#   remove: Remove an existing EAP instance from the specified group
#   status: Print the status of all resources of a group
#
# 

# clean the screen
clear
			
## Should not be run as root.
if [ "$EUID" = "0" ]; then
   echo " Please use a normal user account and not the root account"
   exit 1
fi
		
## Figure out script home
#MY_HOME=$(cd `dirname $0` && pwd)
MY_HOME="/home/rsoares"
SCRIPT_HOME="$MY_HOME/opt/rhq-cli/scripts"
JON_CLI_HOME="$MY_HOME/opt/rhq-cli"
JON_HOST="rsoares"
JON_USER="rhqadmin"
JON_PWD="rhqadmin"
JON_PORT="7080"
			
## Source some defaults
#. $MY_HOME/groupcontrol.conf
			
## Check to see if we have a valid CLI home
if [ ! -d ${JON_CLI_HOME} ]; then
     echo "JON_CLI_HOME not correctly set. Please do so in the file"
     echo $MY_HOME/groupcontrol.conf
     exit 1
fi
			
RHQ_OPTS="-s $JON_HOST -u $JON_USER -t $JON_PORT"
# If JBoss ON_PWD is given then use it as argument. Else let the user enter the password
if [ "x$JON_PWD" == "x" ]; then
     RHQ_OPTS="$RHQ_OPTS -P"
else
     RHQ_OPTS="$RHQ_OPTS -p $JON_PWD"
fi
			
#echo "Calling groupcontrol with $RHQ_OPTS"
			
usage() {
     echo "  Usage $0:"
     echo "  Use this tool to control most group related tasks with a simple script."
     echo "  ------------------------------------------------------------------------- "
}
			
doDeploy() {

     echo " "
     echo -n "Informe nome do Grupo de JBossEAP Servers: "
     read GROUPNAME

     echo " "
     echo " Tipo de pacote"
     select OPT in "WAR" "EAR"; do
        echo -n "Informe o caminho e o nome do arquivo para deploy: "
        read FILENAME

        PKG_NAME=`basename $FILENAME`
        
        if [ ! -e $FILENAME ]; then
           echo "O arquivo informado [$FILENAME] não existe. Favor verificar!"
           exit 1
        fi
      
        echo -n "Informe a versão do pacote [1.0.0] "
        read VERSION
        
        echo -n "Informe o dir. de deploy do pacote [deploy/] "
        read DEPLOY_DIR

        $JON_CLI_HOME/bin/rhq-cli.sh \
            $RHQ_OPTS --args-style=named -f \
            $SCRIPT_HOME/JBossGroupDeploy.js \
            operation="deploy" \
            groupName=$GROUPNAME \
            fileName=$FILENAME \
            appTypeName=$OPT \
            packageVersion=${VERSION:-"1.0.0"} \
            packageName=$PKG_NAME \
            deployDIR=${DEPLOY_DIR:-"."}
        break
     done

}

doReDeploy() {
     echo " "
     echo -n "Informe nome do Grupo de JBossEAP Servers: "
     read GROUPNAME

     echo " "
     echo -n "Informe o caminho e o nome do arquivo para deploy: "
     read FILENAME

     PKG_NAME=`basename $FILENAME`
     
     if [ ! -e $FILENAME ]; then
        echo "O arquivo informado [$FILENAME] não existe. Favor verificar!"
        exit 1
     fi
   
     $JON_CLI_HOME/bin/rhq-cli.sh \
         $RHQ_OPTS --args-style=named -f \
         $SCRIPT_HOME/JBossGroupDeploy.js \
         operation="redeploy" \
         groupName=$GROUPNAME \
         fileName=$FILENAME \
         packageName=$PKG_NAME \
}

doStop() {
     echo -n "Informe o nome do Grupo de JBossEAP Servers: "
     read RESPOSTA

     $JON_CLI_HOME/bin/rhq-cli.sh \
        $RHQ_OPTS --args-style=named -f \
        $SCRIPT_HOME/JBossGroupDeploy.js \
        operation="stop" \
        groupName=$RESPOSTA
}

doStart() {
     echo -n "Informe o nome do Grupo de JBossEAP Servers: "
     read RESPOSTA

     $JON_CLI_HOME/bin/rhq-cli.sh \
        $RHQ_OPTS --args-style=named -f \
        $SCRIPT_HOME/JBossGroupDeploy.js \
        operation="start" \
        groupName=$RESPOSTA
}

doStatus() {
     echo -n "Informe o nome do Grupo de JBossEAP Servers: "
     read RESPOSTA

     $JON_CLI_HOME/bin/rhq-cli.sh \
        $RHQ_OPTS --args-style=named -f \
        $SCRIPT_HOME/JBossGroupDeploy.js \
        operation="status" \
        groupName=$RESPOSTA
}
			
doGetGroups() {
     $JON_CLI_HOME/bin/rhq-cli.sh \
        $RHQ_OPTS --args-style=named -f \
        $SCRIPT_HOME/JBossGroupDeploy.js \
        operation="fetchGroups"
}

case "$1" in
'deploy')
	doDeploy $*
	;;     
'redeploy')
	doReDeploy $*
	;;     
'stop')
	doDeploy $*
	;;     
'start')
	doDeploy $*
	;;     
'status')
	doStatus $*
	;;     
'groups')
	doGetGroups $*
	;;     
*)
   usage $*
   ;;
