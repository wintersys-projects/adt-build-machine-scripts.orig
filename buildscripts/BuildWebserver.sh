#!/bin/sh
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This is the script which will build a functioning webserver. It contains
# all the configuration settings and remote calls to the webserver we are building to ensure
# that it is built correctly and functions as it is supposed to.
# These scripts look more complicated than they really are. All that is happening is we are
# copying over some files to our new autoscaler and executing a few commands (mostly to
# install software) remotely on the autoscaler.
########################################################################################
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
#########################################################################################
#########################################################################################
#set -x
done=0
counter="0"
count="0"

status ""
status ""
status ""
status "#########################WEBSERVER#######################"

#These are the options that we want to use to connect to the remote server. Using a variable for them keeps our code cleaner
#and simpler and also if we want to change a parameter globally, we can change it here and it will change throughout
if ( [ "${PRODUCTION}" = "1" ] )
then
	AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys"
fi
WEBSERVER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_keys"
OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "
OPTIONS_AUTOSCALER="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "
PUBLIC_KEY_ID="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/PUBLICKEYID`"

if ( [ "${DEFAULT_USER}" = "root" ] )
then
	SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
else
	SUDO="DEBIAN_FRONTEND=noninteractive /usr/bin/sudo -S -E "
fi

CUSTOM_USER_SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

status ""
status ""
status ""
status ""
status "========================================================="
status "=================BUILDING WEBSERVER======================"
status "========================================================="

status "Logging for this webserver build is located at ${BUILD_HOME}/logs/${OUT_FILE}"
status "The error stream for this webserver build is located at ${BUILD_HOME}/logs/${ERR_FILE}"
status "========================================================="

