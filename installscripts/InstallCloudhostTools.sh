#!/bin/sh
######################################################################################
# Description: This script will install the cloudhost tools for the provider you have
# selected. These tools will give API access to the provider which can then be used by
# the other scripts to manipulate resourced on that providers infrastructure.
# Date: 07-11-2016
# Author: Peter Winter
######################################################################################
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
set -x

cloudhost="${1}"
buildos="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
        if ( [ ! -f /usr/local/bin/doctl ] )
        then
                ${BUILD_HOME}/installscripts/InstallDoctl.sh "${buildos}"
        fi
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
        if ( [ ! -f /usr/bin/exo ] )
        then
                ${BUILD_HOME}/installscripts/InstallExo.sh "${buildos}"
        fi
fi

if ( [ "${cloudhost}" = "linode" ] )
then
        if ( [ ! -f /usr/local/bin/linode-cli ] )
        then
                ${BUILD_HOME}/installscripts/InstallLinodeCLI.sh "${buildos}"
        fi
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
        if ( [ ! -f /usr/bin/vultr ] )
        then
                ${BUILD_HOME}/installscripts/InstallSudo.sh "${buildos}"
                ${BUILD_HOME}/installscripts/InstallVultrCLI.sh "${buildos}"        
        fi
fi

