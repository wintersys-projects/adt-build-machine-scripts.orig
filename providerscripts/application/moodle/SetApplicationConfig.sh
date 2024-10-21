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
 	
#Set session handler to be database. May (will) get issues if trying to use filesystem
/bin/sed -i '/\/\/.*\\core\\session\\database/s/^\/\///' ${BUILD_HOME}/buildconfiguration/config.php 
/bin/sed -i '/\/\/.*session_database_acquire_lock_timeout/s/^\/\///' ${BUILD_HOME}/buildconfiguration/config.php 

#if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:DBaaS`" = "1" ] )
#then
#	if ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Maria`" = "1" ] )
#	then
#		/bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php 
#		/bin/echo "${0} `/bin/date`: setting dbtype to mariadb" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
#	elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:MySQL`" = "1" ] )
#	then
#		/bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php 
#		/bin/echo "${0} `/bin/date`: setting dbtype to mysqli" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
#	elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEDBaaSINSTALLATIONTYPE:Postgres`" = "1" ] )
#	then
#		/bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php 
#		/bin/echo "${0} `/bin/date`: setting dbtype to pgsql" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
#	fi
#elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Maria`" = "1" ] )
#then
#	/bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${HOME}/runtime/moodle_config.php 
#	/bin/echo "${0} `/bin/date`: setting dbtype to mariadb" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
#elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:MySQL`" = "1" ] )
#then
#	/bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mysqli\";" ${HOME}/runtime/moodle_config.php 
#	/bin/echo "${0} `/bin/date`: setting dbtype to mysqli" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
#elif ( [ "`${HOME}/providerscripts/utilities/CheckConfigValue.sh DATABASEINSTALLATIONTYPE:Postgres`" = "1" ] )
#then
#	/bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"pgsql\";" ${HOME}/runtime/moodle_config.php 
#	/bin/echo "${0} `/bin/date`: setting dbtype to pgsql" >> ${HOME}/logs/OPERATIONAL_MONITORING.log
#fi

	/bin/sed -i "/->dbtype /c\    \$CFG->dbtype    = \"mariadb\";" ${BUILD_HOME}/buildconfiguration/config.php 
	/bin/sed -i "/->dbuser /c\    \$CFG->dbuser    = \"${database_username}\";" ${BUILD_HOME}/buildconfiguration/config.php
	/bin/sed -i "/->dbname /c\    \$CFG->dbname    = \"${database_name}\";" ${BUILD_HOME}/buildconfiguration/config.php 
	/bin/sed -i "/->dbpass /c\    \$CFG->dbpass    = \"${database_password}\";" ${BUILD_HOME}/buildconfiguration/config.php
	/bin/sed -i "/->dbhost /c\    \$CFG->dbhost    = \"${database_identifier}\";" ${BUILD_HOME}/buildconfiguration/config.php
	/bin/sed -i "/dbport/c\     \'dbport\' => \'${DB_PORT}\'," ${BUILD_HOME}/buildconfiguration/config.php 
	/bin/sed -i "0,/\$CFG->wwwroot/ s/\$CFG->wwwroot.*/\$CFG->wwwroot = \"https:\/\/${WEBSITE_URL}\/moodle\";/" ${BUILD_HOME}/buildconfiguration/config.php
	/bin/sed -i "0,/\$CFG->dataroot/ s/\$CFG->dataroot.*/\$CFG->dataroot = \'\/var\/www\/html\/moodledata\';/" ${BUILD_HOME}/buildconfiguration/config.php 

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ${BUILD_HOME}/buildconfiguration/config.php moodle_config.php
/bin/rm ${BUILD_HOME}/buildconfiguration/config.php
