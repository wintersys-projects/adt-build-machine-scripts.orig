#!/bin/sh
########################################################################################
# Author : Peter Winter
# Date:    13/07/2016
# Description : This script will determine if a machine with a given name is running or not
########################################################################################
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
########################################################################################
########################################################################################
#set -x

instance_type="${1}"
cloudhost="${2}"

BUILD_HOME="`/bin/cat /home/buildhome.dat`"
BUILD_IDENTIFIER="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVEBUILDIDENTIFIER`"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute droplet list | /bin/grep ${instance_type}
fi
if ( [ "${cloudhost}" = "exoscale" ] )
then
	zone="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/CURRENTREGION`"
	/usr/bin/exo compute instance list --zone ${zone} -O text | /bin/grep "${instance_type}" 
fi
if ( [ "${cloudhost}" = "linode" ] )
then
	/usr/local/bin/linode-cli linodes list --text | /bin/grep "${instance_type}"
fi
if ( [ "${cloudhost}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	/usr/bin/vultr instance list | /bin/grep "${instance_type}"
fi



