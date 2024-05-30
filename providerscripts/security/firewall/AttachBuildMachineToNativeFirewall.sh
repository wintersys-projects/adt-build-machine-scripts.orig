#!/bin/bash
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2021
# Description : This will apply any native firewalling to the build machine
########################################################################################
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
#########################################################################################
#########################################################################################
#set -x


if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
	build_machine_id="`/usr/local/bin/doctl compute droplet list | /bin/grep "${bmip}" | /usr/bin/awk '{print $1}'`"
	/usr/local/bin/doctl compute firewall add-droplets ${firewall_id} --droplet-ids ${build_machine_id}
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
	build_machine_id="`/usr/bin/exo -O text compute instance list | /bin/grep ${build_machine_ip} | /usr/bin/awk '{print $1}'`"
	/usr/bin/exo compute instance security-group add ${build_machine_id} adt-build-machine
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
	bmip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
	bmid="`/usr/local/bin/linode-cli --json linodes list | jq --arg tmp_ip "${bmip}" '.[] | select (.ipv4 | tostring | contains ($tmp_ip))'.id | /bin/sed 's/\"//g'`"     
	/usr/local/bin/linode-cli firewalls device-create --id ${bmid} --type linode ${firewall_id}      
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"
	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
	build_machine_id="`/usr/bin/vultr instance list | /bin/grep -w ${build_machine_ip} | /usr/bin/awk '{print $1}'`"
	/usr/bin/vultr instance update-firewall-group ${build_machine_id} -f ${firewall_id}
fi


	
