#!/bin/sh
#########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description :  This script gets the private ip address of a machine given its unique name
#########################################################################################
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
########################################################################################
########################################################################################
#set -x

server_type="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute droplet list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $4}'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	server_type="`/bin/echo ${server_type} | /bin/sed 's/\*//g'`"
	zone="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/CURRENTREGION`"
        /usr/bin/exo compute private-network show adt_private_net_${zone} --zone ${zone} -O json | /usr/bin/jq 'select (.leases[].instance | contains("'${server_type}'")).leases[].ip_address' | /bin/sed 's/"//g'
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	server_type="`/bin/echo ${server_type} | /bin/sed 's/\*//g'`"
	linodeids="`/usr/local/bin/linode-cli --json --pretty linodes list | jq '.[] | select (.label | contains("'${server_type}'")).id'`"

	privateips=""
	for linodeid in ${linodeids}
	do
  		privateip="`/usr/local/bin/linode-cli --json --pretty linodes ips-list ${linodeid} | /usr/bin/jq '.[].ipv4.vpc[].address'  | /bin/grep -o '[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'`"		
  		privateips=${privateips}" ${privateip}"
	done
	/bin/echo ${privateips}
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	/bin/sleep 1
	server_type="`/bin/echo ${server_type} | /usr/bin/cut -c -25`"

	ids="`/usr/bin/vultr instance list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $1}'`"
	for id in ${ids}
	do
		/usr/bin/vultr instance get ${id} | /bin/grep "INTERNAL IP" | /usr/bin/awk '{print $NF}'
	done
fi

