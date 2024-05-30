#!/bin/sh
######################################################################################################################
# Description: This is the script will get the snapshot IDs that we can build from 
# Author: Peter Winter
# Date: 17/01/2017
######################################################################################################################
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
######################################################################################################
#set -x

if ( [ "${SNAPSHOT_ID}" = "" ] )
then
	if ( [ "${autoscaler_name}" != "" ] )
	then
		SNAPSHOT_ID="`/bin/echo ${autoscaler_name} | grep -aoE -e '[A-Z]{4}'`"
	fi
fi

if ( [ "${SNAPSHOT_ID}" != "" ] )
then
	if ( [ "${CLOUDHOST}" = "digitalocean" ] )
	then
		WEBSERVER_SNAPSHOT_NAME="`/usr/local/bin/doctl compute snapshot list | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $2}'`"
		WEBSERVER_IMAGE_ID="`/usr/local/bin/doctl compute snapshot list | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
		AUTOSCALER_IMAGE_ID="`/usr/local/bin/doctl compute snapshot list | /bin/grep autoscaler | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
		DATABASE_IMAGE_ID="`/usr/local/bin/doctl compute snapshot list | /bin/grep database | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
	fi 

	if ( [ "${CLOUDHOST}" = "exoscale" ] )
	then
		WEBSERVER_SNAPSHOT_NAME="`/usr/bin/exo -O json vm template list --mine --zone ${REGION} | /usr/bin/jq --arg tmp_instance_name "${webserver_name}" '(.[] | select (.name | contains("webserver")  and  contains($tmp_instance_name)) | .name)' | /bin/sed 's/"//g'`"
		AUTOSCALER_IMAGE_ID="`/usr/bin/exo -O json vm template list --mine --zone ${REGION} | /usr/bin/jq --arg tmp_instance_name "${autoscaler_name}" '(.[] | select (.name | contains("autoscaler")  and  contains($tmp_instance_name)) | .id)' | /bin/sed 's/"//g'`"
		WEBSERVER_IMAGE_ID="`/usr/bin/exo -O json vm template list --mine --zone ${REGION} | /usr/bin/jq --arg tmp_instance_name "${webserver_name}" '(.[] | select (.name | contains("webserver")  and  contains($tmp_instance_name)) | .id)' | /bin/sed 's/"//g'`"
		DATABASE_IMAGE_ID="`/usr/bin/exo -O json vm template list --mine --zone ${REGION} | /usr/bin/jq --arg tmp_instance_name "${database_name}" '(.[] | select (.name | contains("database")  and  contains($tmp_instance_name)) | .id)' | /bin/sed 's/"//g'`"
fi

	if ( [ "${CLOUDHOST}" = "linode" ] )
	then
		WEBSERVER_IMAGE_ID="`/usr/local/bin/linode-cli --text images list  | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
		AUTOSCALER_IMAGE_ID="`/usr/local/bin/linode-cli --text images list  | /bin/grep autoscaler | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
		DATABASE_IMAGE_ID="`/usr/local/bin/linode-cli --text images list  | /bin/grep database | /bin/grep ${SNAPSHOT_ID} | /usr/bin/awk '{print $1}'`"
	fi

	if ( [ "${CLOUDHOST}" = "vultr" ] )
	then
		WEBSERVER_IMAGE_ID="`/usr/bin/vultr snapshots | /bin/grep webserver | /bin/grep ${SNAPSHOT_ID}  | /usr/bin/awk '{print $1}'`"
		AUTOSCALER_IMAGE_ID="`/usr/bin/vultr snapshots | /bin/grep autoscaler | /bin/grep ${SNAPSHOT_ID}  | /usr/bin/awk '{print $1}'`"
		DATABASE_IMAGE_ID="`/usr/bin/vultr snapshots | /bin/grep database | /bin/grep ${SNAPSHOT_ID}  | /usr/bin/awk '{print $1}'`"
	fi       
fi
