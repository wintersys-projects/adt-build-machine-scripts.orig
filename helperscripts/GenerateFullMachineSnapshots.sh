#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : This script will generate a snapshot of a particular machine type
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
        machine_id="`/usr/local/bin/doctl compute droplet list | /bin/grep ${machine_type} | /usr/bin/awk '{print $1}'`"
        machine_name="`/usr/local/bin/doctl compute droplet list | /bin/grep ${machine_type} | /usr/bin/awk '{print $2}'`"
        status ""
        status "########################SNAPSHOTING YOUR ${machine_type}####################################"
        status ""
        /usr/local/bin/doctl compute droplet-action snapshot --snapshot-name "${machine_name}" ${machine_id}
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
        region_id="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/CURRENTREGION`"

        status ""
        status "########################SNAPSHOTING YOUR ${machine_type} ####################################"
        status ""

        machine_name="`/usr/bin/exo compute instance list --zone ${region_id} -O text | /bin/grep "${machine_type}" | /usr/bin/awk '{print $2}' | /usr/bin/head -1`"    
        machine_id="`/usr/bin/exo compute instance list -O text  | /bin/grep "${machine_type}" | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
        /usr/bin/exo compute instance snapshot create -z ${region_id} ${machine_id}
        snapshot_id="`/usr/bin/exo -O text  compute instance snapshot list  | /bin/grep "${machine_name}" | /usr/bin/awk '{print $1}'`"
        /usr/bin/exo compute instance-template register --boot-mode legacy --disable-password --from-snapshot ${snapshot_id} --zone ${region_id} --username ${DEFAULT_USER} ${machine_name} 
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
        machine_id="`/usr/local/bin/linode-cli --text linodes list | /bin/grep "${machine_type}" | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
        machine_name="`/usr/local/bin/linode-cli --text linodes list | /bin/grep "${machine_type}" | /usr/bin/awk '{print $2}' | /usr/bin/head -1`"
        disk_id="`/usr/local/bin/linode-cli --text linodes disks-list ${machine_id} | /bin/grep -v swap | /bin/grep -v id | /usr/bin/awk '{print $1}'`"
        status ""
        status "########################SNAPSHOTING YOUR ${machine_type}####################################"
        status ""
        /usr/local/bin/linode-cli images create --disk_id ${disk_id} --label ${machine_name}
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
        machine_id="`/usr/bin/vultr instance list | /bin/grep "${machine_type}" | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
        machine_name="`/usr/bin/vultr instance  list | /bin/grep "${machine_type}" | /usr/bin/awk '{print $3}' | /usr/bin/head -1`"
        status ""
        status "########################SNAPSHOTING YOUR ${machine_type} ####################################"
        status ""
        /usr/bin/vultr snapshot create -i ${machine_id} -d "${machine_name}"
fi
