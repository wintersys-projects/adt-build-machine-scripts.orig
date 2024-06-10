#!/bin/sh
################################################################################################################################################
# Description: Not all applications play the same, so if you have some particular post processing messages and so on that you need to display
# then you can add them here and they will be displayed to the user at the end of the build process
# Author: Peter Winter
# Date: 17/01/2017
################################################################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

WEBSERVER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_keys"
OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${WEBSERVER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "

status "###############################################################################################################################"
/usr/bin/banner "IMPORTANT" >&3

if ( [ "${BASELINE_DB_REPOSITORY}" = "VIRGIN" ] )
then
	status "###############################################################################################################################"
	status "OK, I'll be kind and show you one time your ${APPLICATION} database credentials."
	status "Please make a note of them but remember to keep them safe and secret"
	status "You can enter them in the GUI system when you install the application"
	status "#########################################"
	. ${BUILD_HOME}/providerscripts/datastore/configwrapper/DisplayCredentials.sh
	status "#########################################"
	status "The database IP address is: ${db_active_ip}"
	status "The database port is ${DB_PORT}"
	status "You can make up your own database prefix but make sure to include the '_' character at the end of your prefix (for example 'dbprefix_')"
	status "#########################################"

	if ( [ "${APPLICATION}" = "joomla" ] && [ "${DB_PORT}" != "3306" ] && [ "${DB_PORT}" != "5432" ] )
	then
		status "You are not using the default port for your database"
		status "REMEMBER to tell joomla this by putting the database hostname as ${db_active_ip}:${DB_PORT} when you enter it in the GUI during the install process"
		status "######################################"
	fi
	
	if ( [ "${APPLICATION}" = "wordpress" ] && [ "${DB_PORT}" != "3306" ] )
	then
		status "You are not using the default port for your database"
		status "REMEMBER to tell wordpress this by putting the database hostname as ${db_active_ip}:${DB_PORT} when you enter it in the GUI during the install process"
		status "######################################"
	fi

	if ( [ "${APPLICATION}" = "joomla" ] )
	then
		status ""
		status "##################################################################################################"
		status "To complete the installation of joomla please go to https://${WEBSITE_URL}/installation/index.php"
		status "##################################################################################################"
		status ""
	fi

	if ( [ "${APPLICATION}" = "drupal" ] )
	then
		status ""
		status "####################################################################"
		status "Waiting for the application install to have been completed at: https://${WEBSITE_URL}/core/install.php"
		status "Use the credentials listed above please"
		status ""

		while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${SUDO} /home/${SERVER_USER}/providerscripts/application/processing/drupal/CheckUser.sh"`" != "USER ADDED" ] )
		do
			/bin/sleep 15
		done
	fi
	
	if ( [ "${APPLICATION}" = "moodle" ] )
	then
		status ""
		status "####################################################################"
		status "Moodle should be available at: https://${WEBSITE_URL}/moodle"
		status "The default admin user has the username: admin123 and password: changeme17832"
		status "As implied you should change both of these immediately using the Moodle administration gui"
		status ""
	fi
fi

if ( [ "${APPLICATION}" = "drupal" ] )
then
	status "####################################################################"
	status "Attempting to truncate cache ready for the application to be usable"
	status "####################################################################"

	while ( [ "`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${ws_active_ip} "${SUDO} /home/${SERVER_USER}/providerscripts/application/processing/drupal/TruncateCache.sh"`" != "TRUNCATED" ] )
	do
		/bin/sleep 60
	done
fi

if ( [ "${APPLICATION}" = "wordpress" ] )
then
	status "========================================================================================================================================="
	status "If you have trouble accessing your new wordpress site, one thing that might be wrong is permalinks within wordpress"
	status "In this case, go to https://${WEBSITE_URL}/wp-admin, login and rebuild permalinks under settings->permalinks"
	status "========================================================================================================================================="
fi

status "#############################BUILD-MACHINE_FIREWALL###############################################################################################"
status "Your build machine is looking for its firewall settings in the bucket: `/usr/bin/crontab -l | /bin/grep TightenBuild | /usr/bin/awk '{print $NF}'`"
status "Please review: https://github.com/${INFRASTRUCTURE_REPOSITORY_OWNER}/adt-build-machine-scripts/blob/main/doco/AgileToolkitDeployment/TightenBuildMachineAccess.md"
status "##################################################################################################################################################"

status "################################IMPORTANT#############################################################################################"
status "REMEMBER TO CONSULT: "
status "    ${BUILD_HOME}/doco/AgileToolkitDeployment/ApplicationConfigurationUpdate.md"
status "FOR HOW TO PERFORM APPLICATION CONFIGURATION UPDATES WITH THIS TOOLKIT"
status "################################IMPORTANT#############################################################################################"

