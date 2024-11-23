#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will get the name of a server of the specified ip address
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

server_ip="${1}"
cloudhost="${2}"

BUILD_HOME="`/bin/cat /home/buildhome.dat`" 
BUILD_IDENTIFIER="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVEBUILDIDENTIFIER`"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute droplet list -o json | /usr/bin/jq -r '.[] | select (.networks.v4[] | select (.ip_address == "'${server_ip}'")).name'
	/bin/echo "digitalocean" > ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	zone="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/CURRENTREGION`"
	/usr/bin/exo compute instance list --zone ${zone} -O json | /usr/bin/jq -r '.[] | select (.ip_address =="'${server_ip}'").name'
	/bin/echo "exoscale" > ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	/usr/local/bin/linode-cli --json linodes list | /usr/bin/jq -r '.[] | select (.ipv4[] == "'${server_ip}'").label' 
	/bin/echo "linode" > ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
        /usr/bin/vultr instance list -o json | /usr/bin/jq -r '.instances[] | select (.main_ip == "'${server_ip}'").label' 
	/bin/echo "vultr" > ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST
fi

