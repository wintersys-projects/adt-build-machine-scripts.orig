#!/bin/sh
####################################################################################
# Description: This sets the bare minimum configuration.php values to get the joomla
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
 
dbprefix="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"
secret="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} SECRET:*  | /usr/bin/awk -F':' '{print $NF}'`"
 	
/bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${dbprefix}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
/bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
/bin/sed -i "/\$user/c\       public \$user = \'${database_username}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
/bin/sed -i "/\$password/c\   public \$password = \'${database_password}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
/bin/sed -i "/\$db /c\        public \$db = \'${database_name}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default

if ( [ "${DATABASE_INSTALLATION_TYPE}" = "Postgres" ] )
then
	/bin/sed -i "/\$dbtype /c\        public \$dbtype = \'pgsql\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$port /d" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$host /c\        public \$host = \'${db_identifier}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
	/bin/sed -i "/\$host /a        public \$port = \'${DB_PORT}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
else
 /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'mysqli\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
 /bin/sed -i "/\$host = /c\   public \$host = \'${db_identifier}:${DB_PORT}\';" ${BUILD_HOME}/buildconfiguration/configuration.php.default
fi

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ${BUILD_HOME}/buildconfiguration/configuration.php.default joomla_configuration.php

/bin/rm ${BUILD_HOME}/buildconfiguration/configuration.php.default
