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

server_size="${1}"
server_name="`/bin/echo ${2} | /usr/bin/cut -c -32`"
snapshot_id="${3}"
cloudhost="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_CLOUDHOST`"
build_identifier="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER`"
buildos="`/bin/grep '^BUILDOS=' ${BUILD_HOME}/runtimedata/${cloudhost}/${build_identifier}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
os_choice="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${cloudhost} ${buildos} ${build_identifier} | /bin/sed "s/'//g"`"
region="`/bin/grep '^REGION=' ${BUILD_HOME}/runtimedata/${cloudhost}/${build_identifier}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
key_id="`/bin/grep '^PUBLIC_KEY_ID=' ${BUILD_HOME}/runtimedata/${cloudhost}/${build_identifier}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
ddos_protection="`/bin/grep '^ENABLE_DDOS_PROTECTION=' ${BUILD_HOME}/runtimedata/${cloudhost}/${build_identifier}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
vpc_ip_range="`/bin/grep '^VPC_IP_RANGE=' ${BUILD_HOME}/runtimedata/${cloudhost}/${build_identifier}/build_environment | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	if ( [ "${snapshot_id}" != "" ] )
	then
		os_choice="${snapshot_id}"
	fi

	if ( [ "`/usr/local/bin/doctl vpcs list | /bin/grep "adt-vpc" | /bin/grep "${region}"`" = "" ] )
	then
		/usr/local/bin/doctl vpcs create --name "adt-vpc" --region "${region}" --ip-range "${vpc_ip_range}"
	fi
	
	vpc_id="`/usr/local/bin/doctl vpcs list  | /bin/grep "adt-vpc" | /bin/grep "${region}" | /usr/bin/awk '{print $1}'`"
 
	/usr/local/bin/doctl compute droplet create "${server_name}" --size "${server_size}" --image "${os_choice}"  --region "${region}" --ssh-keys "${key_id}" --vpc-uuid "${vpc_id}"
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	if ( [ "${snapshot_id}" != "" ] )
	then
		os_choice="${snapshot_id}"
	fi
	
	/usr/bin/exo compute instance create ${server_name} --instance-type standard.${server_size} --template "${os_choice}" --zone ${region} --ssh-key ${key_id} --cloud-init "${BUILD_HOME}/providerscripts/server/cloud-init/exoscale.dat"
   
	if ( [ "`/usr/bin/exo compute private-network list -O text | /bin/grep adt_private_net_${region}`" = "" ] )
	then
		/usr/bin/exo compute private-network create adt_private_net_${region} --zone ${region} --start-ip 10.0.0.20 --end-ip 10.0.0.200 --netmask 255.255.255.0
	fi
	
	/usr/bin/exo compute instance private-network attach  ${server_name} adt_private_net_${region} --zone ${region} 
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
	/bin/echo "${emergency_password}" > ${BUILD_HOME}/runtimedata/${cloudhost}/${BUILD_IDENTIFIER}/EMERGENCY_PASSWORD

	if ( [ "`/usr/local/bin/linode-cli --text vpcs list | /bin/grep "adt-vpc"`" = "" ] )
	then
        	/usr/local/bin/linode-cli vpcs create --label adt-vpc --region ${region} --subnets.label adt-subnet --subnets.ipv4 ${vpc_ip_range}		
	fi
	
	vpc_id="`/usr/local/bin/linode-cli vpcs list --json | /usr/bin/jq -r '.[] | select (.label == "adt-vpc").id'`"
 	subnet_id="`/usr/local/bin/linode-cli --json vpcs subnets-list ${vpc_id} | /usr/bin/jq  -r '.[] | select (.label == "adt-subnet").id'`"
	
 	if ( [ "${snapshot_id}" != "" ] )
	then
		/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image "private/${snapshot_id}" --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
	else	
		/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image "${os_choice}" --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any

	fi
 
  	#	if ( [ "`/bin/echo ${os_choice} | /bin/grep 'Ubuntu 20.04'`" != "" ] )
#		then
#			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image linode/ubuntu20.04 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
#		elif ( [ "`/bin/echo ${os_choice} | /bin/grep 'Ubuntu 22.04'`" != "" ] )
#		then
#			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image linode/ubuntu22.04 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
#		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Ubuntu 24.04'`" != "" ] )
#		then
#			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image linode/ubuntu24.04 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
#		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 10'`" != "" ] )
#		then
#			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image linode/debian10 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
#		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 11'`" != "" ] )
#		then
#			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image linode/debian11 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any  
#		elif ( [ "`/bin/echo ${distribution} | /bin/grep 'Debian 12'`" != "" ] )
#		then
#			/usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${region} --image linode/debian12 --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any		
 # 		fi
#	fi
fi
#

os_choice="${1}"
region="${2}"
server_plan="${3}"
server_name="${4}"
key_id="${5}"
cloudhost="${6}"
snapshot_id="${8}"

if ( [ "`/bin/echo ${7} | /bin/grep ".*-.*-.*-.*-.*"`" != "" ] )
then
        snapshot_id="${7}"
        ddos_protection="${8}"
else
        snapshot_id=""
        ddos_protection="${7}"
fi

if (  [ "${cloudhost}" = "vultr" ] )
then
        os_choice="`/bin/echo "${os_choice}" | /bin/sed "s/'//g"`"

        if ( [ "`/usr/bin/vultr vpc2 list | grep adt-vpc`" = "" ] )
        then
                ip_block="`/bin/echo ${vpc_ip_range} | /usr/bin/awk -F'/' '{print $1}'`"
                /usr/bin/vultr vpc2 create --region="${region}" --description="adt-vpc" --ip-type="v4" --ip-block="${ip_block}" --prefix-length="16"
        fi

        vpc_id="`/usr/bin/vultr vpc2 list -o json | /usr/bin/jq -r '.vpcs[] | select (.description == "adt-vpc").id'`"
        os_choice="`/usr/bin/vultr os list -o json | /usr/bin/jq -r '.os[] | select (.name | contains ("'"${os_choice}"'")).id'`"
	
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
 
        machine_id="`/usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.label == "'"${server_name}"'").id'`"

        while ( [ "${machine_id}" = "" ] )
        do
                machine_id="`/usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.label == "'"${server_name}"'").id'`"
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
fi
