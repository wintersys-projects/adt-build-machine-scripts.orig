#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Get a file from a bucket in the datastore
######################################################################################
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

datastore_provider="$1"
datastore_to_get="`/bin/echo $2 | /usr/bin/cut -c-63`"

if ( [ "$#" = "3" ] )
then
        BUILD_HOME="$3"
elif ( [ "$#" = "4" ] )
then
        BUILD_HOME="$4"
fi

if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
then
        datastore_tool="/usr/bin/s3cmd"
elif ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s5cmd" ] )
then
        host_base="`/bin/grep host_base /root/.s5cfg | /bin/grep host_base | /usr/bin/awk -F'=' '{print  $NF}' | /bin/sed 's/ //g'`" 
        datastore_tool="/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${host_base} "
fi

if ( [ "${BUILD_HOME}" = "" ]  || [ "`/usr/bin/pwd | /bin/grep 'helperscripts'`" != "" ] )
then 
        BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/\/helperscripts//g'`"
fi

if ( [ "${3}" != "" ] )
then
        ${datastore_tool} --force --recursive get s3://${datastore_to_get} ${3}
else
        ${datastore_tool} --force --recursive get s3://${datastore_to_get}
fi
