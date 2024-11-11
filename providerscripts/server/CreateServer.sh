#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will spin up a new server of the size, region and os
# specified  on the hosting provider, cloudhost, of choice.
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

os_choice="${1}"
region="${2}"
server_size="${3}"
server_name="${4}"
key_id="${5}"
cloudhost="${6}"
snapshot_id="${9}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	if ( [ "${snapshot_id}" != "" ] )
	then
		os_choice="${snapshot_id}"
	else
		os_choice="`/bin/echo "${os_choice}" | /bin/sed "s/'//g"`"
	fi

	if ( [ "`/usr/local/bin/doctl vpcs list | /bin/grep "adt-vpc" | /bin/grep "${region}"`" = "" ] )
	then
		/usr/local/bin/doctl vpcs create --name "adt-vpc" --region "${region}" --ip-range "10.116.0.0/24"
	fi
	
	vpc_id="`/usr/local/bin/doctl vpcs list  | /bin/grep "adt-vpc" | /bin/grep "${region}" | /usr/bin/awk '{print $1}'`"
	
  #  /usr/local/bin/doctl compute droplet create "${server_name}" --size "${server_size}" --image "${os_choice}"  --region "${region}" --ssh-keys "${key_id}" --enable-private-networking

	/usr/local/bin/doctl compute droplet create "${server_name}" --size "${server_size}" --image "${os_choice}"  --region "${region}" --ssh-keys "${key_id}" --vpc-uuid "${vpc_id}"


fi

template_id="${1}"
zone_id="${2}" 
server_size="${3}" 
server_name="${4}"
key_pair="${5}"
cloudhost="${6}"
snapshot_id="${9}"

if ( [ "${cloudhost}" = "exoscale" ] )
then

	template_id="`/bin/echo "${template_id}" | /bin/sed "s/'//g"`"


	if ( [ "${snapshot_id}" != "" ] )
	then
		template_id="${snapshot_id}"
	fi
	
	/usr/bin/exo compute instance create ${server_name} --instance-type standard.${server_size} --template "${template_id}" --zone ${zone_id} --ssh-key ${key_pair} --cloud-init "${BUILD_HOME}/providerscripts/server/cloud-init/exoscale.dat"
   
	if ( [ "`/usr/bin/exo compute private-network list -O text | /bin/grep adt_private_net_${zone_id}`" = "" ] )
	then
		/usr/bin/exo compute private-network create adt_private_net_${zone_id} --zone ${zone_id} --start-ip 10.0.0.20 --end-ip 10.0.0.200 --netmask 255.255.255.0
	fi
	
	/usr/bin/exo compute instance private-network attach  ${server_name} adt_private_net_${zone_id} --zone ${zone_id} 
fi

distribution="${1}"
location="${2}"
server_size="${3}"
server_name="`/bin/echo ${4} | /usr/bin/cut -c -32`"
key_id="${5}"
cloudhost="${6}"
snapshot_id="${8}"

if ( [ "${cloudhost}" = "linode" ] )
then
	key="`/usr/local/bin/linode-cli --text sshkeys view ${key_id} | /usr/bin/awk '{print $4,$5,$6}' | /usr/bin/tail -n-1`"
	emergency_password="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-30`"
	BUILD_HOME="`/bin/cat /home/buildhome.dat`"
	/bin/echo "${emergency_password}" > ${BUILD_HOME}/runtimedata/${cloudhost}/EMERGENCY_PASSWORD

	if ( [ "`/usr/local/bin/linode-cli --text vpcs list | /bin/grep "adt-vpc"`" = "" ] )
	then
        	/usr/local/bin/linode-cli vpcs create --label adt-vpc --region ${location} --subnets.label adt-subnet --subnets.ipv4 10.0.1.0/24		
	fi
	
 	vpc_id="`/usr/local/bin/linode-cli --json --pretty | /usr/bin/jq '.[] | select (.label == "adt-vpc").id'`"
	subnet_id="`/usr/local/bin/linode-cli --json --pretty vpcs subnets-list ${vpc_id} | /usr/bin/jq  '.[] | select (.label == "adt-subnet").id'`"
	
 	if ( [ "${snapshot_id}" != "" ] )
	then
		/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${location} --image "private/${snapshot_id}" --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
	else	
  		if ( [ "`/bin/echo ${distribution} | /bin/grep 'Ubuntu 20.04'`" != "" ] )
		then
			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${location} --image linode/ubuntu20.04 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Ubuntu 22.04'`" != "" ] )
		then
			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${location} --image linode/ubuntu22.04 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Ubuntu 24.04'`" != "" ] )
		then
			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${location} --image linode/ubuntu24.04 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 10'`" != "" ] )
		then
			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${location} --image linode/debian10 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 11'`" != "" ] )
		then
			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${location} --image linode/debian11 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any  
		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 12'`" != "" ] )
		then
			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${location} --image linode/debian12 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any		
  		fi
	fi
