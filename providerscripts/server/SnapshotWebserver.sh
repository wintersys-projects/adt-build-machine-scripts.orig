#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : This script will create a snapshot of a webserver
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

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
	webserver_id="`/usr/local/bin/doctl compute droplet list | /bin/grep webserver | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
	webserver_name="`/usr/local/bin/doctl compute droplet list | /bin/grep webserver | /usr/bin/awk '{print $2}' | /usr/bin/head -1`"
	status ""
	status "########################SNAPSHOTING YOUR WEBSERVER####################################"
	status ""
	/usr/local/bin/doctl compute droplet-action snapshot --snapshot-name "${webserver_name}" ${webserver_id}
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then

	status ""
	status "########################SNAPSHOTING YOUR WEBSERVER IN THE BACKGROUND####################################"
	status ""

	region_id="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/CURRENTREGION`"
	webserver_name="`/usr/bin/exo compute instance list --zone ${region_id} -O text | /bin/grep "webserver" | /usr/bin/awk '{print $2}' | /usr/bin/head -1`"    
	webserver_id="`/usr/bin/exo compute instance list -O text  | /bin/grep "${webserver_name}" | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
	/usr/bin/exo compute instance snapshot create -z ${region_id} ${webserver_id}
	snapshot_id="`/usr/bin/exo -O text  compute instance snapshot list  | /bin/grep "${webserver_name}" | /usr/bin/awk '{print $1}'`"
	/usr/bin/exo compute instance-template register --boot-mode legacy --disable-password --from-snapshot ${snapshot_id} --zone ${region_id} --username ${DEFAULT_USER} ${webserver_name} 
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
	webserver_id="`/usr/local/bin/linode-cli --text linodes list | /bin/grep webserver | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
	webserver_name="`/usr/local/bin/linode-cli --text linodes list | /bin/grep webserver | /usr/bin/awk '{print $2}' | /usr/bin/head -1`"
	disk_id="`/usr/local/bin/linode-cli --text linodes disks-list ${webserver_id} | /bin/grep -v swap | /bin/grep -v id | /usr/bin/awk '{print $1}'`"
	status ""
	status "########################SNAPSHOTING YOUR WEBSERVER####################################"
	status ""
	/usr/local/bin/linode-cli images create --disk_id ${disk_id} --label ${webserver_name}
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"

	SUBID="`/usr/bin/vultr instance list | /bin/grep webserver | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
	status ""
	status "########################SNAPSHOTING YOUR WEBSERVER IN THE BACKGROUND####################################"
	status ""
	/usr/bin/vultr snapshot create -i ${SUBID} -d "webserver-${SERVER_USER}"
	/bin/touch ${HOME}/.ssh/SNAPSHOT:${SUBID}
	
fi


