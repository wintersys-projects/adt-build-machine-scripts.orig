#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will build machines from pre existing snapshots held with your
# cloudhost. The cloudhost has to support snapshots and snapshots are identified
# uniquely so that they can be provisioned. From a deployer perspective, the environment
# still needs to be re-primed or at least reviews as, for example, you might require
# that the machine sizes are different to what they were when the snapshots were generated
# Also, you may require to use a different repo, an hourly backup build deployment
# when you may have built off a baseline in the build the snapshots were generated from.
# NOTE THEN: The enviroment is fully re-primed or reviewed for a snapshot deployment, but
# only a small subset of specific environment variables are actually actively renewed
# when deployed from a snapshot, otherwise, the enviroment is considered to be the same
# as when the snapshots were generated, for example, same username and password for
# the user that we sudo from as were in the original and so on.
#####################################################################################
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
######################################################################################
######################################################################################
#set -x

AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys"
WEBSERVER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_keys"
DATABASE_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_keys"

OPTIONS_AS="-o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "
OPTIONS_WS="-o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "
OPTIONS_DB="-o ConnectTimeout=10 -o ConnectionAttempts=30 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "

BUILD_KEY="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}"

if ( [ "${AUTOSCALER_IMAGE_ID}" != "" ] && [ "${WEBSERVER_IMAGE_ID}" != "" ] && [ "${DATABASE_IMAGE_ID}" != "" ] )
then
	status "#########################BUILD FROM SNAPSHOTS#######################"
	status ""
	
	#Generate the snapshot of the autoscaler. We use the username as the identifier as that will remain constant between
	#the original machine and the generated snapshot
	RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"
	FULL_SNAPSHOT_ID="`/bin/ls ${BUILD_HOME}/snapshots | /bin/grep ${SNAPSHOT_ID}`"
	/bin/cp /dev/null ${AUTOSCALER_PUBLIC_KEYS}

	no_autoscalers="0"
	while ( [ "${no_autoscalers}" -lt "${NO_AUTOSCALERS}" ] )
	do
	   status "#######################################################################################################"
	   status "Building autoscaler `/usr/bin/expr ${no_autoscalers} + 1` of ${NO_AUTOSCALERS} autoscalers"

		autoscaler_name="autoscaler-${RND}-`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
		autoscaler_name="`/bin/echo NO-${no_autoscalers}-${autoscaler_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

		#Find out what operating system we are building for
		OS_TYPE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${AS_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"

		if ( [ "${SUBNET_ID}" = "" ] )
		then
			SUBNET_ID="FILLER"
		fi

		#Actually create the server from the snapshot. Note that the image id of the snapshot we want to build from is passed in as the
		#last parameter
		${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION}" "${AS_SERVER_TYPE}" "${autoscaler_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${AUTOSCALER_IMAGE_ID}" "${ENABLE_DDOS_PROTECION}" 1>/dev/null 2>/dev/null
	
	
		#Get the ip addresses of the server we have just built
		ip=""
		private_ip=""
		count="0"
		while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "20" ] )
		do
			status "Interrogating for autoscaler ip addresses....."
			ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
			private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
			/bin/sleep 30
			count="`/usr/bin/expr ${count} + 1`"
		done

		status "It looks like the machine has booted OK"
		ASIP=${ip}
		ASIP_PRIVATE=${private_ip}

		if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
		then
			as_active_ip="${ASIP_PRIVATE}"
		elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
		then
			as_active_ip="${ASIP}"
		fi

		if ( [ ! -d ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
		then
			/bin/mkdir -p ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}
		fi

		/usr/bin/ssh-keyscan -p ${SSH_PORT} ${as_active_ip} >> ${AUTOSCALER_PUBLIC_KEYS}

		while ( [ "$?" != "0" ] )
		do
			status "Could not scan ssh keys for the autoscaler, will try again (this may take several attempts whilst the machine starts up)"
			/bin/sleep 10
			/usr/bin/ssh-keyscan -p ${SSH_PORT} ${as_active_ip} > ${AUTOSCALER_PUBLIC_KEYS}
		done

		/usr/bin/ssh-keyscan ${ASIP_PRIVATE} >> ${AUTOSCALER_PUBLIC_KEYS}

		status "Have got the ip addresses for your autoscaler"
		status "Public IP address: ${ASIP}"
		status "Private IP address: ${ASIP_PRIVATE}"

		#We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
		#So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
		#We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
		/bin/echo "Host ${as_active_ip}" >> ~/.ssh/config
		/bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
		/bin/echo "IdentitiesOnly yes" >> ~/.ssh/config
		no_autoscalers="`/usr/bin/expr ${no_autoscalers} + 1`"
	done
	
	ASIPS="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "*autoscaler*" ${CLOUDHOST} | /bin/grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | /bin/tr '\n' ':' | /bin/sed 's/\:$//g'`"
	ASIP_PRIVATES="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "*autoscaler*" ${CLOUDHOST} | /bin/grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | /bin/tr '\n' ':' | /bin/sed 's/\:$//g'`"
	ASIPS_CLEANED="`/bin/echo ${ASIPS} | /bin/sed 's/\:/ /g'`"
	ASIPS_PRIVATES_CLEANED="`/bin/echo ${ASIP_PRIVATES} | /bin/sed 's/\:/ /g'`"

	if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
	then
		as_active_ips="${ASIPS_PRIVATES_CLEANED}"
	elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
	then
		as_active_ips="${ASIPS_CLEANED}"
	fi

	
	status "#########################################################################################################"

	#Generate the webserver snapshot. Again, we use the username to create the identifier of the machine as this will remain
	#the same between the original machine and the machine built from a snapshot
	webserver_name="webserver-${RND}-`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
	webserver_name="`/bin/echo ${webserver_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

	status "Building webserver machine....."

	#Build the machine from the snapshot. The snapshot image id is passed in as the final parameter
	${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION}" "${WS_SERVER_TYPE}" "${webserver_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${WEBSERVER_IMAGE_ID}" "${ENABLE_DDOS_PROTECION}" 1>/dev/null 2>/dev/null

	#Get the ip addresses of the server we have just built
	ip=""
	private_ip=""
	count="0"
	while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "10" ] )
	do
		status "Interrogating for webserver ip addresses....."
		ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
		private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
		/bin/sleep 30
		count="`/usr/bin/expr ${count} + 1`"
	done

	status "It looks like the machine has booted OK"
	WSIP=${ip}
	WSIP_PRIVATE=${private_ip}

	status "Have got the ip addresses for your webserver"
	status "Public IP address: ${WSIP}"
	status "Private IP address: ${WSIP_PRIVATE}"

	if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
	then
	   ws_active_ip="${WSIP_PRIVATE}"
	elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
	then
	   ws_active_ip="${WSIP}"
	fi

	if ( [ ! -d ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
	then
		/bin/mkdir -p ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}
	fi

	/usr/bin/ssh-keyscan -p ${SSH_PORT} ${ws_active_ip} > ${WEBSERVER_PUBLIC_KEYS}

	while ( [ "$?" != "0" ] )
	do
		status "Could not scan ssh keys for the webserver, will try again (this may take several attempts whilst the machine starts up)"
		/bin/sleep 10
		/usr/bin/ssh-keyscan -p ${SSH_PORT} ${ws_active_ip} > ${WEBSERVER_PUBLIC_KEYS}
	done

	#We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
	#So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
	#We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
	/bin/echo "Host ${ws_active_ip}" >> ~/.ssh/config
	/bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
	/bin/echo "IdentitiesOnly yes" >> ~/.ssh/config
	
	status "#########################################################################################################"

	status "Building database machine....."

	# generate the database snapshot. The username is used to create the identifier as it will remain consistent between the original machine
	# and the machine generated from a snapshot
	database_name="database-${RND}-`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
	database_name="`/bin/echo ${database_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"
	${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION}" "${DB_SERVER_TYPE}" "${database_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} "${SUBNET_ID}" "${DATABASE_IMAGE_ID}" "${ENABLE_DDOS_PROTECION}" 1>/dev/null 2>/dev/null

	#Get the ip addresses of the server we have just built
	ip=""
	private_ip=""
	count="0"
	while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "10" ] )
	do
		status "Interrogating for database ip addresses....."
		ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
		private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
		/bin/sleep 30
		count="`/usr/bin/expr ${count} + 1`"
	done

	status "It looks like the machine has booted OK"
	DBIP=${ip}
	DBIP_PRIVATE=${private_ip}

	status "Have got the ip addresses for your database"
	status "Public IP address: ${DBIP}"
	status "Private IP address: ${DBIP_PRIVATE}"

	if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
	then
		db_active_ip="${DBIP_PRIVATE}"
	elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
	then
		db_active_ip="${DBIP}"
	fi

	if ( [ ! -d ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
	then
		/bin/mkdir -p ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}
	fi

	/usr/bin/ssh-keyscan -p ${SSH_PORT} ${db_active_ip} > ${DATABASE_PUBLIC_KEYS}

	while ( [ "$?" != "0" ] )
	do
		status "Could not scan ssh keys for the database, will try again (this may take several attempts whilst the machine starts up)"
		/bin/sleep 10
		/usr/bin/ssh-keyscan -p ${SSH_PORT} ${db_active_ip} > ${DATABASE_PUBLIC_KEYS}
	done

	#We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
	#So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
	#We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
	/bin/echo "Host ${db_active_ip}" >> ~/.ssh/config
	/bin/echo "IdentityFile ~/.ssh/${FULL_SNAPSHOT_ID}.key" >> ~/.ssh/config
	/bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

	#Remember the keys and config settings for use when we deploy these from these snapshots. The build process will try
	#and use new keys but we'll say, 'no you don't, you have to use the ones we recorded earlier'.
	/bin/mv  ${BUILD_KEY}  ${BUILD_KEY}.$$
	/bin/cp ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${BUILD_KEY}
	/bin/mv  ${BUILD_KEY}.pub  ${BUILD_KEY}.pub.$$
	/bin/cp ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${BUILD_KEY}.pub
	/bin/mv ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials.$$
	/bin/cp -r ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/

	SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD`"
	SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

	########AUTOSCALER config#################

	for as_ip in ${as_active_ips}
	do
		#Wait until the autoscaler has been fully provisioned from its snapshot
		status "Trying to connect to the autoscaler (${as_ip}) to perform initialisation....(this may take a few attempts) I will let you know if I am successful, please wait"
		/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${as_ip} "exit"

		while ( [ "$?" != "0" ] )
		do
		   /bin/sleep 10
		   /usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${as_ip} "exit"
		done

		status "Connected to the autoscaler (${as_ip}) , now initialising it..."

		if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/EMERGENCY_PASSWORD ] )
		then
			/usr/bin/scp -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -P ${SSH_PORT} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/EMERGENCY_PASSWORD ${FULL_SNAPSHOT_ID}@${as_ip}:/home/${SERVER_USER}/.ssh/EMERGENCY_PASSWORD 
		fi

		#There might be some stuff on the autoscaler which is from the build when the snapshots were generated, like IP addresses and so on, so
		#clear them out as they have now been changed/renewed
		/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${as_ip} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/INITIALCONFIGSET /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* /home/${FULL_SNAPSHOT_ID}/runtime/CONFIG-PRIMED"     
		/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${as_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVE\" \"${BUILD_ARCHIVE_CHOICE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"AUTOSCALE\" \"${WEBSERVER_SNAPSHOT_NAME}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"SNAPSHOTID\" \"${WEBSERVER_IMAGE_ID}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"SNAPAUTOSCALE\" \"1\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"KEYID\" \"${PUBLIC_KEY_ID}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${ASIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPUBLICIP\" \"${DBIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBIP\" \"${DBIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPORT\" \"${DB_PORT}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"SIZE\" \"${WS_SIZE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValueWebserver.sh \"DBPORT\" \"${DB_PORT}\""

		#Reinitialise everything by rebooting the machine
		/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${as_ip} "${SUDO} /bin/touch /home/${FULL_SNAPSHOT_ID}/runtime/INITIALBUILDCOMPLETED ; ${SUDO} /sbin/shutdown -r now"
	done

	########WEBSERVER config############

	#Wait until the webserver has been fully provisioned from its snapshot
	status "Trying to connect to the webserver ${ws_active_ip} to perform initialisation.... (this may take a few attempts) I will let you know if I am successful, please wait"

	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "exit"

	while ( [ "$?" != "0" ] )
	do
		/bin/sleep 10
		/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "exit"
	done

	#Clean what we need to so that the configuration will reinitialise on the machine.
	#NETCONFIGURED removing that means that the private ip networking will be refreshed to reflect the new ip addresses
	#APPLICATION_DB_CONFIGURED removing that will mean that the database reinitialises for the new ip addresses and so on
	#SSHTUNNELCONFIGURED removing that will mean that the SSH tunneling will be reinitialised in the case where we use DBaaS
	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/APPLICATION_DB_CONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/APPLICATION_CONFIGURATION_PREPARED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* /home/${FULL_SNAPSHOT_ID}/runtime/CONFIG-PRIMED"

	status "Connected to the webserver ${ws_active_ip}, now initialising it..."

	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBIP\" \"${DBIP_PRIVATE}\" ;  ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPUBLICIP\" \"${DBIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${WSIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${WSIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\";${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPORT\" \"${DB_PORT}\""


	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /sbin/shutdown -r now"


	#If we get to here then we know that the webserver was built correctly
	#We have to configure it some more and add it to the DNS provider's DNS so we can access the webserver
	#Please note, we make use of the implicit DNS loadbalancing system with our webservers
	name="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

	#Create  zone if it doesn't already exist
	${BUILD_HOME}/providerscripts/dns/CreateZone.sh "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${DNS_CHOICE}" "${DNS_REGION}"

	status "We are adding our DNS records to the DNS provider you selected, in this case ${DNS_CHOICE}"
	zonename="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
	zoneid="`${BUILD_HOME}/providerscripts/dns/GetZoneID.sh "${zonename}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"
	recordids="`${BUILD_HOME}/providerscripts/dns/GetAllRecordIDs.sh  "${zoneid}" "${WEBSITE_URL}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"

	if ( [ "${recordids}" != "" ] )
	then
		for recordid in ${recordids}
		do
			${BUILD_HOME}/providerscripts/dns/DeleteRecord.sh "${zoneid}" "${recordid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"
		done
	fi

	#Add our record to the dns. Please note, proxying has to be off, but we need the ip address to be active with our DNS provider
	#provider. The reason why proxying is off is that the system we use to install SSL certificates does not work when proxying is on

	if ( [ "${DNS_REGION}" = "" ] )
	then
		DNS_REGION="FILLER"
	fi
	
	${BUILD_HOME}/providerscripts/dns/AddRecord.sh "${zoneid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${WSIP}" "true" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"
	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${WSIP} "${SUDO} /sbin/shutdown -r now"

	##############DB config#################################

	#Wait until we are sure our DB machine has been provisioned from the snapshot
	status "Trying to connect to the database ${db_active_ip} to perform initialisation....(this may take a few attempts) I will let you know if I am successful"
	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${db_active_ip} "exit"

	while ( [ "$?" != "0" ] )
	do
		/bin/sleep  10
		/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${db_active_ip} "exit"
	done

	status "Connected to the database ${db_active_ip}, now initialising it..."

	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${db_active_ip} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/NETCONFIGURED /home/${FULL_SNAPSHOT_ID}/runtime/*lock* /home/${FULL_SNAPSHOT_ID}/runtime/CONFIG-PRIMED"
	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${db_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDCLIENTIP\" \"${BUILD_CLIENT_IP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"BUILDARCHIVECHOICE\" \"${BUILD_ARCHIVE_CHOICE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP\" \"${ASIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASPUBLICIP\" \"${ASIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYPUBLICIP\" \"${DBIP}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"MYIP\" \"${DBIP_PRIVATE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"WSIP\" \"${WSIP_PRIVATE}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"WSPUBLICIP\" \"${WSIP}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIPS\" \"${ASIPS}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"ASIP_PRIVATES\" \"${ASIP_PRIVATES}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEINSTALLATIONTYPE\" \"${DATABASE_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSDBNAME\" \"${DBaaS_DBNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSHOSTNAME\" \"${DBaaS_HOSTNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSUSERNAME\" \"${DBaaS_USERNAME}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBaaSPASSWORD\" \"${DBaaS_PASSWORD}\"; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DATABASEDBaaSINSTALLATIONTYPE\" \"${DATABASE_DBaaS_INSTALLATION_TYPE}\" ; ${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreConfigValue.sh \"DBPORT\" \"${DB_PORT}\""

	#to refresh everything, reboot the machine
	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${DBIP} "${SUDO} /sbin/shutdown -r now"

fi

	status "Trying to confirm database credentials.....this may take several attempts, I will let you know if I am successful, please wait"

. ${BUILD_HOME}/providerscripts/datastore/ConfirmCredentials.sh

while ( [ "${credentials_confirmed}" != "1" ] )
do
	. ${BUILD_HOME}/providerscripts/datastore/ConfirmCredentials.sh
	/bin/sleep 60
done

status "Successfully confirmed datanbase credentials"


if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreDatabaseCredentials.sh \"${DBaaS_DBNAME}\" \"${DBaaS_PASSWORD}\" \"${DBaaS_USERNAME}\"" 
	/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${db_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/utilities/StoreDatabaseCredentials.sh \"${DBaaS_DBNAME}\" \"${DBaaS_PASSWORD}\" \"${DBaaS_USERNAME}\""                   
fi


# A snapshot might have been made weeks ago and there's been some application modifications or new data is in the database.
# We want to sync, therefore with our latest db backups and repos. Note if the snapshot is generated during a baseline build
# then, when we rerun the config process, we need to select an hourly backup, for example, to sync here with our hourly backup repo/db
status "Attempting to synchronise with the latest application sourcecode  (this may take a few attempts), I will let you know if I am successful"
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS_WS} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/SyncLatestApplication.sh"
while ( [ "$?" != "0" ] )
do
	/bin/sleep 10
	/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS_WS} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/SyncLatestApplication.sh"
done

status "Attempting to synchronise with the latest application database (this may take a few attempts), I will let you know if I am successful"

/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS_DB} ${FULL_SNAPSHOT_ID}@${db_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/applicationdb/InstallApplicationDB.sh force"
while ( [ "$?" != "0" ] )
do
	/bin/sleep 10
	/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS_DB} ${FULL_SNAPSHOT_ID}@${db_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/applicationdb/InstallApplicationDB.sh force"
done

status "Performing any post processing that is needed for your application. This may take a little while depending on your application, Please wait...."
/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS_WS} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/processing/PerformPostProcessingByApplication.sh ${FULL_SNAPSHOT_ID}"

#We are satisfied that all is well, so let's try and see if the application is actually online and active
if ( [ "${DNS_CHOICE}" != "NONE" ] )
then
	status "Application has completed its initialisation, just checking that it is also online.....Endless waiting (more than 5 minutes) and something must be wrong)"
	
	serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS_WS} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
	
	while ( [ "`/bin/echo ${serverinstalled} | /bin/grep ALIVE`" = "" ] )
	do
		serverinstalled="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS_WS} ${FULL_SNAPSHOT_ID}@${ws_active_ip} "${SUDO} /home/${FULL_SNAPSHOT_ID}/providerscripts/application/monitoring/CheckServerAlive.sh" 2>/dev/null`"
		/bin/sleep 100
	done
fi

status "Application has been confirmed to be in good order as far as I can tell"

/usr/bin/ssh -i ${BUILD_KEY} -o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes -p ${SSH_PORT} ${FULL_SNAPSHOT_ID}@${as_active_ip} "${SUDO} /bin/rm -rf /home/${FULL_SNAPSHOT_ID}/runtime/*lock*"

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} INSTALLEDSUCCESSFULLY INSTALLEDSUCCESSFULLY

# If we got to here then we really are doing quite well and we can assume that the environment is Ok to use next
# time around, so dump it to a config file

#################################################################################################################
#If you are a developer and you modify these scripts, you will need to update the envdump.dat file below
#with the variables you have added
#################################################################################################################

/bin/rm ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}

while read line
do
	name="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $1}'`"
	value="`/bin/echo ${line} | /usr/bin/awk -F':' '{print $NF}'`"
	value="`eval /bin/echo ${value}`"
	/bin/echo "export ${name}=\"${value}\"" >> ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}
done < ${BUILD_HOME}/builddescriptors/envdump.dat
