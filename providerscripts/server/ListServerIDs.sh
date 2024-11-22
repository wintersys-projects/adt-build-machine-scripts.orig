#!/bin/sh
################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : Lists all the id's of a server of a particular type
################################################################################
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

server_type="${1}"
cloudhost="${2}"

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
        /usr/local/bin/doctl compute droplet list -o json | /usr/bin/jq -r '.[] | select (.name | contains("'${server_type}'")).id'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
 	zone="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/CURRENTREGION`"
	/usr/bin/exo compute instance list --zone ${zone} -O json | /usr/bin/jq -r '.[] | select (.name | contains("'${server_type}'")).id'
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	/usr/local/bin/linode-cli --json --pretty linodes list | /usr/bin/jq -r '.[] | select (.label | contains("'${server_type}'")).id'
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	server_type="`/bin/echo ${server_type} | /usr/bin/cut -c -25`"
 	/usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.label | contains("'${server_type}'")).id'
fi








