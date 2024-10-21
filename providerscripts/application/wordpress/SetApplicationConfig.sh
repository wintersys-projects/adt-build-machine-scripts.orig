
dbprefix="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"

/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${database_identifier}:${DB_PORT}\");" ${BUILD_HOME}/buildconfiguration/wp-config-sample.php
/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${database_username}\");" ${BUILD_HOME}/buildconfiguration/wp-config-sample.php
/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${database_password}\");" ${BUILD_HOME}/buildconfiguration/wp-config-sample.php
/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${database_name}\");" ${BUILD_HOME}/buildconfiguration/wp-config-sample.php
/bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${dbprefix}\";" ${BUILD_HOME}/buildconfiguration/wp-config-sample.php

/bin/sed -i "/'AUTH_KEY'/i XXYYZZ" ${BUILD_HOME}/buildconfiguration/wp-config-sample.php
/bin/sed -i '/AUTH_KEY/,+7d' ${BUILD_HOME}/buildconfiguration/wp-config-sample.php
salts="`/usr/bin/curl https://api.wordpress.org/secret-key/1.1/salt`"
/bin/sed -n '/XXYYZZ/q;p' ${BUILD_HOME}/buildconfiguration/wp-config-sample.php > /tmp/firsthalf
/bin/sed '0,/^XXYYZZ$/d' ${BUILD_HOME}/buildconfiguration/wp-config-sample.php > /tmp/secondhalf
/bin/cat /tmp/firsthalf > /tmp/fullfile
/bin/echo ${salts} >> /tmp/fullfile
/bin/echo "/* SALTEDALREADY */" >> /tmp/fullfile
/bin/echo "define( 'DISALLOW_FILE_EDIT', true );" >> /tmp/fullfile
/bin/echo "define( 'WP_DEBUG', false );" >> /tmp/fullfile
/bin/echo "define('WP_CACHE', false);" >> /tmp/fullfile
/bin/echo "define('CONCATENATE_SCRIPTS', true);" >> /tmp/fullfile
/bin/echo "define('COMPRESS_SCRIPTS', true);" >> /tmp/fullfile
/bin/echo "define('COMPRESS_CSS', true);" >> /tmp/fullfile
/bin/echo "define('DISABLE_WP_CRON', true);" >> /tmp/fullfile
/bin/cat /tmp/secondhalf >> /tmp/fullfile
/bin/rm /tmp/firsthalf /tmp/secondhalf
/bin/mv /tmp/fullfile ${BUILD_HOME}/buildconfiguration/wp-config-sample.php

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ${BUILD_HOME}/buildconfiguration/wp-config-sample.php wordpress_config.php

/bin/rm ${BUILD_HOME}/buildconfiguration/wp-config-sample.php
