#!/bin/sh
############################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : This script gets a machine's public ip based on its private ip
#############################################################################
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

export HOME="`/bin/cat /home/homedir.dat`"

ip="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
        /usr/local/bin/doctl compute droplet list -o json | /usr/bin/jq -r '.[] | select (.networks.v4[] | select (.ip_address == "'${ip}'")).networks.v4[] | select (.type == "public").ip_address'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	zone="`${HOME}/providerscripts/utilities/ExtractConfigValue.sh 'REGION'`"
	server_name="`/usr/bin/exo compute private-network show adt_private_net_${zone} --zone ${zone} -O json | /usr/bin/jq -r '.leases[] | select(.ip_address=="'${ip}'") | .instance'`"
	/usr/bin/exo compute instance list --zone ${zone} -O json | /usr/bin/jq -r '.[] | select (.name =="'${server_name}'").ip_address' 
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	linodeids="`/usr/local/bin/linode-cli --json linodes list | /usr/bin/jq '.[].id'`"
        
	for linodeid in ${linodeids}
        do
                /usr/local/bin/linode-cli --json linodes ips-list ${linodeid} | /usr/bin/jq -r '.[].ipv4.vpc[] | select (.address == "'${ip}'").nat_1_1'  
        done
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	vpc_id="`/usr/bin/vultr vpc2 list -o json | /usr/bin/jq -r '.vpcs[] | select (.description == "adt-vpc").id'`"
        id="`/usr/bin/vultr vpc2 nodes list ${vpc_id} -o json | /usr/bin/jq -r '.nodes[] | select (.ip_address == "'${ip}'").id'`"
        /usr/bin/vultr instance get ${id} -o json | /usr/bin/jq -r '.instance.main_ip'
	
fi
