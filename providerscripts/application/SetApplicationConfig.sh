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

