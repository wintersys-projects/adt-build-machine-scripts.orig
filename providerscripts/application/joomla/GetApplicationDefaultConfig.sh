	while ( [ ! -f ${BUILD_HOME}/buildconfiguration/configuration.php.default ] )
 	do
		${BUILD_HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ${WEBSITE_URL} configuration.php.default  ${BUILD_HOME}/buildconfiguration
 		/bin/sleep 10
   	done
