#!/bin/sh

export JBOSS_HOME="/home/rsoares/opt/jboss-eap-5.1/jboss-as"
export JAVA_HOME="/opt/jdk"
CLASSPATH="${JBOSS_HOME}/client/jboss-messaging-client.jar"

echo ${CLASSPATH}

echo "JBM password to crypt :"
read PASSWD

ENCRYPT_PASSWD=`${JAVA_HOME}/bin/java -cp ${CLASSPATH} org.jboss.messaging.util.SecurityUtil ${PASSWD}`
echo "Crypted password to cut/paste in your JBM configuration files :"
echo ${ENCRYPT_PASSWD}
