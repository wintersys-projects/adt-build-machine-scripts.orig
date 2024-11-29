#!/bin/sh
######################################################################################################
# Description: This script will perform a software update
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

if ( [ "`/bin/grep "^PACKAGEMANAGER:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "apt" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		/usr/bin/yes | /usr/bin/dpkg --configure -a
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 install -y -qq apt-utils
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages    
	fi

	if ( [ "${buildos}" = "debian" ] )
	then
		/usr/bin/yes | /usr/bin/dpkg --configure -a
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 install -y -qq apt-utils 
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages    
	fi
fi

if ( [ "`/bin/grep "^PACKAGEMANAGER:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "apt-fast" ] )
then
	if ( [ "${buildos}" = "ubuntu" ] )
	then
		/usr/bin/yes | /usr/bin/dpkg --configure -a
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 install -y -qq apt-utils
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages  
                if ( [ ! -d /usr/local/apt-fast ] )
                then
                        /bin/mkdir /usr/local/apt-fast
                else
                        /bin/rm -r /usr/local/apt-fast/*
                        /bin/rm -r /usr/local/apt-fast/.*
                fi
                /usr/bin/git clone https://github.com/ilikenwf/apt-fast.git /usr/local/apt-fast
                /bin/ln -s /usr/local/apt-fast/apt-fast /usr/sbin/apt-fast
                /bin/chmod +x /usr/sbin/apt-fast
                /bin/ln -s /usr/local/apt-fast/apt-fast.conf /etc/apt-fast.conf
                /bin/chown root:root /etc/apt-fast.conf
                /bin/chown root:root /usr/sbin/apt-fast
                /usr/bin/snap install aria2c  
	fi
	
	if ( [ "${buildos}" = "debian" ] )
	then
		/usr/bin/yes | /usr/bin/dpkg --configure -a
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 install -y -qq apt-utils 
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 install -y -qq aria2 
		DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get -o DPkg::Lock::Timeout=-1 -qq -y update --allow-change-held-packages  
                if ( [ ! -d /usr/local/apt-fast ] )
                then
                        /bin/mkdir /usr/local/apt-fast
                else
                        /bin/rm -r /usr/local/apt-fast/*
                        /bin/rm -r /usr/local/apt-fast/.*
                fi
                /usr/bin/git clone https://github.com/ilikenwf/apt-fast.git /usr/local/apt-fast
                /bin/ln -s /usr/local/apt-fast/apt-fast /usr/sbin/apt-fast
                /bin/chmod +x /usr/sbin/apt-fast
                /bin/ln -s /usr/local/apt-fast/apt-fast.conf /etc/apt-fast.conf
                /bin/chown root:root /etc/apt-fast.conf
                /bin/chown root:root /usr/sbin/apt-fast
                /usr/bin/snap install aria2c  
	fi   
fi

