#!/bin/sh
###############################################################################################
# Description: This is the the expedited version of the top level build script for the 
# Agile Deployment Toolkit.
# Author Peter Winter
# Date 22/9/2020
##############################################################################################
#This is just a wrapper which adjusts the SSH connection timeouts so that connections are not
#dropped during the build. Correct me if I am wrong, but, the new SSH settings are picked up
#when a new shell is started as in /bin/sh ExpeditedAgileDeploymentToolkit.sh
###############################################################################################
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
################################################################################################
###############################################################################################
set -x

actioned="0"
if ( [ -f /etc/ssh/ssh_config ] && [ "`/bin/grep 'ServerAliveInterval 60' /etc/ssh/ssh_config`" = "" ] )
then
	/bin/echo "ServerAliveInterval 60" >> /etc/ssh/ssh_config
	/bin/echo "ServerAliveCountMax 20" >> /etc/ssh/ssh_config
	actioned="1"  
fi

if ( [ -f /etc/ssh/sshd_config ] && [ "`/bin/grep 'ClientAliveInterval 60' /etc/ssh/sshd_config`" = "" ] )
then
	/bin/echo "ClientAliveInterval 60
TCPKeepAlive yes
ClientAliveCountMax 10000" >> /etc/ssh/sshd_config
	BUILD_HOME="`/usr/bin/pwd`"
	${BUILD_HOME}/helperscripts/RunServiceCommand.sh sshd restart
	actioned="1"
fi

export HARDCORE="1"
export HOME="/root"
/bin/touch /root/HARDCORE

/usr/bin/stty -echo 
/bin/chmod 755 ExpeditedAgileDeploymentToolkit.sh 
./ExpeditedAgileDeploymentToolkit.sh 
