#!/bin/sh
####################################################################################
# Author: Peter Winter
# Date :  24/02/2022
# Description: This will get a particular file to the configuration datastore
#######################################################################################
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
######################################################################################
######################################################################################
#set -x

BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/\/helperscripts//g'`"

WEBSITE_URL="${1}"
configbucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`"
configbucket="${configbucket}-config"

if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
then
  if ( [ -f ${2} ] )
	then
	  /usr/bin/s3cmd get s3://${configbucket}$2 $3 
	elif ( [ -f ./${2} ] )
	then
	  /usr/bin/s3cmd put s3://${configbucket}$2 $3
		/bin/rm ./$2
	elif ( [ -f /tmp/${2} ] )
	then
	  /usr/bin/s3cmd put s3://${configbucket}$2 /tmp/$3 
	else
	  directory="`/bin/echo ${1} | /usr/bin/awk -F'/' 'NF{NF-=1};1' | /bin/sed 's/ /\//g'`"
		/bin/mkdir -p /tmp/${directory}
		/bin/touch /tmp/$2
		/usr/bin/s3cmd put s3://${configbucket}$2 /tmp/$3
		/bin/rm /tmp/$2
	fi
fi
