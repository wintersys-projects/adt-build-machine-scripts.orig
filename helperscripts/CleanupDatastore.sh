#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : You can use this script to remove buckets from your datastore
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

if ( [ ! -f  ./CleanupDatastore.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which datastore service are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
	DATASTORE_PROVIDER="digitalocean"
	token_to_match="autoscaler"
elif ( [ "${response}" = "2" ] )
then
	DATASTORE_PROVIDER="exoscale"
	token_to_match="autoscaler"
elif ( [ "${response}" = "3" ] )
then
	DATASTORE_PROVIDER="linode"
	token_to_match="autoscaler"
elif ( [ "${response}" = "4" ] )
then
	DATASTORE_PROVIDER="vultr"
	token_to_match="autoscaler"
else
	/bin/echo "Unrecognised  cloudhost. Exiting ...."
	exit
fi

buckets="`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${DATASTORE_PROVIDER} "" | /usr/bin/awk '{print $NF}' | /bin/sed 's,s3://,,'`"

for bucket in ${buckets}
do
	/bin/echo "Have found bucket: ${bucket} do you want to delete it, (Y|N)"
	read response

	if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
	then
		${BUILD_HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${DATASTORE_PROVIDER} "${bucket}"
		${BUILD_HOME}/providerscripts/datastore/DeleteDatastore.sh ${DATASTORE_PROVIDER} "${bucket}"
	fi
done
