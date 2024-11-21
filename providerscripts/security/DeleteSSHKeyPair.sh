#!/bin/sh
####################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will delete a pair of ssh keys from the cloud host provider
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
####################################################################################
####################################################################################
#set -x

key_name="${1}"
token="${2}"
cloudhost="${3}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	key_ids="`/usr/local/bin/doctl compute ssh-key list | /bin/grep "${key_name}" | /usr/bin/awk '{print $1}'`"

	if ( [ "${key_ids}" != "" ] )
	then
	   for key_id in ${key_ids}
	   do
		   /usr/local/bin/doctl compute ssh-key delete ${key_id} --force 
	   done
	fi
fi
if ( [ "${cloudhost}" = "exoscale" ] )
then
	/bin/echo "Y" | /usr/bin/exo compute ssh-key  delete ${key_name} 
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	key_ids="`/usr/local/bin/linode-cli --text sshkeys list | /bin/grep ${key_name} | /usr/bin/awk '{print $2}'`"

	if ( [ "${key_ids}" != "" ] )
	then
		for key_id in ${key_ids}
		do
			/usr/local/bin/linode-cli sshkeys delete ${key_id}
		done
	fi
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	key_ids="`/usr/bin/vultr ssh-key list -o json | /usr/bin/jq -r '.ssh_keys[] | select (.name == "'${key_name}'").id'`"

	if ( [ "${key_ids}" != "" ] )
	then
		for key_id in ${key_ids}
		do
			/usr/bin/vultr ssh-key delete ${key_id}
		done
	fi	
fi


