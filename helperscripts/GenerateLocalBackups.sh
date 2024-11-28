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
elif ( [ "${response}" = "2" ] )
then
        CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
        CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
        CLOUDHOST="vultr"
else
        /bin/echo "Unrecognised  cloudhost. Exiting ...."
        exit
fi

/bin/echo "What is the build Identifer for your build?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
        export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN`"
fi

token_to_match="ws-`/bin/grep 'REGION=' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /usr/bin/awk -F'=' '{print $NF}'`-${BUILD_IDENTIFIER}"
/bin/echo "${BUILD_IDENTIFIER}" > ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
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

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSER`"
SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSERPASSWORD`"
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

/usr/bin/ssh-keygen -f "${HOME}/.ssh/known_hosts" -R [${WEB_IP}]:${SSH_PORT} 2>/dev/null

timestamp="`/usr/bin/date | sed 's/ //g'`"

if ( [ ! -d ${BUILD_HOME}/localbackups/${timestamp} ] )
then
        /bin/mkdir -p ${BUILD_HOME}/localbackups/${timestamp}
fi

WEBSERVER_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/webserver_${WEB_IP}-keys"

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
                /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/application/processing/BundleSourcecodeByApplication.sh \"/var/www/html\""
                /usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP}:/tmp/*-applicationsourcecode.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/
elif ( [ "${response}" = "2" ] )
then
                /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/application/processing/BundleSourcecodeByApplication.sh \"/var/www/html\""
                /usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS}l -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${WEB_IP}:/tmp/*-applicationsourcecode.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/
        else
                /bin/echo "Unrecognised selection, please select only 1 or 2"
        fi
fi

/bin/echo "##############################################################################################"
/bin/echo "The next phase is the processing of your database archive"
/bin/echo "Please tell me the name of the database user that this you took this database dump from, for example, database_username"
read DB_U
/bin/echo "##############################################################################################"
/bin/echo "Press <enter> to begin the processing"
read x


token_to_match="db-`/bin/grep 'REGION=' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /usr/bin/awk -F'=' '{print $NF}'`-${BUILD_IDENTIFIER}"

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
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

DATABASE_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/database_${DB_IP}keys"

if ( [ ! -f ${DATABASE_PUBLIC_KEYS} ] )
then
        /usr/bin/ssh-keyscan  -p ${SSH_PORT} ${DB_IP} > ${DATABASE_PUBLIC_KEYS}    
        if ( [ "`/bin/cat ${DATABASE_PUBLIC_KEYS}`" = "" ] )
        then
                /usr/bin/ssh-keyscan ${DB_IP} > ${DATABASE_PUBLIC_KEYS}    
        fi
else
        /bin/echo "#####################################################################################################################################################################"
        /bin/echo "Do you want to initiate a fresh ssh key scan (might be necessary if you can't connect) or  do you want to use previously generated keys"
        /bin/echo "You should always use previously generated keys unless you can't connect (an previously used ip address might have been reallocated as part of scaling or redeployment"
        /bin/echo "#####################################################################################################################################################################"
        /bin/echo "Enter 'Y' to regenerate your SSH public keys anything else to keep the keys you have got. You should only need to regenerate the keys very occassionally if at all"    
        read response1
        if ( [ "${response1}" = "Y" ] || [ "${response1}" = "y" ] )
        then
                /usr/bin/ssh-keyscan  -p ${SSH_PORT} ${DB_IP} > ${DATABASE_PUBLIC_KEYS}
        fi
fi

if ( [ "`/bin/cat ${DATABASE_PUBLIC_KEYS}`" = "" ] )
then
        /bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online"
        /bin/rm ${DATABASE_PUBLIC_KEYS}
        exit
fi

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"

if ( [ -f ${BUILD_HOME}/localbackups/applicationwebroot.tar.gz ] && [ -f ${BUILD_HOME}/localbackups/applicationdb.tar.gz ] )
then
        /bin/cp ${BUILD_HOME}/localbackups/applicationwebroot.tar.gz ${BUILD_HOME}/localbackups/timestamp/migration-applicationsourcecode.tar.gz
        /bin/cp ${BUILD_HOME}/localbackups/applicationdb.tar.gz ${BUILD_HOME}/localbackups/timestamp/migration-database.tar.gz
else
        if ( [ "${response}" = "1" ] )
        then
                /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/git/utilities/BackupDatabase.sh"
                /usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}:/tmp/*-database.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/
        elif ( [ "${response}" = "2" ] )
        then
                /usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/git/utilities/BackupDatabase.sh"
                /usr/bin/scp -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP}:/tmp/*-database.tar.gz ${BUILD_HOME}/localbackups/${timestamp}/database.tar.gz
        else
                /bin/echo "Unrecognised selection, please select only 1 or 2"
        fi
fi

/bin/echo "###################################################################################################"
/bin/echo "Thank you, your application webroot and database dump should now be available at: ${BUILD_HOME}/localbackups/${timestamp}/"
/bin/echo "To use these for an Agile Deployment Toolkit build, create baselined repositories from them"
/bin/echo "You can then deploy these applications using the Agile Deployment Toolkit and if you have migrated from another hosting solution you will be good to go"
/bin/echo "###################################################################################################"
