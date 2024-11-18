#!/bin/sh
######################################################################################################
# Description: This script will install lego
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

version="`/usr/bin/curl https://go.dev/dl/ | /bin/grep download | /bin/grep -v darwin | /bin/grep filename | /bin/grep  linux | /bin/grep amd64 | /bin/sed 's/.*>go//g' | /bin/grep -v rc | /bin/grep -v beta | /bin/grep -v alpha | /bin/sed 's/\.linux.*//g' | /usr/bin/head -1`"

if ( [ "${buildos}" = "ubuntu" ] )
then
	/usr/bin/curl -O -s https://storage.googleapis.com/golang/go${version}.linux-amd64.tar.gz
	/bin/tar -xf go${version}.linux-amd64.tar.gz
	/bin/mv go /usr/local
	/bin/rm go${version}.linux-amd64.tar.gz
 	if ( [ -f /usr/bin/go ] )
  	then
   		/bin/rm /usr/bin/go
     	fi
	/usr/bin/ln -s /usr/local/go/bin/go /usr/bin/go
fi

if ( [ "${buildos}" = "debian" ] )
then
	/usr/bin/curl -O -s https://storage.googleapis.com/golang/go${version}.linux-amd64.tar.gz
	/bin/tar -xf go${version}.linux-amd64.tar.gz
	/bin/mv go /usr/local
	/bin/rm go${version}.linux-amd64.tar.gz
  	if ( [ -f /usr/bin/go ] )
  	then
   		/bin/rm /usr/bin/go
     	fi
	/usr/bin/ln -s /usr/local/go/bin/go /usr/bin/go
fi
