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

if ( [ "${buildos}" = "ubuntu" ] )
then
	cwd="`/usr/bin/pwd`"
	/bin/mkdir -p /usr/local/src/lego
	cd /usr/local/src/lego
	version="`/usr/bin/wget -O- -q https://github.com/go-acme/lego/releases/latest | /bin/grep -oP 'Release\K.*' | /usr/bin/head -1 | /usr/bin/awk '{print $1}' | /bin/sed "s/[^[:digit:].-]//g"`" 
	/usr/bin/wget https://github.com/xenolf/lego/releases/download/v${version}/lego_v${version}_linux_amd64.tar.gz    
	/bin/tar xvfz lego*tar.gz
	/bin/rm *lego*tar.gz
	/bin/cp lego /usr/bin/
	cd ${cwd}
fi

if ( [ "${buildos}" = "debian" ] )
then
	cwd="`/usr/bin/pwd`"
	/bin/mkdir -p /usr/local/src/lego
	cd /usr/local/src/lego
	version="`/usr/bin/wget -O- -q https://github.com/go-acme/lego/releases/latest | /bin/grep -oP 'Release\K.*' | /usr/bin/head -1 | /usr/bin/awk '{print $1}' | /bin/sed "s/[^[:digit:].-]//g"`" 
	/usr/bin/wget https://github.com/xenolf/lego/releases/download/v${version}/lego_v${version}_linux_amd64.tar.gz    
	/bin/tar xvfz lego*tar.gz
	/bin/rm *lego*tar.gz
	/bin/cp lego /usr/bin/
	cd ${cwd}
fi

