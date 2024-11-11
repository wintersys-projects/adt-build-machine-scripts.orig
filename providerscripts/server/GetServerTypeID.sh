#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will return the type (size) of the machine to be spun up
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
######################################################################################
######################################################################################
#set -x

server_size="${1}"
server_type="${2}"
cloudhost="${3}"
buildos="${4}"
buildosversion="${5}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	/bin/echo ${server_size}
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	/bin/echo "${server_size}"
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	/bin/echo ${server_size}
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	BUILD_HOME="`/bin/cat /home/buildhome.dat`"
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	/bin/sleep 1
	/usr/bin/vultr plans list | /bin/grep "${server_size}" | /usr/bin/awk '{print $1}'
fi

