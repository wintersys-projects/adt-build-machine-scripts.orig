#!/bin/sh
######################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Lists files from a bucket in the datastore
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
#######################################################################################
#######################################################################################
#set -x

datastore_provider="$1"
file_to_list="$2"
BUILD_HOME="$3"

if ( [ "${BUILD_HOME}" = "" ] )
then 
        BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/\/helperscripts//g'`"
fi


if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
then
        datastore_tool="/usr/bin/s3cmd"
fi

${datastore_tool} --force ls s3://${file_to_list} 2>/dev/null
