#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will list the ssh key pairs
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
###################################################################################
###################################################################################
#set -x

key_name="${1}"
cloudhost="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute ssh-key list -o json | /usr/bin/jq '.[] | select (.name == "'${key_name}'").id'
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
 	/usr/bin/exo compute ssh-key list -O json | /usr/bin/jq -r '.[] | select (.name == "'${key_name}'").fingerprint'
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	/usr/local/bin/linode-cli --json sshkeys list | /usr/bin/jq -r '.[] | select (.label == "'${key_name}'").id'
 fi

if ( [ "${cloudhost}" = "vultr" ] )
then
        /usr/bin/vultr ssh-key list -o json | /usr/bin/jq -r '.ssh_keys[] | select (.name == "'${key_name}'").ssh_key'
fi


