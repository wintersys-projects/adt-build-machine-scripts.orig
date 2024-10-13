#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : If there is a chance that the server didn't attach to the VPC correctly
# then we try to attach it here to make sure we are all nice and VPC about things. 
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
####################################################################################
####################################################################################
#set -x    

cloudhost="${1}"
server_name="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	: # Can't create a droplet without a VPC the way we do it so no need to check that the droplet has attached to the VPC successfully
fi

cloudhost="${1}"
server_name="${2}"

if ( [ "${cloudhost}" = "exoscale" ] )
then
	zone_id="`/bin/cat ${BUILD_HOME}/runtimedata/exoscale/CURRENTREGION`"
	
	private_network_id="`/usr/bin/exo -O text compute private-network list | /bin/grep adt_private_net_${zone_id} | /usr/bin/awk '{print $1}'`"
	
	count="0"
	while ( [ "${private_network_id}" = "" ] && [ "${count}" -lt "5" ] )
	do
		/bin/sleep 10
		count="`/usr/bin/expr ${count} + 1`"
		/usr/bin/exo compute private-network create adt_private_net_${zone_id} --zone ${zone_id} --start-ip 10.0.0.20 --end-ip 10.0.0.200 --netmask 255.255.255.0
		private_network_id="`/usr/bin/exo -O text compute private-network list | /bin/grep adt_private_net_${zone_id} | /usr/bin/awk '{print $1}'`"
	done

	count="0"
	while ( [ "`/usr/bin/exo compute private-network show ${private_network_id} | /bin/grep "${server_name}"`" = "" ] && [ "${count}" -lt "5" ] )
	do
		count="`/usr/bin/expr ${count} + 1`"
		/bin/sleep 10
		/usr/bin/exo compute instance private-network attach  ${server_name} adt_private_net_${zone_id} --zone ${zone_id} 
	done
	if ( [ "${count}" -eq "5" ] )
	then
		/bin/echo "Fail to attach ${server_name} to private network adt_private_net_${zone_id}"
	fi
fi

cloudhost="${1}"
server_name="${2}"

if ( [ "${cloudhost}" = "linode" ] )
then
	:  
fi
	

cloudhost="${1}"
server_name="${2}"
ip="${3}"


if ( [ "${cloudhost}" = "vultr" ] )
then
	machine_id="`/usr/bin/vultr instance list | /bin/grep "${server_name}" | /usr/bin/awk '{print $1}'`"
	
	while ( [ "${machine_id}" = "" ] )
	do
		machine_id="`/usr/bin/vultr instance list | /bin/grep "${server_name}" | /usr/bin/awk '{print $1}'`"
		/bin/sleep 5
	done

	vpc_id="`/usr/bin/vultr vpc2 list | grep adt-vpc | /usr/bin/awk '{print $1}'`"
	
	if ( [ "${machine_id}" != "" ] )
	then
		/usr/bin/vultr vpc2 nodes attach ${vpc_id} --nodes="${machine_id}"
	fi

	/bin/sleep 5

	while ( [ "` /usr/bin/vultr vpc2 list nodes ${vpc_id} | /bin/grep ${ip} | /bin/grep "pending" | /usr/bin/awk '{print $1}'`" != "" ] )
	do
	   #This shouldn't go on forever because we don't expect to be in the pending state forever
	   /bin/sleep 5
	done

	failed_machine_id="` /usr/bin/vultr vpc2 list nodes ${vpc_id} | /bin/grep ${ip} | /bin/grep "failed" | /usr/bin/awk '{print $1}'`"
	count="0"

	while ( [ "${failed_machine_id}" != "" ] && [ "${count}" -lt "5" ] )
	do
		/usr/bin/vultr vpc2 nodes detach ${vpc_id} --nodes="${failed_machine_id}"
		/bin/sleep 10
		/usr/bin/vultr vpc2 nodes attach ${vpc_id} --nodes="${machine_id}"
		/bin/sleep 30
		failed_machine_id="` /usr/bin/vultr vpc2 list nodes ${vpc_id} | /bin/grep ${ip} | /bin/grep "failed" | /usr/bin/awk '{print $1}'`"
		count="`/usr/bin/expr ${count} + 1`"
	done

	if ( [ "${count}" = "5" ] )
	then
		/bin/echo "failed to attach ${failed_machine_id} to the VPC (${vpc_id})"
	fi
fi
