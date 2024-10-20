/usr/bin/perl -i -pe 'BEGIN{undef $/;} s/^\$databases.\;/\$databases = [];/smg' ${HOME}/runtime/drupal_settings.php

if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] || [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
then
	credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${DATABASE}', \n 'username' => '${NAME}', \n 'password' => '${PASSWORD}', \n 'host' => '${HOST}', \n 'port' => '${DB_PORT}', \n 'driver' => 'pgsql', \n 'prefix' => '${prefix}', \n 'collation' => 'utf8mb4_general_ci',\n);"
	/bin/echo "${0} `/bin/date`: Set DB username, password, database name, hostname and port" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
else
	credentialstring="\$databases ['default']['default'] =array (\n 'database' => '${DATABASE}', \n 'username' => '${NAME}', \n 'password' => '${PASSWORD}', \n 'host' => '${HOST}', \n 'port' => '${DB_PORT}', \n 'driver' => 'mysql', \n 'prefix' => '${prefix}', \n 'collation' => 'utf8mb4_general_ci',\n);"
	/bin/echo "${0} `/bin/date`: Set DB username, password, database name, hostname and port" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi

/bin/sed -i "/^\$databases/{:1;/;/!{N;b 1}
	 s/.*/${credentialstring}/g}" ${HOME}/runtime/drupal_settings.php

if ( [ ! -d /var/www/tmp ] )
then
	/bin/mkdir -p /var/www/tmp
fi

/bin/chmod 755 /var/www/tmp
/bin/chown www-data:www-data /var/www/tmp

/bin/sed -i "/.*$settings\['file_temp_path'\]/c\$settings['file_temp_path'] = '/var/www/tmp';" ${HOME}/runtime/drupal_settings.php
	
salt="`/bin/cat /var/www/html/salt`"
	
if ( [ "${salt}" = "" ] )
then
	salt="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"
fi

/bin/sed -i "/^\$settings\['hash_salt'\]/c\$settings['hash_salt'] = '${salt}';" ${HOME}/runtime/drupal_settings.php

/bin/echo "${0} `/bin/date`: Set the salt value" >> ${HOME}/logs/OPERATIONAL_MONITORING.log


if ( [ "`/bin/grep 'ADDED BY CONFIG PROCESS' ${HOME}/runtime/drupal_settings.php`" = "" ] )
then
	/bin/echo "#====ADDED BY CONFIG PROCESS=====" >> ${HOME}/runtime/drupal_settings.php
	/bin/echo "\$settings['trusted_host_patterns'] = [ '.*' ];" >> ${HOME}/runtime/drupal_settings.php
	/bin/echo "\$settings['config_sync_directory'] = '/var/www/html/sites/default';" >> ${HOME}/runtime/drupal_settings.php
	/bin/echo "\$config['system.performance']['css']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php
	/bin/echo "\$config['system.performance']['js']['preprocess'] = FALSE;" >> ${HOME}/runtime/drupal_settings.php 
	/bin/echo "\$settings['file_private_path'] = \$app_root . '/../private';" >> ${HOME}/runtime/drupal_settings.php
 	/bin/echo "${0} `/bin/date`: Adjusted the drupal settings:  trusted_host_patterns, config_sync_directory, system.performance" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
fi
