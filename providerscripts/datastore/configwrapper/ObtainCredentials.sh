#!/bin/sh
##############################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will copy our generated config file for a particular
# provider over to our new machine
###############################################################################
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
#################################################################################
#################################################################################
#set -x

BUILD_HOME="`/bin/cat /home/buildhome.dat`"
CLOUDHOST="`/bin/cat ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST`"
BUILD_IDENTIFIER="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER`"
SERVER_USER="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSER`"
TOKEN="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

config_bucket="`/bin/echo "${WEBSITE_URL}"-config | /bin/sed 's/\./-/g'`-${TOKEN}"

if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
then
        datastore_tool="/usr/bin/s3cmd "
	datastore_tool_1="/usr/bin/s3cmd --force get "
elif ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s5cmd" ] )
then
        host_base="`/bin/grep host_base /root/.s5cfg | /bin/grep host_base | /usr/bin/awk -F'=' '{print  $NF}' | /bin/sed 's/ //g'`" 
        datastore_tool="/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${host_base} "
	datastore_tool_1="/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${host_base} cp "
 	destination="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}"
fi

if ( [ "`${datastore_tool} ls s3://${config_bucket}`" != "" ] )
then
	${datastore_tool_1} s3://${config_bucket}/credentials/shit ${destination}
	if ( [ "${DATASTORE_CHOICE}" = "digitalocean" ] || [ "${DATASTORE_CHOICE}" = "exoscale" ] || [ "${DATASTORE_CHOICE}" = "linode" ] || [ "${DATASTORE_CHOICE}" = "vultr" ] )
	then	
		if ( [ "`${datastore_tool} ls s3://${config_bucket}`" != "" ] )
		then
			${datastore_tool_1} s3://${config_bucket}/credentials/shit ${destination}
				
			if ( [ "${HARDCORE}" = "1" ] )
			then
    				if ( [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
	 			then
					/bin/echo "Database name: `/bin/sed 1!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`" 
					/bin/echo "Database username: `/bin/sed 3!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`" 
					/bin/echo "Database password: `/bin/sed 2!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`" 
     				else
	  				database_name="`/bin/sed 1!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`"
	  				database_username="`/bin/sed 3!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`"
       					database_password="`/bin/sed 2!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`"
				fi
			else
	    			if ( [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
	 			then
					/bin/echo "Database name: `/bin/sed 1!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`" >&3
     					/bin/echo "Database username: `/bin/sed 3!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`" >&3
					/bin/echo "Database password: `/bin/sed 2!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`" >&3
     				else
	  				database_name="`/bin/sed 1!d .${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`"
	  				database_username="`/bin/sed 3!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`"
       					database_password="`/bin/sed 2!d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/shit`"
	     			fi
			fi
		fi
	fi
fi

