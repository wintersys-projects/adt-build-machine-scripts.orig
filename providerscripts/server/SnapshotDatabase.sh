#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : This script will create a snapshot of the database
#####################################################################################
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
        database_id="`/usr/local/bin/doctl compute droplet list | /bin/grep database | /usr/bin/awk '{print $1}'`"
        database_name="`/usr/local/bin/doctl compute droplet list | /bin/grep database | /usr/bin/awk '{print $2}'`"
        status ""
        status "########################SNAPSHOTING YOUR DATABASE####################################"
        status ""
        /usr/local/bin/doctl compute droplet-action snapshot --snapshot-name "${database_name}" ${database_id}
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then

        status ""
        status "########################SNAPSHOTING YOUR DATABASE IN THE BACKGROUND####################################"
        status ""

        region_id="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/CURRENTREGION`"
        database_name="`/usr/bin/exo compute instance list --zone ${region_id} -O text | /bin/grep "database" | /usr/bin/awk '{print $2}'`"    
        database_id="`/usr/bin/exo compute instance list -O text  | /bin/grep "${database_name}" | /usr/bin/awk '{print $1}'`"
        /usr/bin/exo compute instance snapshot create -z ${region_id} ${database_id}
        snapshot_id="`/usr/bin/exo -O text  compute instance snapshot list  | /bin/grep "${database_name}" | /usr/bin/awk '{print $1}'`"
        /usr/bin/exo compute instance-template register --boot-mode legacy --disable-password --from-snapshot ${snapshot_id} --zone ${region_id} --username ${DEFAULT_USER} ${database_name}  
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
        database_id="`/usr/local/bin/linode-cli --text linodes list | /bin/grep database | /usr/bin/awk '{print $1}'`"
        database_name="`/usr/local/bin/linode-cli --text linodes list | /bin/grep database | /usr/bin/awk '{print $2}'`"
        disk_id="`/usr/local/bin/linode-cli --text linodes disks-list ${database_id} | /bin/grep -v swap | /bin/grep -v id | /usr/bin/awk '{print $1}'`"
        status ""
        status "########################SNAPSHOTING YOUR DATABASE####################################"
        status ""
        /usr/local/bin/linode-cli images create --disk_id ${disk_id} --label ${database_name}
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
        export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"
   
        SUBID="`/usr/bin/vultr instance list | /bin/grep database | /usr/bin/awk '{print $1}'`"
        status ""
        status "########################SNAPSHOTING YOUR DATABASE IN THE BACKGROUND####################################"
        status ""
        /usr/bin/vultr snapshot create -i ${SUBID} -d "database-${SERVER_USER}"
        /bin/touch ${HOME}/.ssh/SNAPSHOT:${SUBID}
fi
