#!/bin/bash

# JBoss EAP 5.x Sliming Script
#
# Refs:
#    https://access.redhat.com/knowledge/techbriefs/jboss-eap-slimming-guide
#    https://access.redhat.com/kb/docs/DOC-36442
#    https://community.jboss.org/wiki/JBoss5xTuningSlimming
#
# Authors: 
#    rsoares at redhat dot com
#    joao.viragine at redhat dot com
#
# version: 1.3

DATA=$(date  +%Y%m%d-%H%M)
clear

# Checking JBOSS_HOME
if [ ! -d "$1" ] || [ ! -f "$2" ]; then
    echo "ERROR!"
    echo "[USAGE]: ./slimmingEAP5.sh <JBOSS_HOME> <SLIMMED_CONF>"	
    exit 1
 else
    JBOSS_HOME=$1
    SLIMMED_CONF=$2
fi

# Checking SLIMMED_CONF
if [ ! -r "$SLIMMED_CONF" ]; then
    echo "Slimming configuration file doesn't exists!"
    echo "Please, create a file named slimming.conf with slimming configuration."	
    exit 1   
 else
    . "$SLIMMED_CONF"
fi

# create a log file
SLIM_LOG_FILE="eap_${BASE_PROFILE_NAME}_${DATA}.out"
touch $SLIM_LOG_FILE

rejectFileOrDirectory()
{
    echo  "Rejecting $1" >> $SLIM_LOG_FILE
    if [ -a "$1" ]; then
	mv "$1" "$1".rej
    else
	echo "$1 doesn't exists!" >> $SLIM_LOG_FILE
    fi
}

printLineSeparator()
{
   echo "--------------------------------------------------------------------------------" >> $SLIM_LOG_FILE
}

#---------------------------------------------------------------------------------------------------------------------#
# Creating slimmed profile from default profile
echo "Creating slimmed profile named [${SLIMMED_PROFILE_NAME}] from [${BASE_PROFILE_NAME}] profile in ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/."
echo "Creating slimmed profile named [${SLIMMED_PROFILE_NAME}] from [${BASE_PROFILE_NAME}] profile in ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/." >> $SLIM_LOG_FILE
echo "See log output in $SLIM_LOG_FILE file."

if [ -d ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME} ]; then
	mv ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME} ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}-bkp-$DATA
fi

cp -r ${JBOSS_HOME}/server/${BASE_PROFILE_NAME}/ ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/

# Removing EJB 2
if [ $REMOVE_EJB_2 = "Y" ]; then
printLineSeparator
echo "Removing EJB 2:" >> $SLIM_LOG_FILE
echo "   Services to support Enterprise Java Beans 2.x (EJB2)" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/ejb2-container-jboss-beans.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/ejb2-timer-service.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/ejb-deployer-jboss-beans.xml
fi

# Removing EJB 3
if [ $REMOVE_EJB_3 = "Y" ]; then
printLineSeparator
echo "Removing EJB 3:" >> $SLIM_LOG_FILE
echo "   Services to support Enterprise Java Beans 3.0 (EJB3)" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-connectors-jboss-beans.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-container-jboss-beans.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-interceptors-aop.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-timerservice-jboss-beans.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/quartz-ra.rar
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/ejb3.deployer
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/ejb3-deployers-jboss-beans.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/jboss-ejb3-endpoint-deployer.jar
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/jboss-ejb3-metrics-deployer.jar
fi

# Removing Hypersonic DB
if [ $REMOVE_Hypersonic_DB = "Y" ]; then
printLineSeparator
echo "Removing Hypersonic DB:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/hsqldb-ds.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/messaging/hsqldb-persistence-service.xml
rejectFileOrDirectory ${JBOSS_HOME}/common/lib/hsqldb.jar
fi

# Removing JBoss Messaging
if [ $REMOVE_JBoss_Messaging = "Y" ]; then
printLineSeparator
echo "Removing JBoss Messaging:" >> $SLIM_LOG_FILE
echo "   Services to support Java Messaging Service (JMS)" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/messaging
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/jms-ra.rar
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/messaging-definitions-jboss-beans.xml
echo "   Editing conf/jbossts-properties.xml to comment the snippet:" >> $SLIM_LOG_FILE
echo "      <!--property name=\"com.arjuna.ats.jta.recovery.XAResourceRecovery.JBMESSAGING1 value=\"org.jboss.jms.server.recovery.MessagingXAResourceRecovery;java:/DefaultJMSProvider\"/-->" >> $SLIM_LOG_FILE

sed -i.bak -e 's/<\(.*.JBMESSAGING1.*.\)/<!-- \1/g' -e 's/\(.*DefaultJMSProvider\"\/\)>/\1 -->/g' ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/conf/jbossts-properties.xml
fi

# Removing JBoss WS
if [ $REMOVE_JBoss_WS = "Y" ]; then
printLineSeparator
echo "Removing JBoss WS:" >> $SLIM_LOG_FILE
echo "   Services to support SOAP/WSDL web services via the JbossWebServices stack" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/jbossws.sar
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/jbossws.deployer
fi

