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
