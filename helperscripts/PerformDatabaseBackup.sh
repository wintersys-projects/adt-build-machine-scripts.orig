#!/bin/sh
######################################################################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will connect you to your database(s) via ssh
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

if ( [ ! -f  ./PerformDatabaseBackup.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4)Vultr. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
	CLOUDHOST="digitalocean"
	token_to_match="database.*"
elif ( [ "${response}" = "2" ] )
then
	CLOUDHOST="exoscale"
	token_to_match="database"
elif ( [ "${response}" = "3" ] )
then
	CLOUDHOST="linode"
	token_to_match="database"
elif ( [ "${response}" = "4" ] )
then
	CLOUDHOST="vultr"
	token_to_match="database"
else
	/bin/echo "Unrecognised  cloudhost. Exiting ...."
	exit
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

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
	read response
	if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
	then
		DB_IP=${ip}
		break
	fi
	count="`/usr/bin/expr ${count} + 1`"
done


/bin/echo "Which periodicity of backup do you want to make, 1) HOURLY 2)DAILY 3) WEEKLY 4)MONTHLY 5)BIMONTHLY 6)MANUAL 7)ALL"
/bin/echo "Please enter one of 1,2,3,4,5,6,7"
read periodicity

while ( [ "`/bin/echo '1 2 3 4 5 6 7' | /bin/grep ${periodicity}`" = "" ] )
do
	/bin/echo "Sorry, that's not a valid selection, please try again"
	read periodicity
done

if ( [ "${periodicity}" = "1" ] )
then
	periodicity="HOURLY"
fi

if ( [ "${periodicity}" = "2" ] )
then
	periodicity="DAILY"
fi

if ( [ "${periodicity}" = "3" ] )
then
	periodicity="WEEKLY"
fi

if ( [ "${periodicity}" = "4" ] )
then
	periodicity="MONTHLY"
fi

if ( [ "${periodicity}" = "5" ] )
then
	periodicity="BIMONTHLY"
fi

if ( [ "${periodicity}" = "6" ] )
then
	periodicity="MANUAL"
	if ( [ ! -d ${BUILD_HOME}/manualbackups ] )
	then
		/bin/mkdir -p ${BUILD_HOME}/manualbackups/backup.$$
		/bin/mv ${BUILD_HOME}/manualbackups/* ${BUILD_HOME}/manualbackups/backup.$$
	fi
fi
if ( [ "${periodicity}" = "7" ] )
then
	periodicity="HOURLY DAILY WEEKLY MONTHLY BIMONTHLY"
fi

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSER`"
SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSERPASSWORD`"
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

DATABASE_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_${DB_IP}-keys"

if ( [ ! -f ${DATABASE_PUBLIC_KEYS} ] )
then
	/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${DB_IP} > ${DATABASE_PUBLIC_KEYS}    
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
	/bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online)"
	/bin/rm ${DATABASE_PUBLIC_KEYS}
	exit
fi

/bin/echo "Does your server use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

if ( [ "${response}" = "1" ] )
then
	/bin/echo ""
	/bin/echo "############################################"
	/bin/echo "Your git repository provider is set to:"
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'" 2>/dev/null
	/bin/echo "Your git repository username is set to:"
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'" 2>/dev/null
	/bin/echo "Your application identifier is set to:"
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'" 2>/dev/null
	/bin/echo "ARE YOU ABSOLUTELY SURE THIS IS CORRECT, UNPREDICTABLE THINGS WILL HAPPEN IF IT ISN'T"
	/bin/echo "PRESS THE ENTER KEY IF YOU ARE HAPPY"
	/bin/echo "#############################################"
	read x
	build_identifier="`/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'" 2>/dev/null`"
	/bin/echo "Build identifier is set to: ${build_identifier}"
	/bin/echo "OK, ready to create backup - press enter to confirm"
	read x
	for period in ${periodicity}
	do
		/bin/echo "Making database backup for ${period} backup"
		/bin/sleep 5
		/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/backupscripts/Backup.sh ${period} ${build_identifier}" 2>/dev/null
	done
	
	if ( [ "${periodicity}" = "MANUAL" ] )
	then
		/usr/bin/scp -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_rsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} "${SERVER_USERNAME}@${DB_IP}:/tmp/backup_archive/*.tar.gz" ${BUILD_HOME}/manualbackups
		/bin/echo"######################################################################"
		/bin/echo "BACKUP STORED IN ${BUILD_HOME}/manualbackups"
		/bin/echo "#####################################################################"
	fi
elif ( [ "${response}" = "2" ] )
then
	/bin/echo ""
	/bin/echo "############################################"
	/bin/echo "Your git repository provider is set to:"
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYPROVIDER'" 2>/dev/null
	/bin/echo "Your git repository username is set to:"
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONREPOSITORYUSERNAME'" 2>/dev/null
	/bin/echo "Your application identifier is set to:"
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'APPLICATIONIDENTIFIER'" 2>/dev/null
	/bin/echo "ARE YOU ABSOLUTELY SURE THIS IS CORRECT, UNPREDICTABLE THINGS WILL HAPPEN IF IT ISN'T"
	/bin/echo "PRESS THE ENTER KEY IF YOU ARE HAPPY"
	/bin/echo "#############################################"
	read x
	build_identifier="`/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/utilities/ExtractConfigValue.sh 'BUILDIDENTIFIER'" 2>/dev/null`"
	/bin/echo "Build identifier is set to: ${build_identifier}"
	/bin/echo "OK, ready to create backup - press enter to confirm"
	
	for period in ${periodicity}
	do
		/bin/echo "Making database backup for ${period} backup"
		/bin/sleep 5
		/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${DB_IP} "${SUDO} /home/${SERVER_USERNAME}/providerscripts/backupscripts/Backup.sh ${period} ${build_identifier}" 2>/dev/null
	done
	
	if ( [ "${periodicity}" = "MANUAL" ] )
	then
		/usr/bin/scp -o ConnectTimeout=5 -o ConnectionAttempts=2 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_ecdsa_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} "${SERVER_USERNAME}@${DB_IP}:/tmp/backup_archive/*.tar.gz" ${BUILD_HOME}/manualbackups
		/bin/echo"######################################################################"
		/bin/echo "BACKUP STORED IN ${BUILD_HOME}/manualbackups"
		/bin/echo "#####################################################################"
	fi
else
	/bin/echo "Unrecognised selection, please select only 1 or 2"
fi
