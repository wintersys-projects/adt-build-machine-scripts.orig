
dbprefix="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"

/usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${BUILD_HOME}/buildconfiguration/settings.php

if ( [ "${DATABASE_INSTALLATION_TYPE}" = "Postgres" ] )
then
	credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${DATABASE}', \n 'username' => '${NAME}', \n 'password' => '${PASSWORD}', \n 'host' => '${HOST}', \n 'port' => '${DB_PORT}', \n 'driver' => 'pgsql', \n 'prefix' => '${dbprefix}', \n 'collation' => 'utf8mb4_general_ci',\n);"
else
	credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${DATABASE}', \n 'username' => '${NAME}', \n 'password' => '${PASSWORD}', \n 'host' => '${HOST}', \n 'port' => '${DB_PORT}', \n 'driver' => 'mysql', \n 'prefix' => '${dbprefix}', \n 'collation' => 'utf8mb4_general_ci',\n);"
fi

/bin/sed -i "/^\$databases/{:1;/;/!{N;b 1}
	 s/.*/${credentialstring}/g}" ${BUILD_HOME}/buildconfiguration/settings.php

/bin/sed -i "/.*$settings\['file_temp_path'\]/c\$settings['file_temp_path'] = '/var/www/tmp';" ${BUILD_HOME}/buildconfiguration/settings.php
	
salt="`/bin/cat /var/www/html/salt`"
	
if ( [ "${salt}" = "" ] )
then
	salt="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
fi

/bin/sed -i "/^\$settings\['hash_salt'\]/c\$settings['hash_salt'] = '${salt}';" ${BUILD_HOME}/buildconfiguration/settings.php


if ( [ "`/bin/grep 'ADDED BY CONFIG PROCESS' ${BUILD_HOME}/buildconfiguration/settings.php`" = "" ] )
then
	/bin/echo "#====ADDED BY CONFIG PROCESS=====" >> ${BUILD_HOME}/buildconfiguration/settings.php
	/bin/echo "\$settings['trusted_host_patterns'] = [ '.*' ];" >> ${BUILD_HOME}/buildconfiguration/settings.php
	/bin/echo "\$settings['config_sync_directory'] = '/var/www/html/sites/default';">>  ${BUILD_HOME}/buildconfiguration/settings.php
	/bin/echo "\$config['system.performance']['css']['preprocess'] = FALSE;" >> ${BUILD_HOME}/buildconfiguration/settings.php
	/bin/echo "\$config['system.performance']['js']['preprocess'] = FALSE;" >> ${BUILD_HOME}/buildconfiguration/settings.php 
	/bin/echo "\$settings['file_private_path'] = \$app_root . '/../private';" >> ${BUILD_HOME}/buildconfiguration/settings.php
 	/bin/echo "${0} `/bin/date`: Adjusted the drupal settings:  trusted_host_patterns, config_sync_directory, system.performance" >> ${BUILD_HOME}/buildconfiguration/settings.php
fi
