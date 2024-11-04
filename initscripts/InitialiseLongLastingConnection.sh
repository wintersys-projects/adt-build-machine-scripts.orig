#!/bin/sh
#########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This toolkit will need uninterrupted ssh connections for extended periods of time
# so we can make that so by doing the below
#########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

if ( [ "${HARDCORE}" = "0" ] )
then
	actioned="0"
	if ( [ -f /etc/ssh/ssh_config ] && [ "`/bin/grep 'ServerAliveInterval 60' /etc/ssh/ssh_config`" = "" ] )
	then
		status ""
		status ""
		status "########################################################################################################################"
		status "Updating your client ssh config so that connections don't drop."
		status "If this is OK, press the <enter> key, if not, then ctrl-c to exit"
		status "########################################################################################################################"
		if ( [ "${HARDCORE}" != "1" ] )
		then
			read response
		fi
		/bin/echo "" >> /etc/ssh/ssh_config
		/bin/echo "ServerAliveInterval 60" >> /etc/ssh/ssh_config
		/bin/echo "ServerAliveCountMax 20" >> /etc/ssh/ssh_config
		actioned="1"  
	fi

	if ( [ -f /etc/ssh/sshd_config ] && [ "`/bin/grep 'ClientAliveInterval 60' /etc/ssh/sshd_config`" = "" ] )
	then
		status ""
		status ""
		status "########################################################################################################################"
		status "Updating your server ssh config so that connections don't drop from clients to this machine."
		status "If this is OK, press the <enter> key, if not, then ctrl-c to exit"
		status "########################################################################################################################"
		if ( [ "${HARDCORE}" != "1" ] )
		then
			read response
		fi
		/bin/echo "" >> /etc/ssh/sshd_config
		/bin/echo "ClientAliveInterval 60
TCPKeepAlive yes
ClientAliveCountMax 10000" >> /etc/ssh/sshd_config
		BUILD_HOME="`/usr/bin/pwd`"
		${BUILD_HOME}/helperscripts/RunServiceCommand.sh ssh restart
		actioned="1"
	fi

	if ( [ "${actioned}" = "1" ] )
	then
		status "############################YOU WILL ONLY NEED TO DO THIS ON THE FIRST RUN THROUGH ################################################################"
		status "SSH configuration settings have been updated, please rerun the ExpeditedAgileDeploymentToolkit script so that they are picked up"
		status "NOTE: if this is a VPS machine running remotely to your desktop, please make sure that you desktop machine is also configured to not drop"
		status "SSH connections within a few minutes as this will interrupt the build"
		status "############################YOU WILL ONLY NEED TO DO THIS ON THE FIRST RUN THROUGH ################################################################"
		exit
	fi
fi
