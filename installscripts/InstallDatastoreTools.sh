#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date :  9/4/2016
# Description: Install the tools for manipulating the Datastores
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
####################################################################################
####################################################################################
#set -x

if ( [ "$2" != "" ] )
then
	buildos="${2}"
fi

if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
then

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
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install s3cmd
		fi

		if ( [ "${buildos}" = "debian" ] )
		then
			DEBIAN_FRONTEND=noninteractive ${apt} -o DPkg::Lock::Timeout=-1 -qq -y install s3cmd
		fi
	fi
elif ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s5cmd" ] )
then
	/usr/bin/go install github.com/peak/s5cmd/v2@latest
	/bin/cp /root/go/bin/s5cmd /usr/bin/s5cmd
fi
