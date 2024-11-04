#!/bin/sh
######################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This will run a service command by service type and the function that is needed
#######################################################################################################
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
#######################################################################################################
#######################################################################################################
#set -x

service_type="${1}"
service_function="${2}"

buildos="`/bin/grep ID /etc/*-release | /bin/grep debian | /usr/bin/awk -F'=' '{print $NF}'`"

if ( [ "${buildos}" = "ubuntu" ] )
then
    if ( [ "${service_type}" = "ssh" ] )
    then
        /usr/bin/systemctl daemon-restart
    fi
    /usr/sbin/service ${service_type} ${service_function}
fi

if ( [ "${buildos}" = "debian" ] )
then
    if ( [ "${service_type}" = "ssh" ] )
    then
        /usr/bin/systemctl daemon-restart
    fi
    /usr/sbin/service ${service_type} ${service_function}
fi
