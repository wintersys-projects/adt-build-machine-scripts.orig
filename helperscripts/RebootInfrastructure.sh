#!/bin/sh
#########################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will reboot your infrastructure
#########################################################################################################
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


if ( [ ! -f  ./RebootInfrastructure.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "I find that with some providers, occassionally, the networking doesn't initialse correctly and you get timeouts between machines"
/bin/ehco "If you find a situation where everything looks to be running fine but you get a timeout, a simple reboot can sort it out"
/bin/echo "So, please bear that in mind as something to try if you are getting timeouts...Thanks"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr. Please Enter the number for your cloudhost"
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

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

autoscaler_token_to_match="as-`/bin/grep 'REGION=' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /usr/bin/awk -F'=' '{print $NF}'`-${BUILD_IDENTIFIER}"
webserver_token_to_match="ws-`/bin/grep 'REGION=' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /usr/bin/awk -F'=' '{print $NF}'`-${BUILD_IDENTIFIER}"
database_token_to_match="db-`/bin/grep 'REGION=' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /usr/bin/awk -F'=' '{print $NF}'`-${BUILD_IDENTIFIER}"

/bin/echo "${BUILD_IDENTIFIER}" > ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
then
	autoscalerips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${autoscaler_token_to_match}" ${CLOUDHOST} ${BUILD_HOME}`"
else
	autoscalerips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${autoscaler_token_to_match}" ${CLOUDHOST} ${BUILD_HOME}`"
fi

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
then
	webserverips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${webserver_token_to_match}" ${CLOUDHOST} ${BUILD_HOME}`"
else
	webserverips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${webserver_token_to_match}" ${CLOUDHOST} ${BUILD_HOME}`"
fi

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/VPC-ACTIVE ] )
then
	databaseips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${database_token_to_match}" ${CLOUDHOST} ${BUILD_HOME}`"
else
	databaseips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh  "${database_token_to_match}" ${CLOUDHOST} ${BUILD_HOME}`"
fi

/bin/echo "Do your servers use Elliptic Curve Digital Signature Algorithm or the Rivest Shamir Adleman Algorithm for authenitcation?"
/bin/echo "If you are not sure, please try one and then the other. If you are prompted for a password, it is the wrong one"
/bin/echo "Please select (1) RSA (2) ECDSA"
read response

if ( [ "${response}" = "1" ] )
then
	ALGORITHM="rsa"
elif ( [ "${response}" = "2" ] )
then
	ALGORITHM="ecdsa"
else
	/bin/echo "Unknown choice. Exiting...."
	exit
fi

/bin/echo "Are you sure you want to reboot the infrastructure? (Y/N)"
read response

if ( [ "${response}" != "Y" ] && [ "${response}" != "y" ] )
then
	exit
fi

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSER`"
SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSERPASSWORD`"
SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
SSH_PORT="`/bin/grep SSH_PORT ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

/bin/echo "OK, rebooting your infrastructure"


for ip in ${autoscalerips}
do
	/bin/echo "Rebooting autoscaler....."
	/bin/sleep 5
	AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/autoscaler_${ip}-keys"

	if ( [ ! -f ${AUTOSCALER_PUBLIC_KEYS} ] )
	then
		/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${ip} > ${AUTOSCALER_PUBLIC_KEYS}    
	else
		/bin/echo "#####################################################################################################################################################################"
		/bin/echo "Do you want to initiate a fresh ssh key scan (might be necessary if you can't connect) or  do you want to use previously generated keys"
		/bin/echo "You should always use previously generated keys unless you can't connect (an previously used ip address might have been reallocated as part of scaling or redeployment"
		/bin/echo "#####################################################################################################################################################################"
		/bin/echo "Enter 'Y' to regenerate your SSH public keys anything else to keep the keys you have got. You should only need to regenerate the keys very occassionally if at all"    
		read response1
		if ( [ "${response1}" = "Y" ] || [ "${response1}" = "y" ] )
		then
			/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${ip} > ${AUTOSCALER_PUBLIC_KEYS}
		fi
	fi

	if ( [ "`/bin/cat ${AUTOSCALER_PUBLIC_KEYS}`" = "" ] )
	then
		/bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online"
		/bin/rm ${AUTOSCALER_PUBLIC_KEYS}
		exit
	fi
	
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${ip} "${SUDO} /usr/sbin/shutdown -r now" 2>/dev/null
done

for ip in ${webserverips}
do
	/bin/echo "Rebooting webserver....."
	/bin/sleep 5
	
	WEBSERVER_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/webserver_${ip}-keys"

	if ( [ ! -f ${WEBSERVER_PUBLIC_KEYS} ] )
	then
		/usr/bin/ssh-keyscan -p ${SSH_PORT} ${ip} > ${WEBSERVER_PUBLIC_KEYS}    
	else
		/bin/echo "#####################################################################################################################################################################"
		/bin/echo "Do you want to initiate a fresh ssh key scan (might be necessary if you can't connect) or  do you want to use previously generated keys"
		/bin/echo "You should always use previously generated keys unless you can't connect (an previously used ip address might have been reallocated as part of scaling or redeployment"
		/bin/echo "#####################################################################################################################################################################"
		/bin/echo "Enter 'Y' to regenerate your SSH public keys anything else to keep the keys you have got. You should only need to regenerate the keys very occassionally if at all"   
		read response1
		if ( [ "${response1}" = "Y" ] || [ "${response1}" = "y" ] )
		then
			/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${ip} > ${WEBSERVER_PUBLIC_KEYS}
		fi
	fi

	if ( [ "`/bin/cat ${WEBSERVER_PUBLIC_KEYS}`" = "" ] )
	then
		/bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online"
		/bin/rm ${WEBSERVER_PUBLIC_KEYS}
		exit
	fi
	
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${ip} "${SUDO} /usr/sbin/shutdown -r now" 2>/dev/null
done

for ip in ${databaseips}
do
	/bin/echo "Rebooting database....."
	/bin/sleep 5

	DATABASE_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/database_${ip}-keys"

	if ( [ ! -f ${DATABASE_PUBLIC_KEYS} ] )
	then
		/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${ip} > ${DATABASE_PUBLIC_KEYS}    
	else
		/bin/echo "#####################################################################################################################################################################"
		/bin/echo "Do you want to initiate a fresh ssh key scan (might be necessary if you can't connect) or  do you want to use previously generated keys"
		/bin/echo "You should always use previously generated keys unless you can't connect (an previously used ip address might have been reallocated as part of scaling or redeployment"
		/bin/echo "#####################################################################################################################################################################"
		/bin/echo "Enter 'Y' to regenerate your SSH public keys anything else to keep the keys you have got. You should only need to regenerate the keys very occassionally if at all"    
		read response1
		if ( [ "${response1}" = "Y" ] || [ "${response1}" = "y" ] )
		then
			/usr/bin/ssh-keyscan  -p ${SSH_PORT} ${ip} > ${DATABASE_PUBLIC_KEYS}
		fi
	fi

	if ( [ "`/bin/cat ${DATABASE_PUBLIC_KEYS}`" = "" ] )
	then
		/bin/echo "Couldn't initiate ssh key scan please try again (make sure the machine is online"
		/bin/rm ${DATABASE_PUBLIC_KEYS}
		exit
	fi
	
	/usr/bin/ssh -o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} -i ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USERNAME}@${databaseips} '${SUDO} /usr/sbin/shutdown -r now' 2>/dev/null
done
