#!/bin/sh
####################################################################################
# Description: This will set the application configuration for use by the webservers
# The application configuration (for example configuration.php for Joomla) will be
# set here and uploaded to the config bucket in the datastore and the websevers will
# pull the configuration from there. You can extend the application specific settings
# to any level of detail right the way up to configuring every configurable setting 
# if you chose to. What I do here is set the bare minimum to get the application 
# online which basically means database and hostname/ip address
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
     
. ${BUILD_HOME}/providerscripts/application/${APPLICATION}/GetApplicationDefaultConfig.sh

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/DBaaS_HOSTNAME ] )
then
        DB_HOSTNAME="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/DBaaS_HOSTNAME`"
fi

if ( [ "${DB_HOSTNAME}" = "" ] )
then
        if ( [ "${DBIP_PRIVATE}" = "" ] )
        then
                DBIP_PRIVATE="`/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}/ips/${BUILD_IDENTIFIER}/DBPRIVATEIP:* | /usr/bin/awk -F':' '{print $NF}'`"
        fi
 
        if ( [ "${DBIP}" = "" ] )
        then
                DBIP="`/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}/ips/${BUILD_IDENTIFIER}/DBIP:* | /usr/bin/awk -F':' '{print $NF}'`"
        fi
fi

. ${BUILD_HOME}/providerscripts/datastore/configwrapper/ObtainCredentials.sh

if ( [ "${DB_HOSTNAME}" != "" ] )
then
     database_identifier="${DB_HOSTNAME}"
else
     database_identifier="${DBIP_PRIVATE}"
fi

. ${BUILD_HOME}/providerscripts/application/${APPLICATION}/SetApplicationConfig.sh

