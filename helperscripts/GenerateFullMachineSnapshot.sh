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

if ( [ "${1}" = "" ] )
then
        /bin/echo "I need to know what type of machine you want to snapshot and the machine type must be running"
        /bin/echo "Machine  type can be one of autoscaler, webserver, database"
        exit
fi

if ( [ "${1}" = "autoscaler" ] )
then
        machine_type="autoscaler"
fi

if ( [ "${1}" = "webserver" ] )
then
        machine_type="webserver"
fi

if ( [ "${1}" = "database" ] )
then
        machine_type="database"
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4)Vultr. Please Enter the number for your cloudhost"
read response

if ( [ "${response}" = "1" ] )
then
        CLOUDHOST="digitalocean"
elif ( [ "${response}" = "2" ] )
then
        CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
        CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
        CLOUDHOST="vultr"
else
        /bin/echo "Unrecognised  cloudhost. Exiting ...."
        exit
fi

/bin/echo "Which build identifer do these snapshots relate to?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "${BUILD_IDENTIFIER}" > ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
        machine_id="`/usr/local/bin/doctl compute droplet list | /bin/grep ${machine_type} | /usr/bin/awk '{print $1}'`"
        machine_name="`/usr/local/bin/doctl compute droplet list | /bin/grep ${machine_type} | /usr/bin/awk '{print $2}'`"
        /bin/echo ""
        /bin/echo "########################SNAPSHOTING YOUR ${machine_type}####################################"
        /bin/echo ""
        /usr/local/bin/doctl compute droplet-action snapshot --snapshot-name "${machine_name}" ${machine_id}
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
        region_id="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/CURRENTREGION`"

        /bin/echo ""
        /bin/echo "########################SNAPSHOTING YOUR ${machine_type} ####################################"
        /bin/echo ""

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
        /bin/echo ""
        /bin/echo "########################SNAPSHOTING YOUR ${machine_type}####################################"
        /bin/echo ""
        /usr/local/bin/linode-cli images create --disk_id ${disk_id} --label ${machine_name}
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
        machine_id="`/usr/bin/vultr instance list | /bin/grep "${machine_type}" | /usr/bin/awk '{print $1}' | /usr/bin/head -1`"
        machine_name="`/usr/bin/vultr instance  list | /bin/grep "${machine_type}" | /usr/bin/awk '{print $3}' | /usr/bin/head -1`"
        /bin/echo ""
        /bin/echo "########################SNAPSHOTING YOUR ${machine_type} ####################################"
        /bin/echo ""
        /usr/bin/vultr snapshot create -i ${machine_id} -d "${machine_name}"
        snapshot_id="`/usr/bin/vultr snapshot list | /bin/grep "${machine_type}" | /usr/bin/awk '{print $1}'`"   
fi

/bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/snapshots/${snapshot_id}
/bin/cp ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/snapshots/${snapshot_id}
/bin/cp ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/snapshots/${snapshot_id}
/bin/cp ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/snapshots/${snapshot_id}
