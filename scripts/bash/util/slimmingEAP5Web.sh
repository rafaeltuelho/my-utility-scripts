#!/bin/bash

# https://community.jboss.org/wiki/JBoss5xTuningSlimming
# https://access.redhat.com/kb/docs/DOC-36442

# Checking JBOSS_HOME
if [ ! -d "$1" ]; then
    echo "JBOSS_HOME specified doesn't exists!"
    echo "[USAGE]: ./slimmingEAP5Web.sh <JBOSS_HOME>"	
    exit 1
 else
    JBOSS_HOME=$1
fi

rejectFileOrDirectory()
{
    echo  "Rejecting $1"
    if [ -a "$1" ]; then
	mv "$1" "$1".rej
    else
	echo "$1 doesn't exists!"
    fi
}

BASE_PROFILE_NAME=default
SLIMMED_PROFILE_NAME=slimmed

# Creating slimmed profile from default profile
echo "Creating slimmed profile named [${SLIMMED_PROFILE_NAME}] from [${BASE_PROFILE_NAME}] profile in ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/."
rm -rf ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/
cp -r ${JBOSS_HOME}/jboss-as/server/${BASE_PROFILE_NAME}/ ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/

# Removing EJB 2
echo "Removing EJB 2"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/ejb2-container-jboss-beans.xml
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/ejb2-timer-service.xml

# Removing EJB 3
#echo "Removing EJB 3"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-connectors-jboss-beans.xml
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-container-jboss-beans.xml
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-interceptors-aop.xml
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/ejb3-timerservice-jboss-beans.xml
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/profile-service-secured.jar
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deployers/jboss-ejb3-endpoint-deployer.jar


# Removing JBoss Messaging
echo "Removing JBoss Messaging"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/messaging
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/jms-ra.rar
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deployers/messaging-definitions-jboss-beans.xml

# Removing JBoss WS
echo "Removing JBoss WS"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/jbossws.sar
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deployers/jbossws.deployer

# Removing jUDDI Key Generator
#echo "Removing jUDDI Key Generator"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/juddi-service.sar
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/uuid-key-generator.sar

# Removing JBoss Mail
echo "Removing JBoss Mail"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/mail-ra.rar
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/mail-service.xml

# Removing Scheduling
echo "Removing Scheduling"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/schedule-manager-service.xml
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/scheduler-service.xml
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/quartz-ra.rar

# Removing Hypersonic DB
#echo "Removing Hypersonic DB"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/hsqldb-ds.xml
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/messaging/hsqldb-persistence-service.xml
#rejectFileOrDirectory ${JBOSS_HOME}/common/lib/hsqldb.jar

# Removing BeanShell
echo "Removing BeanShell"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deployers/bsh.deployer

# Removing Hot deployment
#echo "Removing Hot deployment"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/hdscanner-jboss-beans.xml

# Removing JMX Console
#echo "Removing JMX Console"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/jmx-console.war

# Removing Web Console
echo "Removing Web Console"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/management

# Removing Admin Console
echo "Removing Admin Console"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/admin-console.war

# Removing Seam
echo "Removing Seam"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deployers/seam.deployer

# Removing xnio
#echo "Removing xnio"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/xnio-provider.jar

# Removing XA datasources
#echo "Removing XA datasources"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/jboss-xa-jdbc.rar

# Removing remote (RMI) acces to JMX
#echo "Removing remote (RMI) acces to JMX"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/jmx-remoting.sar

# Removing SQLException
#echo "Removing SQLException"
#rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/sqlexception-service.xml

# Removing HTTP invoker
echo "Removing HTTP invoker"
rejectFileOrDirectory ${JBOSS_HOME}/jboss-as/server/${SLIMMED_PROFILE_NAME}/deploy/http-invoker.sar




