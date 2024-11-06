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
all="${3}"

if ( [ "${cloudhost}" = "digitalocean" ] || [ "${all}" = "1" ] )
then
	if ( [ -f ~/.config/doctl/config.yaml ] )
	then
		server_name="`/usr/local/bin/doctl compute droplet list | /bin/grep -w "${server_ip}" | /usr/bin/awk '{print $2}'`"
		if ( [ "${server_name}" != "" ] )
		then
			/bin/echo "digitalocean" > ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST
			/bin/echo ${server_name}
		fi
	fi
fi

if ( [ "${cloudhost}" = "exoscale" ] || [ "${all}" = "1" ] )
then
	zone="`/bin/cat ${BUILD_HOME}/runtimedata/exoscale/CURRENTREGION`"
	/usr/bin/exo compute instance list --zone ${zone} -O json | /usr/bin/jq '.[] | select (.ip_address =="'${server_ip}'").name' | /bin/sed 's/"//g'
fi

if ( [ "${cloudhost}" = "linode" ] || [ "${all}" = "1" ] )
then
	/usr/local/bin/linode-cli --json --pretty linodes list | jq '.[] | select (.ipv4[] == "'${server_ip}'").label' | /bin/sed 's/"//g'
fi

if ( [ "${cloudhost}" = "vultr" ] || [ "${all}" = "1" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/vultr/TOKEN` 2>/dev/null"
	if ( [ "${VULTR_API_KEY}" != "" ] )
	then
		/bin/sleep 1
		server_name="`/usr/bin/vultr instance list | /bin/grep -w "${server_ip}" | /usr/bin/awk '{print $3}'`"
		if ( [ "${server_name}" != "" ] )
		then
			/bin/echo "vultr" > ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST
			/bin/echo ${server_name}
		fi
	fi
fi