fi

os_choice="${1}"
region="${2}"
server_plan="${3}"
server_name="${4}"
key_id="${5}"
cloudhost="${6}"
snapshot_id="${8}"
if ( [ "${snapshot_id}" = "0" ] || [ "${snapshot_id}" = "1" ] )
then
	ddos_protection="${snapshot_id}"
else
	ddos_protection="${9}"
fi
if ( [ "${snapshot_id}" = "FILLER" ] )
then
	snapshot_id="${9}"
	ddos_protection="${10}"
fi

if (  [ "${cloudhost}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	/bin/sleep 1
	os_choice="`/bin/echo "${os_choice}" | /bin/sed "s/'//g"`"

	if ( [ "`/usr/bin/vultr vpc2 list | grep adt-vpc`" = "" ] )
	then
		/usr/bin/vultr vpc2 create --region="${region}" --description="adt-vpc" --ip-type="v4" --ip-block="192.168.0.0" --prefix-length="16"
	fi
	
	vpc_id="`/usr/bin/vultr vpc2 list | grep adt-vpc | /usr/bin/awk '{print $1}'`"
	os_choice="`/usr/bin/vultr os list | /bin/grep "${os_choice}" | /usr/bin/awk '{print $1}'`"

	user_data=`${BUILD_HOME}/providerscripts/server/cloud-init/vultr.dat`
   
 	if ( [ "${snapshot_id}" != "" ] )
	then
	   if ( [ "${ddos_protection}" = "1" ] )
	   then
			/usr/bin/vultr instance create --label="${server_name}" --region="${region}" --plan="${server_plan}" --ipv6=false -s ${key_id} --snapshot="${snapshot_id}" --ddos=true --userdata="${user_data}"
		else
			/usr/bin/vultr instance create --label="${server_name}" --region="${region}" --plan="${server_plan}" --ipv6=false -s ${key_id} --snapshot="${snapshot_id}" --ddos=false --userdata="${user_data}"
		fi
	else
	   if ( [ "${ddos_protection}" = "1" ] )
	   then
			/usr/bin/vultr instance create --label="${server_name}" --region="${region}" --plan="${server_plan}" --os="${os_choice}" --ipv6=false -s ${key_id} --ddos=true --userdata="${user_data}"
		else
			/usr/bin/vultr instance create --label="${server_name}" --region="${region}" --plan="${server_plan}" --os="${os_choice}" --ipv6=false -s ${key_id} --ddos=false --userdata="${user_data}"
		fi    
	fi
	machine_id="`/usr/bin/vultr instance list | /bin/grep "${server_name}" | /usr/bin/awk '{print $1}'`"
	
	while ( [ "${machine_id}" = "" ] )
	do
		machine_id="`/usr/bin/vultr instance list | /bin/grep "${server_name}" | /usr/bin/awk '{print $1}'`"
		/bin/sleep 5
	done
	
	if ( [ "${machine_id}" != "" ] )
	then
		count="0"
		/usr/bin/vultr vpc2 nodes attach ${vpc_id} --nodes="${machine_id}"
		while ( [ "$?" != "0" ] && [ "${count}" -lt "5" ] )
		do
			count="`/usr/bin/expr ${count} + 1`"
			/bin/sleep 30
			/usr/bin/vultr vpc2 nodes attach ${vpc_id} --nodes="${machine_id}"
		done 
	fi
	
	if ( [ "`/usr/bin/vultr vpc2 nodes list ${vpc_id} | /bin/grep ${machine_id}`" = "" ] )
	then
		: #return "FAILURE" AND check for it
	fi
fi


