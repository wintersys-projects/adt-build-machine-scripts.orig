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

BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/\/helperscripts//g'`"

config_bucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-config"

if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
then
	if ( [ "`/usr/bin/s3cmd ls s3://${config_bucket}`" != "" ] )
	then
		/usr/bin/s3cmd --force get s3://${config_bucket}/credentials/shit
		if ( [ "${DATASTORE_CHOICE}" = "digitalocean" ] || [ "${DATASTORE_CHOICE}" = "exoscale" ] || [ "${DATASTORE_CHOICE}" = "linode" ] || [ "${DATASTORE_CHOICE}" = "vultr" ] )
		then
			config_bucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-config"
	
			if ( [ "`/usr/bin/s3cmd ls s3://${config_bucket}`" != "" ] )
			then
				/usr/bin/s3cmd --force get s3://${config_bucket}/credentials/shit
				
				if ( [ "${HARDCORE}" = "1" ] )
				then
					/bin/echo "Database name: `/bin/sed 1!d ./shit`" 
					/bin/echo "Database username: `/bin/sed 3!d ./shit`" 
					/bin/echo "Database password: `/bin/sed 2!d ./shit`" 
     					database_name="`/bin/sed 1!d ./shit`"
	  				database_username="`/bin/sed 3!d ./shit`"
       					database_password="`/bin/sed 2!d ./shit`"
				else  
					/bin/echo "Database name: `/bin/sed 1!d ./shit`" >&3
     					/bin/echo "Database username: `/bin/sed 3!d ./shit`" >&3
					/bin/echo "Database password: `/bin/sed 2!d ./shit`" >&3
     					database_name="`/bin/sed 1!d ./shit`"
	  				database_username="`/bin/sed 3!d ./shit`"
       					database_password="`/bin/sed 2!d ./shit`"
				fi
			fi
		fi
	fi
fi
