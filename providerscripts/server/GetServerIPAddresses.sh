#!/bin/sh
##############################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will get all the server ip addresses of the machines of a specified type
##############################################################################################
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
#############################################################################################
#############################################################################################
#set -x

server_type="$1"
cloudhost="$2"
if ( [ "${3}" != "" ] )
then
	BUILD_HOME="$3"
fi

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute droplet list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $3}'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	zone="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/CURRENTREGION`"
	/usr/bin/exo  compute instance list --zone ${zone} -O text | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $5}'
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	server_type="`/bin/echo ${server_type} | /bin/sed 's/\*//g'`"
	/usr/local/bin/linode-cli --json --pretty linodes list | jq '.[] | select (.label | contains("'${server_type}'")).ipv4' | /bin/grep -o '[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}.[0-9]\{1,3\}'
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	/bin/sleep 1
	server_type="`/bin/echo ${server_type} | /usr/bin/cut -c -25`"
	ip="`/usr/bin/vultr instance list | /bin/grep ".*${server_type}" | /usr/bin/awk '{print $2}'`"
	
	if ( [ "${ip}" = "0.0.0.0" ] )
	then
		/bin/echo ""
	else
		/bin/echo "${ip}"
	fi
fi



