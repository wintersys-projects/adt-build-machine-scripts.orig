#!/bin/sh
#####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will register an ssh key pair
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
##################################################################################
##################################################################################
#set -x

status () {
	/bin/echo "$1" | /usr/bin/tee /dev/fd/3 2>/dev/null
}

key_name="${1}"
token="${2}"
key_substance="${3}"
cloudhost="${4}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute ssh-key create ${key_name} --public-key "${key_substance}"
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	/bin/echo ${key_substance}  > /tmp/key
	/usr/bin/exo compute ssh-key register ${key_name} /tmp/key
	/bin/rm /tmp/key
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	/usr/local/bin/linode-cli sshkeys create --label "${key_name}" --ssh_key="${key_substance}"
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/TOKEN`"
	status "About to create ssh key in vultr"
	/bin/sleep 1
	/usr/bin/vultr ssh-key create -n "${key_name}" -k "${key_substance}"
fi


