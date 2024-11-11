#!/bin/sh
######################################################################################################
# Description: This script will install iptables
# Author: Peter Winter
# Date: 17/01/2017
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

if ( [ "${1}" != "" ] )
then
	buildos="${1}"
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

apt=""
if ( [ "`/bin/grep "^PACKAGEMANAGER:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	apt="/usr/bin/apt-get"
elif ( [ "`/bin/grep "^PACKAGEMANAGER:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	apt="/usr/sbin/apt-fast"
fi

if ( [ "${apt}" != "" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install iptables

                /usr/bin/debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install netfilter-persistent
		DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install iptables-persistent

	fi

	if ( [ "${buildos}" = "debian" ] )
	then
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install iptables

                /usr/bin/debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
                DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install netfilter-persistent
		DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install iptables-persistent
        fi
fi
