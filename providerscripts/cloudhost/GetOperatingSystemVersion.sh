#!/bin/sh
#############################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will get the version of the operating system that we are building for
#############################################################################################
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
############################################################################################
############################################################################################
#set -x

cloudhost="${1}"
buildos="${2}"
buildos_version="${3}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		buildos_version="`/bin/echo ${buildos_version} | /bin/sed 's/\./-/g'`"
		/bin/echo "ubuntu-${buildos_version}-x64"
	elif ( [ "${buildos}" = "debian" ] )
	then
		/bin/echo "debian-${buildos_version}-x64"
	fi
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		if ( [ "${buildos_version}" = "20.04" ] )
		then
			/bin/echo "Linux Ubuntu ${buildos_version} LTS 64-bit"
		elif ( [ "${buildos_version}" = "22.04" ] )
		then
			/bin/echo "Linux Ubuntu ${buildos_version} LTS 64-bit"
		elif ( [ "${buildos_version}" = "24.04" ] )
		then
			/bin/echo "Linux Ubuntu ${buildos_version} LTS 64-bit"
		fi
	elif ( [ "${buildos}" = "debian" ] )
	then
		if ( [ "${buildos_version}" = "11" ] )
		then 
			/bin/echo "Linux Debian ${buildos_version} (Bullseye) 64-bit"
		elif ( [ "${buildos_version}" = "12" ] )
		then
			/bin/echo "Linux Debian ${buildos_version} (Bookworm) 64-bit"
		fi
	fi
fi

if ( [ "${cloudhost}" = "linode" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		/bin/echo "Ubuntu ${buildos_version}"
	elif ( [ "${buildos}" = "debian" ] )
	then
		/bin/echo "Debian ${buildos_version}"
	fi
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		/bin/echo "Ubuntu ${buildos_version} LTS x64"
	elif ( [ "${buildos}" = "debian" ] )
	then
		/bin/echo "Debian ${buildos_version} x64"
	fi
fi




