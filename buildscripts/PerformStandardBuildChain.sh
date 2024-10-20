#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will perform a standard build chain (autoscaler/webserver/database)
####################################################################################
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
####################################################################################
####################################################################################
#set -x

if ( [ -f ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys ] )
then
	/bin/rm ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys
fi

if ( [ "${AUTOSCALE_FROM_SNAPSHOTS}" = "1" ] )
then
	status "###############################################################################################################################################"
	status "Performing a snapshot style build. If this is what you want, press <enter> if not <ctrl-c> to reconfigure"
	status "###############################################################################################################################################"
	if ( [ "${HARDCORE}" != "1" ] )
	then
		read carryon
	fi

	if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
	then
		status "##############################################################################################################"
		status "You have selected to use a 3rd party DBaaS for your database solution"
		status "It is fine to do this when building from snapshots, but there is a caveat that all the credentials have to be"
		status "the same as when you generated the snapshot as part of an initial build process"
		status "This means that you can't have changed the username, password, hostname, ip addresses and so on in the interim"
		status "period between when you generated the snapshot you are now building from and now."
		status "I am expecting you to have the following active and online"
		status "A Database with username: ${DBaaS_USERNAME}"
		status "A Database with password: ${DBaaS_PASSWORD}"
		status "A Database with the name: ${DBaaS_DBNAME}"
		status "A Database at Endpoint: ${DBaaS_HOSTNAME}"
		status "##############################################################################################################"
		status "If all these things are configured and set, then it is OK to :"
		status "Press the <enter> key to continue"
		if ( [ "${HARDCORE}" != "1" ] )
		then
			read x
		fi
	fi
	if ( [ "${NO_AUTOSCALERS}" = "" ] )
	then
		status "How many autoscalers do you want to deploy?"

		if ( [ "${HARDCORE}" != "1" ] )
		then
			read NO_AUTOSCALERS
		fi
		 
		while ! ( [ "${NO_AUTOSCALERS}" -eq "${NO_AUTOSCALERS}" ] 2> /dev/null )
		do
			status "Sorry, invalid input, try again"
			if ( [ "${HARDCORE}" != "1" ] )
			then
				read NO_AUTOSCALERS
			fi
		done
		if ( [ "${NO_AUTOSCALERS}" -lt "1" ] )
		then
			status "Number of autoscalers can't be less than 1 setting autoscalers to 1"
			status "Press <enter> to accept"
			if ( [ "${HARDCORE}" != "1" ] )
			then
				read x
			fi
			NO_AUTOSCALERS="1"
		elif ( [ "${NO_AUTOSCALERS}" -gt "5" ] )
		then
			status "Number of autoscalers can't be greater than 5 setting autoscalers to 5"
			status "Press <enter> to accept"
			if ( [ "${HARDCORE}" != "1" ] )
			then
				read x
			fi
			NO_AUTOSCALERS="5"
		else 
			status "Number of autoscalers is set to ${NO_AUTOSCALERS} are you sure?"
			status "Press <enter> to accept"
			if ( [ "${HARDCORE}" != "1" ] )
			then
				read x
			fi
		fi
	fi

	. ${BUILD_HOME}/buildscripts/BuildFromSnapshots.sh
	. ${BUILD_HOME}/providerscripts/security/firewall/TightenDBaaSFirewall.sh
	/bin/touch ${BUILD_HOME}/runtimedata/PRIME_FIREWALL
	cloudhost_holder="${CLOUDHOST}"
	. ${BUILD_HOME}/providerscripts/security/firewall/TightenBuildMachineFirewall.sh
	export CLOUDHOST="${cloudhost_holder}"

	status ""
	status "##########################################################################################################"
	status "Build from snapshots completed"
	status "It will take a few minutes before your site comes online. Anything more than 10 minutes before it is online"
	status "Means that there is something wrong and you should start to investigate"
	status "##########################################################################################################"
