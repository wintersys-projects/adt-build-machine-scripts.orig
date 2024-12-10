#!/bin/sh
#################################################################################
# Description: Ths script will work out what kind of application you are deploying
# from a backup stored in your datastore
# Author: Peter Winter
# Date: 02/01/2017
#################################################################################
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
###################################################################################
###################################################################################
#set -x

status () {
	/bin/echo "$1" | /usr/bin/tee /dev/fd/3 2>/dev/null
}

APPLICATION=""

#################JOOMLA################
if ( [ -d ${interrogation_home}/tmp/backup/administrator ] && [ -d ${interrogation_home}/tmp/backup/modules ] && [ -d ${interrogation_home}/tmp/backup/plugins ] && [ -d ${interrogation_home}/tmp/backup/templates ] )
then
	/bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:joomla
	APPLICATION="joomla"
	if ( [ "${DIRECTORIES_TO_MOUNT}" = "" ] )
	then
		DIRECTORIES_TO_MOUNT="images"
	fi
	status "Discovered you are deploying joomla from a datastore backup"
	status "Press the <enter> key to accept as true"
	if ( [ "${HARDCORE}" != "1" ] )
	then
		read x
	fi
 	/bin/cp ${interrogation_home}/tmp/backup/configuration.php.default ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
	if ( [ ! -f ${interrogation_home}/tmp/backup/dbp.dat ] )
 	then
  		status "Error, cannot find db prefix file"
    	fi
 	/bin/cp ${interrogation_home}/tmp/backup/dbp.dat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}
 #################JOOMLA################
	#################WORDPRESS################
elif ( [ -f ${interrogation_home}/tmp/backup/wp-login.php ] && [ -d ${interrogation_home}/tmp/backup/wp-content ] && [ -f ${interrogation_home}/tmp/backup/wp-cron.php ] && [ -d ${interrogation_home}/tmp/backup/wp-admin ] && [ -d ${interrogation_home}/tmp/backup/wp-includes ] && [ -f ${interrogation_home}/tmp/backup/wp-settings.php ] )
then
	/bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:wordpress
	APPLICATION="wordpress"
	if ( [ "${DIRECTORIES_TO_MOUNT}" = "" ] )
	then
		DIRECTORIES_TO_MOUNT="wp-content.uploads"
	fi
	status "Discovered you are deploying wordpress from a datastore backup"
	status "Press the <enter> key to accept as true"
	if ( [ "${HARDCORE}" != "1" ] )
	then
		read x
	fi
  	/bin/cp ${interrogation_home}/tmp/backup/wp-config-sample.php ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/wp-config-sample.php
	
 	if ( [ ! -f ${interrogation_home}/tmp/backup/dbp.dat ] )
 	then
  		status "Error, cannot find db prefix file"
    	fi
     
 	/bin/cp ${interrogation_home}/tmp/backup/dbp.dat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}
	#################WORDPRESS################
	#################MOODLE################
elif ( [ -f ${interrogation_home}/tmp/backup/moodle/index.php ] && [ -f ${interrogation_home}/tmp/backup/moodle/version.php ] && [ -d ${interrogation_home}/tmp/backup/moodle/userpix ] && [ -d ${interrogation_home}/tmp/backup/moodle/report ] && [ -d ${interrogation_home}/tmp/backup/moodle/enrol ] && [ -d ${interrogation_home}/tmp/backup/moodle/theme ] )
then
	/bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:moodle
	APPLICATION="moodle"
	if ( [ "${DIRECTORIES_TO_MOUNT}" = "" ] )
	then
		DIRECTORIES_TO_MOUNT="moodledata.filedir"
	fi
	status "Discovered you are deploying moodle from a datastore backup"
	status "Press the <enter> key to accept as true"
	if ( [ "${HARDCORE}" != "1" ] )
	then
		read x
	fi
   	/bin/cp ${interrogation_home}/tmp/backup/config.php ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/config.php
	
 	if ( [ ! -f ${interrogation_home}/tmp/backup/dbp.dat ] )
 	then
  		status "Error, cannot find db prefix file"
    	fi
     
 	/bin/cp ${interrogation_home}/tmp/backup/dbp.dat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}
	#################MOODLE################
	#################DRUPAL################
elif ( [ -f ${interrogation_home}/tmp/backup/core/misc/drupal.js ] && [ -d ${interrogation_home}/tmp/backup/themes ] && [ -d ${interrogation_home}/tmp/backup/vendor ] && [ -d ${interrogation_home}/tmp/backup/modules ] && [ -d ${interrogation_home}/tmp/backup/profiles ] )
then
	/bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/APPLICATION:drupal
	APPLICATION="drupal"
	if ( [ "${DIRECTORIES_TO_MOUNT}" = "" ] )
	then
		DIRECTORIES_TO_MOUNT="sites.default.files.pictures:sites.default.files.styles:sites.default.files.inline-images"
	fi
	status "Discovered you are deploying drupalfrom a datastore backup"
	status "Press the <enter> key to accept as true"
	if ( [ "${HARDCORE}" != "1" ] )
	then
		read x
	fi
    	/bin/cp ${interrogation_home}/tmp/backup/settings.php ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/settings.php
	
 	if ( [ ! -f ${interrogation_home}/tmp/backup/dbp.dat ] )
 	then
  		status "Error, cannot find db prefix file"
    	fi
     
 	/bin/cp ${interrogation_home}/tmp/backup/dbp.dat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}
	#################DRUPAL################
fi

if ( [ "${APPLICATION}" = "" ] )
then
	status "Couldn't find a recognised application type. If you are sure you are OK with this, hit <enter> otherwise <ctrl-c> and have a look into what is going on"
	if ( [ "${HARDCORE}" != "1" ] )
	then
		read x
	fi
fi
