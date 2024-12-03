#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will destroy the specified server by ip address
###################################################################################
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
###################################################################################
###################################################################################
#set -x

status () {
	/bin/echo "$1" | /usr/bin/tee /dev/fd/3 2>/dev/null
}

server_ip="${1}"
cloudhost="${2}"

BUILD_HOME="`/bin/cat /home/buildhome.dat`" 
BUILD_IDENTIFIER="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER`"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
        server_id="`/usr/local/bin/doctl compute droplet list -o json | /usr/bin/jq -r '.[] | select (.networks.v4[].ip_address == "'${server_ip}'").id'`"
        /usr/local/bin/doctl -force compute droplet delete ${server_id}
        status "Destroyed a server with ip address ${server_ip}"
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
        zone="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/${BUILD_IDENTIFIER}/CURRENTREGION`"
        server_name="`/usr/bin/exo compute private-network show adt_private_net_${zone} --zone ${zone} -O json | /usr/bin/jq -r '.leases[] | select(.ip_address=="'${server_ip}'") | .instance'`"
        if ( [ "${server_name}" != "" ] )
        then
                server_ip="`/usr/bin/exo compute instance list --zone ${zone} -O json | /usr/bin/jq -r '.[] | select (.name =="'${server_name}'").ip_address'`" 
        fi
        server_to_delete="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} ${cloudhost}`"
        /bin/echo "Y" | /usr/bin/exo compute instance delete ${server_to_delete} --zone ${zone}
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	if ( [ "${server_ip}" != "" ] )
	then
    		server_id="`/usr/local/bin/linode-cli --json linodes list | /usr/bin/jq -r '.[] | select (.ipv4[] == "'${server_ip}'").id'`"
    		if ( [ "${server_id}" = "" ] )
      		then
			server_ip="`${BUILD_HOME}/providerscripts/server/GetServerPublicIPAddressByIP.sh ${server_ip} ${cloudhost}`"
    			server_id="`/usr/local/bin/linode-cli --json linodes list | /usr/bin/jq -r '.[] | select (.ipv4[] == "'${server_ip}'").id'`"
   		fi
		/usr/local/bin/linode-cli linodes shutdown ${server_id}
		/usr/local/bin/linode-cli linodes delete ${server_id}
		status "Destroyed a server with ip address ${server_ip}"
	fi
fi


if ( [ "${cloudhost}" = "vultr" ] )
then
	server_id="`/usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.main_ip == "'${server_ip}'").id'`"
		
	if ( [ "${server_id}" = "" ] )
  	then
		server_id="`/usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.internal_ip == "'${server_ip}'").id'`"
	fi        
 	/usr/bin/vultr instance delete ${server_id}
        status "Destroyed a server with ip address ${server_ip}"
fi


