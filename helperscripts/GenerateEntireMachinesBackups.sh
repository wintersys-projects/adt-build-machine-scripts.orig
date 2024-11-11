#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/01/2022
# Description : This script will adjust the scaling settings for your infrastructure
########################################################################################################
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

if ( [ ! -f  ./GenerateEntireMachinesBackups.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which cloudhost service are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
	CLOUDHOST="digitalocean"
elif ( [ "${response}" = "2" ] )
then
	CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
	CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
	CLOUDHOST="vultr"
else
	/bin/echo "Unrecognised  cloudhost. Exiting ...."
	exit
fi

/bin/echo "What is the build identifier you want to allow access for?"
/bin/echo "You have these builds to choose from: "

if ( [ -d ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} ] )
then
        /bin/ls ${BUILD_HOME}/buildconfiguration/${CLOUDHOST} | /bin/grep -v 'credentials'
else
        /bin/echo "No eligible builds found"
        exit
fi

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

SERVER_USERNAME="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSER`"
SERVER_USER_PASSWORD="`/bin/cat ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SERVERUSERPASSWORD`"

SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

${BUILD_HOME}/helperscripts/ExecuteOnAutoscaler.sh "${SUDO} /bin/rm /tmp/backup.tgz 2>/dev/null ; ${SUDO} /home/${SERVER_USERNAME}/providerscripts/backupscripts/BackupEntireMachine.sh"
${BUILD_HOME}/helperscripts/ExecuteOnWebserver.sh "${SUDO} /bin/rm /tmp/backup.tgz 2>/dev/null  ; ${SUDO} /home/${SERVER_USERNAME}/providerscripts/backupscripts/BackupEntireMachine.sh"
${BUILD_HOME}/helperscripts/ExecuteOnDatabase.sh "${SUDO} /bin/rm /tmp/backup.tgz 2>/dev/null ; ${SUDO} /home/${SERVER_USERNAME}/providerscripts/backupscripts/BackupEntireMachine.sh"