# Removing UUID Key Generator
if [ $REMOVE_UUID_Key_Generator = "Y" ]; then
printLineSeparator
echo "Removing UUID Key Generator:" >> $SLIM_LOG_FILE
echo "   Services for generating Universally Unique Identifiers (UUIDs)" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/uuid-key-generator.sar
fi

# Removing JBoss Mail
if [ $REMOVE_JBoss_Mail = "Y" ]; then
printLineSeparator
echo "Removing JBoss Mail:" >> $SLIM_LOG_FILE
echo "   Services for supporting the Simple Mail Transport Protocol (SMTP) and the Post Office Protocol (POP)" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/mail-ra.rar
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/mail-service.xml
fi

# Removing Scheduling
if [ $REMOVE_Scheduling = "Y" ]; then
printLineSeparator
echo "Removing Scheduling:" >> $SLIM_LOG_FILE
echo "   Services to support scheduling of JMX-based services" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/schedule-manager-service.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/scheduler-service.xml
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/quartz-ra.rar
fi

# Removing BeanShell
if [ $REMOVE_BeanShell = "Y" ]; then
printLineSeparator
echo "Removing BeanShell:" >> $SLIM_LOG_FILE
echo "   Services for deploying BeanShell scripting" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/bsh.deployer
fi

# Removing Hot deployment
if [ $REMOVE_Hot_deployment = "Y" ]; then
printLineSeparator
echo "Removing Hot deployment" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/hdscanner-jboss-beans.xml
fi

# Removing JMX Console
if [ $REMOVE_JMX_Console = "Y" ]; then
printLineSeparator
echo "Removing JMX Console:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/jmx-console.war
fi

# Removing Web Console
if [ $REMOVE_Web_Console = "Y" ]; then
printLineSeparator
echo "Removing Web Console:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/management
fi

# Removing Admin Console
if [ $REMOVE_Admin_Console = "Y" ]; then
printLineSeparator
echo "Removing Admin Console:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/admin-console.war
fi

# Removing Seam
if [ $REMOVE_Seam = "Y" ]; then
printLineSeparator
echo "Removing Seam:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/seam.deployer
fi

# Removing xnio
if [ $REMOVE_xnio = "Y" ]; then
printLineSeparator
echo "Removing xnio:" >> $SLIM_LOG_FILE
echo "   Services for supporting a simplified low-level I/O layer which can be used anywhere you are using NIO today" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/xnio-provider.jar
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/xnio.deployer
fi

# Removing XA datasources
if [ $REMOVE_XA_datasources = "Y" ]; then
printLineSeparator
echo "Removing XA datasources:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/jboss-xa-jdbc.rar
fi

# Removing remote (RMI) acces to JMX
if [ $REMOVE_remote_RMI_acces_to_JMX = "Y" ]; then
printLineSeparator
echo "Removing remote (RMI) acces to JMX:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/jmx-invoker-service.xml
fi

# Removing SQLException
if [ $REMOVE_SQLException = "Y" ]; then
printLineSeparator
echo "Removing SQLException:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/sqlexception-service.xml
fi

# Removing HTTP invoker
if [ $REMOVE_HTTP_invoker = "Y" ]; then
printLineSeparator
echo "Removing HTTP invoker:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/http-invoker.sar
fi

# Removing ROOT WebApp
if [ $REMOVE_ROOT_WebApp = "Y" ]; then
printLineSeparator
echo "Removing ROOT WebApp:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/ROOT.war
fi

# Removing Monitoring Service
if [ $REMOVE_Monitoring_Service = "Y" ]; then
printLineSeparator
echo "Removing Monitoring Service:" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/monitoring-service.xml
fi

# Removing SNMP Adaptor
if [ $REMOVE_SNMP_ADAPTOR = "Y" ]; then
printLineSeparator
echo "Removing SNMP Adaptor:" >> $SLIM_LOG_FILE
echo "   Services for supporting the Simple Network Management Protocol (SNMP)" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/snmp-adaptor.sar
fi

# Removing Properties Service
if [ $REMOVE_Properties_Service = "Y" ]; then
printLineSeparator
echo "Removing Properties Service:" >> $SLIM_LOG_FILE
echo "   Services for defining and overriding properties used by other services" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/properties-service.xml
fi

# Removing JSR-88 Service
if [ $REMOVE_JSR88_Service = "Y" ]; then
printLineSeparator
echo "Removing JSR-88 Service:" >> $SLIM_LOG_FILE
echo "   Services for supporting this specification that defines standard APIs " >> $SLIM_LOG_FILE
echo "   that will enable any deployment tool that uses the deployment APIs to deploy " >> $SLIM_LOG_FILE
echo "   any assembled application onto a J2EE compatible platform." >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/jsr88-service.xml
fi

# Removing JBoss Web container
if [ $REMOVE_JBossWEB = "Y" ]; then
printLineSeparator
echo "Removing JBoss Web container:" >> $SLIM_LOG_FILE
echo "   Services for supporting web applications" >> $SLIM_LOG_FILE
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deploy/jbossweb.sar
rejectFileOrDirectory ${JBOSS_HOME}/server/${SLIMMED_PROFILE_NAME}/deployers/jbossweb.deployer
fi
