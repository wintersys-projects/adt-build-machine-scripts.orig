#!/bin/sh
####################################################################################
# Description: This sets the bare minimum config.php values to get the wordpress
# application online
# Date: 07/11/2024
# Author: Peter Winter
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
#####################################################################################
#####################################################################################
#set -x

#dbprefix="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ ! -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/dbp.dat ] )
then
 status "Error, cannot find database prefix file"
fi

dbprefix="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/dbp.dat`"
/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${database_identifier}:${DB_PORT}\");" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php
/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${database_username}\");" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php
/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${database_password}\");" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php
/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${database_name}\");" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php
/bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${dbprefix}\";" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php

/bin/sed -i "/'AUTH_KEY'/i XXYYZZ" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php
/bin/sed -i '/AUTH_KEY/,+7d' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php
salts="`/usr/bin/curl https://api.wordpress.org/secret-key/1.1/salt`"
/bin/sed -n '/XXYYZZ/q;p' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php > /tmp/firsthalf
/bin/sed '0,/^XXYYZZ$/d' ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php > /tmp/secondhalf
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
/bin/mv /tmp/fullfile ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php wordpress_config.php


