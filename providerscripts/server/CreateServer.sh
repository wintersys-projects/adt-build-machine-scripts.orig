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
server_name="${2}"
snapshot_id="${3}"
CLOUDHOST="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_CLOUDHOST`"
BUILD_IDENTIFIER="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER`"

BUILD_ENVIRONMENT="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/build_environment"
BUILDOS="`/bin/grep '^BUILDOS=' ${BUILD_ENVIRONMENT} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
BUILDOS_VERSION="`/bin/grep '^BUILDOS_VERSION=' ${BUILD_ENVIRONMENT} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
REGION="`/bin/grep '^REGION=' ${BUILD_ENVIRONMENT} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
DDOS_PROTECTION="`/bin/grep '^ENABLE_DDOS_PROTECTION=' ${BUILD_ENVIRONMENT} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"
VPC_IP_RANGE="`/bin/grep '^VPC_IP_RANGE=' ${BUILD_ENVIRONMENT} | /bin/sed 's/"//g' | /usr/bin/awk -F'=' '{print $NF}'`"

OS_CHOICE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION} | /bin/sed "s/'//g"`"
KEY_ID="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/PUBLICKEYID`"

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
        if ( [ "${snapshot_id}" != "" ] )
        then
                OS_CHOICE="${snapshot_id}"
        fi

        if ( [ "`/usr/local/bin/doctl vpcs list -o json | /usr/bin/jq -r '.[] | select (.region == "'${REGION}'") | select (.name == "adt-vpc").id'`" = "" ] )
        then
                /usr/local/bin/doctl vpcs create --name "adt-vpc" --region "${REGION}" --ip-range "${VPC_IP_RANGE}"
        fi

        vpc_id="`/usr/local/bin/doctl vpcs list -o json | /usr/bin/jq -r '.[] | select (.region == "'${REGION}'") | select (.name == "adt-vpc").id'`"
 
        /usr/local/bin/doctl compute droplet create "${server_name}" --size "${server_size}" --image "${OS_CHOICE}"  --region "${REGION}" --ssh-keys "${KEY_ID}" --vpc-uuid "${vpc_id}"
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
        if ( [ "${snapshot_id}" != "" ] )
        then
                OS_CHOICE="${snapshot_id}"
        fi

        /usr/bin/exo compute instance create ${server_name} --instance-type standard.${server_size} --template "${OS_CHOICE}" --zone ${REGION} --ssh-key ${KEY_ID} --cloud-init "${BUILD_HOME}/providerscripts/server/cloud-init/exoscale.dat"
   
        if ( [ "`/usr/bin/exo compute private-network list -O text | /bin/grep -w "adt_private_net_${REGION}"`" = "" ] )
        then
                /usr/bin/exo compute private-network create adt_private_net_${REGION} --zone ${REGION} --start-ip 10.0.0.20 --end-ip 10.0.0.200 --netmask 255.255.255.0
        fi

        /usr/bin/exo compute instance private-network attach  ${server_name} adt_private_net_${REGION} --zone ${REGION} 
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
        key="`/usr/local/bin/linode-cli --json sshkeys view ${KEY_ID} | /usr/bin/jq -r '.[].ssh_key'`"
        emergency_password="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-30`"
        BUILD_HOME="`/bin/cat /home/buildhome.dat`"
        /bin/echo "${emergency_password}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/EMERGENCY_PASSWORD

        if ( [ "`/usr/local/bin/linode-cli --json vpcs list | /usr/bin/jq -r '.[] | select (.label == "'${label}'").id'`" = "" ] )
        then
                /usr/local/bin/linode-cli vpcs create --label adt-vpc --region ${REGION} --subnets.label adt-subnet --subnets.ipv4 ${VPC_IP_RANGE}
        fi

        vpc_id="`/usr/local/bin/linode-cli vpcs list --json | /usr/bin/jq -r '.[] | select (.label == "adt-vpc").id'`"
        subnet_id="`/usr/local/bin/linode-cli --json vpcs subnets-list ${vpc_id} | /usr/bin/jq  -r '.[] | select (.label == "adt-subnet").id'`"

        if ( [ "${snapshot_id}" != "" ] )
        then
                /usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${REGION} --image "private/${snapshot_id}" --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any
        else
                /usr/local/bin/linode-cli linodes create --authorized_keys "${key}" --root_pass "${emergency_password}" --region ${REGION} --image "${OS_CHOICE}" --type ${server_size} --label "${server_name}" --no-defaults --interfaces.primary true --interfaces.purpose vpc --interfaces.subnet_id ${subnet_id} --interfaces.ipv4.nat_1_1 any

        fi
fi

if (  [ "${CLOUDHOST}" = "vultr" ] )
then
        if ( [ "`/usr/bin/vultr vpc2 list -o json | /usr/bin/jq -r '.vpcs[] | select (.description == "adt-vpc").id'`" = "" ] )
        then
                ip_block="`/bin/echo ${VPC_IP_RANGE} | /usr/bin/awk -F'/' '{print $1}'`"
                /usr/bin/vultr vpc2 create --region="${REGION}" --description="adt-vpc" --ip-type="v4" --ip-block="${ip_block}" --prefix-length="16"
        fi

        vpc_id="`/usr/bin/vultr vpc2 list -o json | /usr/bin/jq -r '.vpcs[] | select (.description == "adt-vpc").id'`"
        OS_CHOICE="`/usr/bin/vultr os list -o json | /usr/bin/jq -r '.os[] | select (.name | contains ("'"${OS_CHOICE}"'")).id'`"

        user_data=`${BUILD_HOME}/providerscripts/server/cloud-init/vultr.dat`
   
        if ( [ "${snapshot_id}" != "" ] )
        then
           if ( [ "${DDOS_PROTECTION}" = "1" ] )
           then
                        /usr/bin/vultr instance create --label="${server_name}" --region="${REGION}" --plan="${server_size}" --ipv6=false -s ${KEY_ID} --snapshot="${snapshot_id}" --ddos=true --userdata="${user_data}"
                else
                        /usr/bin/vultr instance create --label="${server_name}" --region="${REGION}" --plan="${server_size}" --ipv6=false -s ${KEY_ID} --snapshot="${snapshot_id}" --ddos=false --userdata="${user_data}"
                fi
        else
           if ( [ "${DDOS_PROTECTION}" = "1" ] )
           then
                        /usr/bin/vultr instance create --label="${server_name}" --region="${REGION}" --plan="${server_size}" --os="${OS_CHOICE}" --ipv6=false -s ${KEY_ID} --ddos=true --userdata="${user_data}"
                else
                        /usr/bin/vultr instance create --label="${server_name}" --region="${REGION}" --plan="${server_size}" --os="${OS_CHOICE}" --ipv6=false -s ${KEY_ID} --ddos=false --userdata="${user_data}"
                fi    
        fi

        machine_id=""
        count="0"
        while ( [ "${machine_id}" = "" ] && [ "${count}" -lt "10" ] )
        do
                machine_id="`/usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.label == "'"${server_name}"'").id'`"
                /bin/sleep 5
                count="`/usr/bin/expr ${count} + 1`"
        done

        /usr/bin/vultr vpc2 nodes attach ${vpc_id} --nodes="${machine_id}"
fi
