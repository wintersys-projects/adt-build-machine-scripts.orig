#!/bin/sh
######################################################################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will make a local copy of your webroot and database
####################################################################################################################################################### 
#To migrate from another provider, create a tar of your webroot at    ${BUILD_HOME}/localbackups/applicationwebroot.tar.gz 
#and a dump of your database in a file applicationDB.sql contained in   ${BUILD_HOME}/localbackups/applicationdb.tar.gz
# Before running this script
######################################################################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

WEB_IP=""
if ( [ ! -f  ./GenerateLocalBackups.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3)Linode 4)Vultr. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
	CLOUDHOST="digitalocean"
	token_to_match="webserver*"
elif ( [ "${response}" = "2" ] )
then
	CLOUDHOST="exoscale"
	token_to_match="webserver"
elif ( [ "${response}" = "3" ] )
then
	CLOUDHOST="linode"
	token_to_match="webserver*"
elif ( [ "${response}" = "4" ] )
then
	CLOUDHOST="vultr"
	token_to_match="webserver*"
else
	/bin/echo "Unrecognised  cloudhost. Exiting ...."
	exit
fi

/bin/echo "What is the build Identifer for your build?"
/bin/echo "You have these builds to choose from: "

if ( [ -d ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} ] )
then
        /bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
else
        /bin/echo "No eligible builds found"
        exit
fi

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