#If "done" is set to 1, then we know that a webserver has been successfully built and is running.
#Try up to 5 times if the webserver is failing to complete its build
while ( [ "${done}" != "1" ] && [ "${counter}" -lt "5" ] )
do
	counter="`/usr/bin/expr ${counter} + 1`"
	status "OK... Building a webserver. This is the ${counter} attempt of 5"
	WEBSITE_IDENTIFIER="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`"

 >&2 echo "XXXXX 1"

	#Check if there is a webserver already running. If there is, then skip building the webserver
	if ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "webserver" ${CLOUDHOST} 2>/dev/null`" -eq "0" ] )
	then
		ip=""
		#Construct a unique name for this webserver
		RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"

		webserver_name="webserver-init-${RND}-`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
		webserver_name="`/bin/echo ${webserver_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"
		
		#What OS type are we building for. Currently, only ubuntu is supported
		
		if ( [ "${OS_TYPE}" = "" ] )
		then
			OS_TYPE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${WS_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"
		fi

		status "Initialising a new server machine, please wait......"
>&2 echo "XXXXX 2"
		server_started="0"
		while ( [ "${server_started}" = "0" ] )
		do
			count="0"
			#Actually start the server machine. Following this, there will be an active machine instance running on your cloud provider
			${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${OS_TYPE}'" "${REGION}" "${WS_SERVER_TYPE}" "${webserver_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${WEBSERVER_IMAGE_ID} ${ENABLE_DDOS_PROTECION}

			#Keep trying if the first time wasn't successful
			while ( [ "$?" != "0" ] && [ "${count}" -lt "10" ] )
			do
				count="`/usr/bin/expr ${count} + 1`"
				/bin/sleep 10
				${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION}" "${WS_SERVER_TYPE}" "${webserver_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${WEBSERVER_IMAGE_ID}  ${ENABLE_DDOS_PROTECION}
			done
			
			if ( [ "${count}" = "10" ] )
			then
				status "Could not create webserver machine"
				exit
			fi

			#Check that the server has been assigned its IP addresses and that they are active
			ip=""
			private_ip=""
			count="0"
 >&2 echo "XXXXX 3"

			#Keep trying until we get the ip addresses of our new machine, both public and private ips
			while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) || [ "${ip}" = "0.0.0.0" ] && [ "${count}" -lt "20" ] )
			do
				status "Interrogating for webserver ip address....."
				ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
				private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${webserver_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
				/bin/sleep 10
				count="`/usr/bin/expr ${count} + 1`"
			done
			
			if ( [ "${ip}" != "" ] && [ "${private_ip}" != "" ] )
			then
				server_started="1"
			else
				status "I haven't been able to start your server, trying again...."
			fi
	   done
 >&2 echo "XXXXX 4"

	   ${BUILD_HOME}/providerscripts/server/EnsureServerAttachedToVPC.sh "${CLOUDHOST}" "${webserver_name}" "${private_ip}"

		WSIP=${ip}
		WSIP_PRIVATE=${private_ip}

		if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
		then
			ws_active_ip="${WSIP_PRIVATE}"
		elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
		then
			ws_active_ip="${WSIP}"
		fi

		status "Have got the ip addresses for your webserver (${webserver_name})"
		status "Public IP address: ${WSIP}"
		status "Private IP address: ${WSIP_PRIVATE}"

		if ( [ ! -d ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER} ] )
		then
			/bin/mkdir -p ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}
		fi

		status "Performing SSH keyscan on your new webserver machine (I allow up to 10 attempts). If this does fail, check BUILD_MACHINE_VPC in your template"

		if ( [ -f ${WEBSERVER_PUBLIC_KEYS} ] )
		then
			/bin/cp /dev/null ${WEBSERVER_PUBLIC_KEYS}
		fi
		
		/usr/bin/ssh-keyscan -T 60 ${ws_active_ip} >> ${WEBSERVER_PUBLIC_KEYS}

   >&2 echo "XXXXX 5"

		keytry="0"
		while ( [ "`/usr/bin/diff -s /dev/null ${WEBSERVER_PUBLIC_KEYS} | /bin/grep identical`" != "" ] && [ "${keytry}" -lt "10" ] )
		do
			status "Couldn't scan for webserver ${webserver_name} ssh-keys ... trying again"
			/bin/sleep 10
			keytry="`/usr/bin/expr ${keytry} + 1`"
			/usr/bin/ssh-keyscan -T 60 ${ws_active_ip} >> ${WEBSERVER_PUBLIC_KEYS}
		done 

		if ( [ "${keytry}" = "10" ] )
		then
			status "Couldn't obtain ssh-keys, having to destroy the machine and try again"
			${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${WSIP} ${CLOUDHOST}
		else
			status "Successfully scanned remote webserver ${webserver_name} for ssh-keys"

			#We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
			#So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
			#We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
			/bin/echo "Host ${ws_active_ip}" >> ~/.ssh/config
			/bin/echo "IdentityFile ~/.ssh/${SERVER_USER}.key" >> ~/.ssh/config
			/bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

			initiation_ip="${ws_active_ip}"
			machine_type="webserver"

			. ${BUILD_HOME}/buildscripts/InitiateNewMachine.sh

			/bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
		
			while read param
			do
				param1="`eval /bin/echo ${param}`"
				if ( [ "${param1}" != "" ] )
				then
					 /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
				fi
			done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
		
			/usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${ws_active_ip}:/home/${SERVER_USER}/.ssh/webserver_configuration_settings.dat >/dev/null 2>&1
			/usr/bin/scp ${OPTIONS} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${ws_active_ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1   
			/usr/bin/scp ${OPTIONS} ${BUILD_HOME}/providerscripts/git/GitRemoteInstall.sh ${SERVER_USER}@${ws_active_ip}:/home/${SERVER_USER}/InstallGit.sh

			gitfetchno="0"
			while ( [ "`/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/ls /home/${SERVER_USER}/ws.sh" 2>/dev/null`" = "" ] && [ "${gitfetchno}" -lt "5" ] )
			do
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/InstallGit.sh ; cd /home/${SERVER_USER}; /usr/bin/git clone https://github.com/${INFRASTRUCTURE_REPOSITORY_OWNER}/adt-webserver-scripts.git; /bin/cp -r ./adt-webserver-scripts/* .; /bin/rm -r ./adt-webserver-scripts ; /bin/chown -R ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}/*; /bin/chmod 500 /home/${SERVER_USER}/ws.sh"
				/bin/sleep 5
				gitfetchno="`/usr/bin/expr ${gitfetchno} + 1`"
		   done
 >&2 echo "XXXXX 6"

			if ( [ "${gitfetchno}" = "5" ] )
			then
				status "Had trouble getting the webserver infrastructure sourcecode, will have to exit"
				exit
			fi

			status "About to build the webserver"
			status "Please Note: The process of building the webserver is running on a remote machine with ip address : ${WSIP}"
			status "To access this machine once it has finished provisioning you can use the scripts in ${BUILD_HOME}/helperscripts"
			status "Log files (stderr and stdout) are stored on the remote machine in the directory /home/${SERVER_USER}/logs"
			status "Starting to build the webserver proper"
			/bin/date >&3

		   #Which one is a called depends on what we are building from. Virgin, hourly, weekly, monthly or bimonthly
			if ( [ "${BUILD_CHOICE}" = "0" ] )
			then
				#We are building a virgin system
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'virgin' ${SERVER_USER}"
			elif ( [ "${BUILD_CHOICE}" = "1" ] )
			then
				#We are building from a baseline
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'baseline' ${SERVER_USER}"
			elif ( [ "${BUILD_CHOICE}" = "2" ] )
			then
				#We are building from an hourly backup
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'hourly' ${SERVER_USER}"
			elif ( [ "${BUILD_CHOICE}" = "3" ] )
			then
				#We are building from an daily backup
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'daily' ${SERVER_USER}"
			elif ( [ "${BUILD_CHOICE}" = "4" ] )
			then
				#We are building from an weekly backup
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'weekly' ${SERVER_USER}"
			elif ( [ "${BUILD_CHOICE}" = "5" ] )
			then
				#We are building from an monthly backup
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'monthly' ${SERVER_USER}"
			elif ( [ "${BUILD_CHOICE}" = "6" ] )
			then
				#We are building from an bimonthly backup
				/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/ws.sh 'bimonthly' ${SERVER_USER}"
			fi

			status "Finished building the webserver (${webserver_name})"
			status "`/bin/date`"
		
			#Wait for the machine to become responsive before we check its integrity

			pingcount="0"

			while ( [ "$?" != "0" ] )
			do
				/usr/bin/ping -c 10 ${ws_active_ip}
				pingcount="`/usr/bin/expr ${pingcount} + 1`"
				if ( [ "${pingcount}" = "10" ] )
				then
					status "I am having trouble pinging your new webserver."
					status "If you see this message repeatedly, maybe check that your security policy allows ping requests"
					status "----------------------------------------------------------------------------------------------"
					pingcount="0"
				fi
			done

			/bin/sleep 10

			status "We now need to wait for the webserver machine to become responsive"

			#So, looking good. Now what we have to do is keep monitoring for the build process for our webserver to complete
			done="0"
			alive=""
			status "About to check that the webserver (${webserver_name}) has built correctly and is primed"

			alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "/bin/ls /home/${SERVER_USER}/runtime/WEBSERVER_READY"`"

			count="0"
			while ( [ "${alive}" != "/home/${SERVER_USER}/runtime/WEBSERVER_READY" ] && [ "${count}" -lt "15" ] )
			do
				count="`/usr/bin/expr ${count} + 1`"
				/bin/sleep 10
				alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "/bin/ls /home/${SERVER_USER}/runtime/WEBSERVER_READY"`"
			done

			if ( [ "${count}" = "15" ] )
			then
				done="0"
			else
				done="1"
			fi

			. ${BUILD_HOME}/initscripts/InitialiseDNSRecord.sh
			
			#Remeber Webserver IP
			WSIP=${ip}

			#If $done != 1, then the webserver didn't build properly, so, destroy the machine
			if ( [ "${done}" != "1" ] )
			then
				status "################################################################################################################"
				status "Hi, a webserver didn't seem to build correctly. I can destroy it and I can try to build a new webserver for you"
				status "################################################################################################################"
				status "Press the <enter> key to be continue with the next attempt <ctrl - c> to exit"
				if ( [ "${HARDCORE}" != "1" ] )
				then
					read response
				fi

				${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${WSIP} ${CLOUDHOST}

				#Wait until we are sure that the image server(s) are destroyed because of a faulty build
				while ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "webserver" ${CLOUDHOST} 2>/dev/null`" != "0" ] )
				do
					/bin/sleep 30
				done
			else
				status "A webserver (${webserver_name}) has built correctly (`/usr/bin/date`) and is accepting connections"
				/bin/touch ${BUILD_HOME}/runtimedata/WEBSERVER_BUILT
				counter="`/usr/bin/expr ${counter} - 1`"
			fi
		fi
	else
		status "A webserver is already running, using that one"
		status "Press enter if this is OK with you"
		if ( [ "${HARDCORE}" != "1" ] )
		then
			read response
		fi
		done=1
	fi
done

#If we get to here then we know that the webserver didn't build properly, so report it and exit

if ( [ "${counter}" = "5" ] )
then
	status "The infrastructure failed to intialise because of a build problem, plese investigate, correct and rebuild"
	exit
fi
