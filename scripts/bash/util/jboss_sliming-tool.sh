#!/bin/sh

#
# Created by Bram Biesbrouck <b@beligum.org>
#
# Disclaimer: I was tired when I wrote this; you can't hold me responsible for it.
#
#
# Auto-slims a JBoss configuration, to turn a default config
# into a production config by asking a few questions.
# When you're uncertain, follow the hint.
#
# 
#

########################################
####FILL OUT THESE VARIABLES FIRST######
########################################

JBOSS_HOME=/java/servers/jboss

########################################
########################################
########################################

if [ "${JBOSS_HOME}" == "" ]; then
    echo "Please adapt this script file with your own jboss-home-path"
    exit 1
fi
if [ ! -d "${JBOSS_HOME}" ]; then
    echo "You specified a jboss-home-path that doesn't exist, change this script's header first !"
    exit 1
fi

function processYNanswer()
{
    read answer

    if [ "$answer" == "y" ] || [ "$answer" == "Y" ] || [ "$answer" == "yes" ]; then
	return 1;
    fi

    if [ "$answer" == "n" ] || [ "$answer" == "N" ] || [ "$answer" == "no" ]; then
	return 0;
    fi

    echo "Unsupported answer (y/n), please try again:"
    processYNanswer
}

#echo -e -n "I'll make a backup of your original jboss_home to ${BACKUP_DIR} \nPress any key to continue... "
#read
#cp -r ${JBOSS_HOME} ${BACKUP_DIR}
#echo "done."


if [ -d "${JBOSS_HOME}/server/slim" ]; then
    echo "WARNING: a slim configuration exists, hit enter to continue, Ctrl-c to abort."
    read
fi

echo -n "Okay, let's get started with creating a 'slim' configuration... "

rm -rf "${JBOSS_HOME}/server/slim"
cp -r "${JBOSS_HOME}/server/default" "${JBOSS_HOME}/server/slim"
rm -rf "${JBOSS_HOME}/server/slim/work"
rm -rf "${JBOSS_HOME}/server/slim/log"
rm -rf "${JBOSS_HOME}/server/slim/tmp"
rm -rf "${JBOSS_HOME}/server/slim/data"
echo "done."


echo -e "\nYou want to remove web services (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -d "${JBOSS_HOME}/server/slim/deploy/jbossws.sar" ]; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/jbossws.sar"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove Quartz (hint:n)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -f "${JBOSS_HOME}/server/slim/deploy/quartz-ra.rar" ] && [ -f "${JBOSS_HOME}/server/slim/lib/quartz.jar" ]; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/quartz-ra.rar"
	rm -rf "${JBOSS_HOME}/server/slim/lib/quartz.jar"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove JBossMQ(JMS) (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -d "${JBOSS_HOME}/server/slim/deploy/jms" ] && [ -f "${JBOSS_HOME}/server/slim/lib/jbossmq.jar" ]; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/jms"
	rm -rf "${JBOSS_HOME}/server/slim/lib/jbossmq.jar"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove HTTPInvoker (which lets you tunnel RMI over HTTP) (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -d "${JBOSS_HOME}/server/slim/deploy/http-invoker.sar" ]; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/http-invoker.sar"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove BeanShell Deployer (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -f "${JBOSS_HOME}/server/slim/deploy/bsh-deployer.xml" ] && [ -f "${JBOSS_HOME}/server/slim/lib/bsh-deployer.jar" ] && [ -f "${JBOSS_HOME}/server/slim/lib/bsh.jar" ]; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/bsh-deployer.xml"
	rm -rf "${JBOSS_HOME}/server/slim/lib/bsh-deployer.jar"
	rm -rf "${JBOSS_HOME}/server/slim/lib/bsh.jar"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove Hypersonic (watch out if you use JMS !) (hint:n)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -f "${JBOSS_HOME}/server/slim/deploy/hsqldb-ds.xml" ] && [ -f "${JBOSS_HOME}/server/slim/lib/hsqldb-plugin.jar" ] && [ -f "${JBOSS_HOME}/server/slim/lib/hsqldb.jar" ]; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/hsqldb-ds.xml"
	rm -rf "${JBOSS_HOME}/server/slim/lib/hsqldb-plugin.jar"
	rm -rf "${JBOSS_HOME}/server/slim/lib/hsqldb.jar"
	echo "done."
    else
	echo "ERROR!"
    fi
fi


echo -e "\nYou want to remove the JMX-Console (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -d "${JBOSS_HOME}/server/slim/deploy/jmx-console.war" ]; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/jmx-console.war"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove both the management web-console and jsr-77 extensions (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -d "${JBOSS_HOME}/server/slim/deploy/management" ] ; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/management"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove the tomcat status pages (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -d "${JBOSS_HOME}/server/slim/deploy/jboss-web.deployer/ROOT.war" ] ; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/jboss-web.deployer/ROOT.war"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove the example scheduler-service.xml (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -f "${JBOSS_HOME}/server/slim/deploy/scheduler-service.xml" ] ; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/scheduler-service.xml"
	echo "done."
    else
	echo "ERROR!"
    fi
fi

echo -e "\nYou want to remove JBoss Scheduler Manager (allows you to schedule invocations against MBeans) (hint:y)?"
processYNanswer
if [ $? -eq 1 ]; then
    echo -n "Removing... "
    if [ -f "${JBOSS_HOME}/server/slim/deploy/schedule-manager-service.xml" ] && [ -f "${JBOSS_HOME}/server/slim/lib/scheduler-plugin.jar" ] && [ -f "${JBOSS_HOME}/server/slim/lib/scheduler-plugin-example.jar" ] ; then
	rm -rf "${JBOSS_HOME}/server/slim/deploy/schedule-manager-service.xml"
	rm -rf "${JBOSS_HOME}/server/slim/lib/scheduler-plugin.jar"
	rm -rf "${JBOSS_HOME}/server/slim/lib/scheduler-plugin-example.jar"
	echo "done."
    else
	echo "ERROR!"
    fi
fi