if ( [ -f ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
then
	ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
else
	ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
fi

if ( [ "${ips}" = "" ] )
then
	/bin/echo "There doesn't seem to be any webservers running"
	exit
fi

/bin/echo "Which webserver would you like to connect to?"
count=1
for ip in ${ips}
do
	/bin/echo "${count}:   ${ip}"
	/bin/echo "Press Y/N to connect..."
	read response
	if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
	then
		WEB_IP=${ip}
		break
	fi
	count="`/usr/bin/expr ${count} + 1`"
done

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "If you are not sure, please try one and then the other. If you are prompted for a password, it is the wrong one"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER`"
SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD`"
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

/usr/bin/ssh-keygen -f "${HOME}/.ssh/known_hosts" -R [${WEB_IP}]:${SSH_PORT} 2>/dev/null

timestamp="`/usr/bin/date | sed 's/ //g'`"

if ( [ ! -d ${BUILD_HOME}/localbackups/${timestamp} ] )
then
	/bin/mkdir -p ${BUILD_HOME}/localbackups/${timestamp}
fi

WEBSERVER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_${WEB_IP}-keys"

if ( [ ! -f ${WEBSERVER_PUBLIC_KEYS} ] )
then
	/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${WEB_IP} > ${WEBSERVER_PUBLIC_KEYS}    
fi

if ( [ "`/bin/cat ${WEBSERVER_PUBLIC_KEYS}`" = "" ] )
then
	/bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online"
	/bin/rm ${WEBSERVER_PUBLIC_KEYS}
	exit
else
	/bin/echo "Do you want to initiate a fresh ssh key scan (might be necessary if you can't connect) or  do you want to use previously generated keys"
	/bin/echo "You should always use previously generated keys unless you can't connect (an previously used ip address might have been reallocated as part of scaling or redeployment"
	/bin/echo "Enter 'Y' to regenerate keys anything else to keep the keys you have got. You should only need to regenerate the keys very occassionally if at all"    
	read response1
	if ( [ "${response1}" = "Y" ] || [ "${response1}" = "y" ] )
	then
		/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${WEB_IP} > ${WEBSERVER_PUBLIC_KEYS}
	fi
fi

if ( [ -f ${BUILD_HOME}/localbackups/applicationwebroot.tar.gz ] && [ -f ${BUILD_HOME}/localbackups/applicationdb.tar.gz ] )
then
	/bin/cp ${BUILD_HOME}/localbackups/applicationwebroot.tar.gz ${BUILD_HOME}/localbackups/timestamp/migration-applicationsourcecode.tar.gz
	/bin/cp ${BUILD_HOME}/localbackups/applicationdb.tar.gz ${BUILD_HOME}/localbackups/timestamp/migration-database.tar.gz
else
	if ( [ "${response}" = "1" ] )
	then
		/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/application/processing/BundleSourcecodeByApplication.sh \"/var/www/html\""
		/usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP}:/tmp/*-applicationsourcecode.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/
elif ( [ "${response}" = "2" ] )
then
		/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/application/processing/BundleSourcecodeByApplication.sh \"/var/www/html\""
		/usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS}l -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP}:/tmp/*-applicationsourcecode.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/
	else
		/bin/echo "Unrecognised selection, please select only 1 or 2"
	fi
fi

/bin/mkdir /tmp/processing

/bin/rm -r /tmp/processing/*

if ( [ -f ${BUILD_HOME}/localbackups/${timestamp}/*-applicationsourcecode.tar.gz ] )
then
	/bin/echo "#######################################################################################"
	/bin/echo "I have obtained an archive of your webroot."

	/bin/echo "The next phase to make your the website usable by the Agile Deployment Toolkit is to remove its original branding"
	/bin/echo "I need some information from you"
	/bin/echo "Please tell me the following (making sure it is correct or things will go south)"
	/bin/echo "Please tell me the original website domain, for example, www.nuocial.org.uk"
	read WEBSITE_URL

	domainspecifier="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
	ROOT_DOMAIN="`/bin/echo ${WEBSITE_URL} | /usr/bin/cut -d"." -f2`" 
	/bin/echo "If you know your original website display name, for example, Nuocial"
	read WEBSITE_DISPLAY_NAME
	WEBSITE_DISPLAY_NAME_LOWER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/awk '{print tolower($0)}'`"
	WEBSITE_DISPLAY_NAME_UPPER="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /usr/bin/awk '{print toupper($0)}'`"
	WEBSITE_DISPLAY_NAME_FIRST="`/bin/echo ${WEBSITE_DISPLAY_NAME_LOWER} | /bin/sed -e 's/\b\(.\)/\u\1/g'`"
	/bin/echo "About to apply your settings to your the backup we obtained of your webroot"
	/bin/echo "#######################################################################################"
	/bin/echo "Press <enter> to give it the OK"
	read x

	/bin/tar xvfz ${BUILD_HOME}/localbackups/${timestamp}/*-applicationsourcecode.tar.gz -C /tmp/processing


	/bin/echo "Processsing....Please wait...."

	/usr/bin/find /tmp/processing/* -type f -exec sed -i -e "s/${domainspecifier}/ApplicationDomainSpec/g" -e "s/${WEBSITE_URL}/applicationdomainwww.tld/g" -e "s/${ROOT_DOMAIN}/applicationrootdomain.tld/g" -e "s/${WEBSITE_DISPLAY_NAME}/The GreatApplication/g" -e "s/${WEBSITE_DISPLAY_NAME_UPPER}/THE GREATAPPLICATION/g" -e "s/${WEBSITE_DISPLAY_NAME}/GreatApplication/g" -e "s/${WEBSITE_DISPLAY_NAME_UPPER}/GREATAPPLICATION/g" -e "s/${WEBSITE_DISPLAY_NAME_LOWER}/greatapplication/g" -e "s/${WEBSITE_DISPLAY_NAME_FIRST}/Greatapplication/g" {} \;

	application_name="`/bin/ls ${BUILD_HOME}/localbackups/${timestamp}/*-applicationsourcecode.tar.gz | /usr/bin/awk -F'/' '{print $NF}' | /usr/bin/awk -F'-' '{print $1}'`"
	cd /tmp/processing
	/bin/tar cvfz ${BUILD_HOME}/localbackups/${timestamp}/${application_name}-applicationsourcecode.tar.gz *
fi

/bin/echo "##############################################################################################"
/bin/echo "The next phase is the processing of your database archive"
/bin/echo "Please tell me the name of the database user that this you took this database dump from, for example, database_username"
read DB_U
/bin/echo "##############################################################################################"
/bin/echo "Press <enter> to begin the processing"
read x


token_to_match="database"

if ( [ -f ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
then
	ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
else
	ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh ${token_to_match} ${CLOUDHOST} ${BUILD_HOME}`"
fi

if ( [ "${ips}" = "" ] )
then
	/bin/echo "There doesn't seem to be any databases running"
	exit
fi

DIR="`/bin/pwd`"

/bin/echo "Which Database server would you like to connect to?"
count=1
for ip in ${ips}
do
	/bin/echo "${count}:   ${ip}"
	/bin/echo "Press Y/N to connect..."
	read answer 
	if ( [ "${answer}" = "Y" ] || [ "${answer}" = "y" ] )
	then
		DB_IP=${ip}
		break
	fi
	count="`/usr/bin/expr ${count} + 1`"
done

if ( [ -f ${BUILD_HOME}/localbackups/applicationwebroot.tar.gz ] && [ -f ${BUILD_HOME}/localbackups/applicationdb.tar.gz ] )
then
	/bin/cp ${BUILD_HOME}/localbackups/applicationwebroot.tar.gz ${BUILD_HOME}/localbackups/timestamp/migration-applicationsourcecode.tar.gz
	/bin/cp ${BUILD_HOME}/localbackups/applicationdb.tar.gz ${BUILD_HOME}/localbackups/timestamp/migration-database.tar.gz
else
	if ( [ "${response}" = "1" ] )
	then
		/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/git/utilities/BackupDatabase.sh"
		/usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}:/tmp/*-database.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/
	elif ( [ "${response}" = "2" ] )
	then
		/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/git/utilities/BackupDatabase.sh"
		/usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}:/tmp/*-database.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/
	else
		/bin/echo "Unrecognised selection, please select only 1 or 2"
	fi
fi

/bin/tar xvfz ${BUILD_HOME}/localbackups/${timestamp}/*-database.tar.gz -C /tmp/processing
/bin/rm ${BUILD_HOME}/localbackups/${timestamp}/*-database.tar.gz 

/bin/sed -i "s/${domainspecifier}/ApplicationDomainSpec/g" /tmp/processing/app*sql
/bin/sed -i "s/${WEBSITE_URL}/www.applicationdomain.tld/g" /tmp/processing/app*sql
/bin/sed -i "s/@${ROOT_DOMAIN}/@applicationdomain.tld/g" /tmp/processing/app*sql
/bin/sed -i "s/${ROOT_DOMAIN}/applicationdomain.tld/g" /tmp/processing/app*sql
/bin/sed -i "s/${WEBSITE_DISPLAY_NAME}/GreatApplication/g" /tmp/processing/app*sql
/bin/sed -i "s/${WEBSITE_DISPLAY_NAME_UPPER}/GREATAPPLICATION/g" /tmp/processing/app*sql
/bin/sed -i "s/${WEBSITE_DISPLAY_NAME_LOWER}-online/application-online/g" /tmp/processing/app*sql
/bin/sed -i "s/${DB_U}/XXXXXXXXXX/g" /tmp/processing/app*sql
/bin/sed -i "s/@@mail/@mail/g" /tmp/processing/app*sql

cd /tmp/processing

/bin/tar cvfz ${BUILD_HOME}/localbackups/${timestamp}/${application_name}-database.tar.gz app*sql

cd ${BUILD_HOME}/helperscripts

/bin/rm -r /tmp/processing/*

/bin/echo "###################################################################################################"
/bin/echo "Thank you, your application webroot and database dump should now be available at: ${BUILD_HOME}/localbackups/${timestamp}/"
/bin/echo "To use these for an Agile Deployment Toolkit build, create baselined repositories from them"
/bin/echo "You can then deploy these applications using the Agile Deployment Toolkit and if you have migrated from another hosting solution you will be good to go"
/bin/echo "###################################################################################################"
