#!/bin/sh
##############################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will copy our generated snapshots data to the datastore
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

snapshots_bucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-snaps"

if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
then
        datastore_tool="/usr/bin/s3cmd"
elif ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s5cmd" ] )
then
        host_base="`/bin/grep host_base /root/.s5cfg | /bin/grep host_base | /usr/bin/awk -F'=' '{print  $NF}' | /bin/sed 's/ //g'`" 
        datastore_tool="/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${host_base} "
fi

${datastore_tool} mb s3://${snapshots_bucket}
  
if ( [ "`${datastore_tool} ls s3://${snapshots_bucket}`" != "" ] )
then
        ${datastore_tool} get s3://${snapshots_bucket}/snapshots.tar.gz
fi

if ( [ ! -d ${BUILD_HOME}/snapshots ] )
then
        /bin/mkdir ${BUILD_HOME}/snapshots
fi

if ( [ -f ./snapshots.tar.gz ] )
then
        /bin/tar xvfz ./snapshots.tar.gz -C ${BUILD_HOME}/snapshots
fi

path="`/usr/bin/pwd`"

cd ${BUILD_HOME}/snapshots

/bin/tar cvfz ./snapshots.tar.gz *

if ( [ "`${datastore_tool} ls s3://${snapshots_bucket}`" = "" ] )
then
        ${datastore_tool} mb s3://${snapshots_bucket}
fi

${datastore_tool} mv s3://${snapshots_bucket}/snapshots.tar.gz s3://${snapshots_bucket}/snapshots.tar.gz.$$
${datastore_tool} put ./snapshots.tar.gz s3://${snapshots_bucket}/
/bin/rm ./snapshots.tar.gz

if ( [ -f ./snapshots.tar.gz ] )
then
        /bin/rm ./snapshots.tar.gz
fi

cd ${path}