else
	status "###############################################################################################################################################"
	status "Performing a regular style build (not from snapshot images). If this is what you want, press <enter> if not <ctrl-c> to reconfigure"
	if ( [ "${GENERATE_SNAPSHOTS}" = "1" ] )
	then
		 if ( [ "${CLOUDHOST}" = "linode" ] )
		 then
			 status "=============================================================================================================================================="
			 status "To be able to generate snapshots when using Linode you need to enable the backup service for your linodes before the snapshots are made"
			 status "This is because of image size limits that are present when backups are not enabled for a linode which will cause the image generation to fail"
			 status "You will be given an opportunity to enable backups for your linodes just before snapshots are made as part of this build process"
			 status "==============================================================================================================================================="
			 status "Press <enter> to acknowledge this"
			 if ( [ "${HARDCORE}" != "1" ] )
			 then
				 read x
			 fi
		 fi
		 status "SNAPSHOTS OF YOUR MACHINES WILL BE GENERATED FOR FUTURE USE"
	else
		 status "NO SNAPSHOTS ARE BEING GENERATED"
	fi
	status "###############################################################################################################################################"
	status "Press <enter> to carry on"
	if ( [ "${HARDCORE}" != "1" ] )
	then
		read carryon
	fi

	if ( [ -f ${BUILD_HOME}/runtimedata/AUTOSCALER_BUILT ] )
	then
		/bin/rm ${BUILD_HOME}/runtimedata/AUTOSCALER_BUILT
	fi

	if ( [ -f ${BUILD_HOME}/runtimedata/WEBSERVER_BUILT ] )
	then
		/bin/rm ${BUILD_HOME}/runtimedata/WEBSERVER_BUILT
	fi

	if ( [ -f ${BUILD_HOME}/runtimedata/DATABASE_BUILT ] )
	then
		/bin/rm ${BUILD_HOME}/runtimedata/DATABASE_BUILT
	fi

	if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] && [ "${BASELINE_DB_REPOSITORY}" != "VIRGIN" ] )
	then
		if ( [ "${GENERATE_SNAPSHOTS}" != "1" ] )
		then
			if ( [ "${NO_AUTOSCALERS}" = "" ] )
			then
				status "How many autoscalers do you want to deploy?"
				if ( [ "${HARDCORE}" != "1" ] )
				then
					read NO_AUTOSCALERS
				fi 
				while ! ( [ "${NO_AUTOSCALERS}" -eq "${NO_AUTOSCALERS}" ] 2> /dev/null )
				do
					status "Sorry, invalid input, try again"
					if ( [ "${HARDCORE}" != "1" ] )
					then
						read NO_AUTOSCALERS
					fi
				done
				if ( [ "${NO_AUTOSCALERS}" -lt "1" ] )
				then
					status "Number of autoscalers can't be less than 1 setting autoscalers to 1"
					status "Press <enter> to accept"
					if ( [ "${HARDCORE}" != "1" ] )
					then
						read x
					fi
					NO_AUTOSCALERS="1"
				elif ( [ "${NO_AUTOSCALERS}" -gt "5" ] )
				then
					status "Number of autoscalers can't be greater than 5 setting autoscalers to 5"
					status "Press <enter> to accept"
					if ( [ "${HARDCORE}" != "1" ] )
					then
						read x
					fi
					NO_AUTOSCALERS="5"
				else 
					status "Number of autoscalers set to ${NO_AUTOSCALERS}"
					status "Press <enter> to accept"
					if ( [ "${HARDCORE}" != "1" ] )
					then
						read x
					fi
				fi
			fi
		else
			status "One autoscaler is being deployed (generate snapshots is active)"
		fi
		if ( [ "${NO_AUTOSCALERS}" -ne "0" ] && [ "${INPARALLEL}" = "0" ] )
		then
			tally="0"
			if ( [ -f ${BUILD_HOME}/runtimedata/MULTI_AUTOSCALER_BUILT ] )
			then
				/bin/rm ${BUILD_HOME}/runtimedata/MULTI_AUTOSCALER_BUILT
			fi
			while ( [ "${tally}" -lt "${NO_AUTOSCALERS}" ] && [ ! -f ${BUILD_HOME}/runtimedata/MULTI_AUTOSCALER_BUILT ] )
			do
				. ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh
				tally="`/usr/bin/expr ${tally} + 1`"
			done
		elif ( [ "${NO_AUTOSCALERS}" -ne "0" ] && [ "${INPARALLEL}" = "1" ] )
		then
			tally="0"
			while ( [ "${NO_AUTOSCALERS}" -le "5" ] && [ "${tally}" -lt "${NO_AUTOSCALERS}" ] )
			do
				. ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh &
				/bin/sleep 30
				tally="`/usr/bin/expr ${tally} + 1`"
			done
		fi
	fi

	if ( [ "${INPARALLEL}" = "0" ] )
	then
		. ${BUILD_HOME}/buildscripts/BuildWebserver.sh 
		. ${BUILD_HOME}/buildscripts/BuildDatabase.sh 
	elif ( [ "${NO_AUTOSCALERS}" -ne "0" ] && [ "${INPARALLEL}" = "1" ]  )
	then
		. ${BUILD_HOME}/buildscripts/BuildWebserver.sh &
		/bin/sleep 30
		. ${BUILD_HOME}/buildscripts/BuildDatabase.sh &

		tries="0"
		while ( [ "${NO_AUTOSCALERS}" = "1" ] && ( [ ! -f ${BUILD_HOME}/runtimedata/AUTOSCALER_BUILT ]  || [ ! -f ${BUILD_HOME}/runtimedata/DATABASE_BUILT ] || [ ! -f ${BUILD_HOME}/runtimedata/WEBSERVER_BUILT ] ) && [ "${tries}" -lt "200" ] )
		do
			/bin/sleep 10
			tries="`/usr/bin/expr ${tries} + 1`"
		done
			
		if ( [ "${tries}" -eq "200" ] )
		then
			status "######################################################################################################################"
			status "Waited a long time for the machines to build. I'm going to try and finish up but you might want to take a look into why its taking so long..."
			status "If you find that the build has failed for some reason you can shut the machines down from the ${CLOUDHOST} GUI system"
			status "######################################################################################################################"
		fi
		 
		tries="0"
		while ( [ "${NO_AUTOSCALERS}" -gt "1" ] && ( [ ! -f ${BUILD_HOME}/runtimedata/MULTI_AUTOSCALER_BUILT ] ||  [ ! -f ${BUILD_HOME}/runtimedata/DATABASE_BUILT ] || [ ! -f ${BUILD_HOME}/runtimedata/WEBSERVER_BUILT ] ) && [ "${tries}" -lt "200" ] )        
		do
			/bin/sleep 10
			tries="`/usr/bin/expr ${tries} + 1`"
		done
			
		if ( [ "${tries}" -eq "200" ] )
		then
			status "######################################################################################################################"
			status "Waited a long time for the machines to build you might want to take a look into why..."
			status "If you find that the build has failed for some reason you can shut the machines down from the ${CLOUDHOST} GUI system"
			status "######################################################################################################################"
		fi
	fi

	if ( [ "${NO_AUTOSCALERS}" -eq "0" ] && [ "${INPARALLEL}" = "1" ]  && [ "${DEVELOPMENT}" = "1" ] )
	then
		. ${BUILD_HOME}/buildscripts/BuildWebserver.sh &
		/bin/sleep 30
		. ${BUILD_HOME}/buildscripts/BuildDatabase.sh &

		tries="0"
		while ( [ "${NO_AUTOSCALERS}" -eq "0" ] && ( [ ! -f ${BUILD_HOME}/runtimedata/DATABASE_BUILT ] || [ ! -f ${BUILD_HOME}/runtimedata/WEBSERVER_BUILT ] ) && [ "${tries}" -lt "200" ] )
		do
			/bin/sleep 10
			tries="`/usr/bin/expr ${tries} + 1`"
		done
			
		if ( [ "${tries}" -eq "200" ] )
		then
			status "######################################################################################################################"
			status "Waited a long time for the machines to build. I'm going to try and finish up but you might want to take a look into why its taking so long..."
			status "If you find that the build has failed for some reason you can shut the machines down from the ${CLOUDHOST} GUI system"
			status "######################################################################################################################"
		fi
	fi

	if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
	then
		AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys"
		if ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -gt "1" ] )
		then
			as_active_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
		elif ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -eq "1" ] )
		then
			as_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
		fi
		ws_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "webserver" "${CLOUDHOST}"`"
		db_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "database" "${CLOUDHOST}"`"
	elif ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
	then
		if ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -gt "1" ] )
		then
			as_active_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
		elif ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -eq "1" ] )
		then
			as_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
		fi
		ws_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "webserver" "${CLOUDHOST}"`"
		db_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "database" "${CLOUDHOST}"`"
	fi

	AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys"
	OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "
	if ( [ "${as_active_ips}" != "" ] )
	then
		for ip in `/bin/echo ${as_active_ips} | /bin/sed 's/:/ /g'`
		do
			/usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/webserver_configuration_settings.dat >/dev/null 2>&1        
			/usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1    
		done
	elif ( [ "${as_active_ip}" != "" ] )
	then
		/usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh/webserver_configuration_settings.dat >/dev/null 2>&1        
		/usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1    
	fi
	
	if ( [ "${PRODUCTION}" = "1" ] )
	then
		status "Autoscaler, webserver and database built correctly....."
	elif ( [ "${DEVELOPMENT}" = "1" ] )
	then
		status "Webserver and database built correctly....."
	fi
	
	. ${BUILD_HOME}/providerscripts/security/firewall/TightenDBaaSFirewall.sh
	/bin/touch ${BUILD_HOME}/runtimedata//PRIME_FIREWALL
	cloudhost_holder="${CLOUDHOST}"
	. ${BUILD_HOME}/providerscripts/security/firewall/TightenBuildMachineFirewall.sh
	export CLOUDHOST="${cloudhost_holder}"


 	#################ADDED

	while ( [ ! -f ${BUILD_HOME}/buildconfiguration/configuration.php.default ] )
 	do
		${BUILD_HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ${WEBSITE_URL} configuration.php.default  ${BUILD_HOME}/buildconfiguration
 		/bin/sleep 10
   	done
    
	if ( [ -f ${BUILD_HOME}runtimedata/linode/DBaaS_HOSTNAME ] )
 	then
  		DB_HOSTNAME="`/bin/cat ${BUILD_HOME}runtimedata/${CLOUDHOST}/DBaaS_HOSTNAME`"
    	fi

     	if ( [ "${DB_HOSTNAME}" = "" ] )
      	then
      		if ( [ "${DBIP_PRIVATE}" = "" ] )
  		then
     			DBIP_PRIVATE="`/bin/ls ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBPRIVATEIP:* | /usr/bin/awk -F':' '{print $NF}'`"
		fi
 
		if ( [ "${DBIP}" = "" ] )
  		then
     			DBIP="`/bin/ls ${BUILD_HOME}/runtimedata/ips/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBIP:* | /usr/bin/awk -F':' '{print $NF}'`"
		fi
  	fi

   	. ${BUILD_HOME}/providerscripts/datastore/configwrapper/ObtainCredentials.sh

	dbprefix="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"
	secret="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} SECRET:*  | /usr/bin/awk -F':' '{print $NF}'`"
 	
  	/bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${dbprefix}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
  	/bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$dbtype /c\        public \$dbtype = \'mysqli\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$host = /c\   public \$host = \'${DBIP_PRIVATE}:${DB_PORT}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$user/c\       public \$user = \'${database_username}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$password/c\   public \$password = \'${database_password}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$db /c\        public \$db = \'${database_name}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default

	${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ${BUILD_HOME}/buildconfiguration/configuration.php.default joomla_configuration.php

     	############ADDED
      
	##Do the build finalisation procedures
	. ${BUILD_HOME}/buildscripts/FinaliseBuildProcessing.sh
fi
