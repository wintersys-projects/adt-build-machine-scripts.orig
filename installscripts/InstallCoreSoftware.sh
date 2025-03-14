#!/bin/sh
######################################################################################################
# Description: This will install all software on the build machine. If you add new software that 
# needs installing you will have to update it here as well. This takes the approach of installing all
# possible software that could be needed even if it is not needed for the current install. 
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

if ( [ ! -f /root/DATASTORETOOL_INSTALLED ] ||  [ "${BUILDOS}" = "ubuntu" ] )
then
	status "Installing/Updating Datastore tools"
	${BUILD_HOME}/installscripts/InstallDatastoreTools.sh "ubuntu"
 	/bin/touch /root/DATASTORETOOL_INSTALLED
elif ( [ "${BUILDOS}" = "debian" ] )
then
	status "Installing/Updating Datastore tools"
	${BUILD_HOME}/installscripts/InstallDatastoreTools.sh "debian"
 	/bin/touch /root/DATASTORETOOL_INSTALLED
fi

if ( [ ! -f ~/UPDATEDSOFTWARE ] || [ "`/usr/bin/find ~/UPDATEDSOFTWARE -mmin +1440 -print`" != "" ] )
then
	if ( [ ! -d /root/logs ] )
 	then
  		/bin/mkdir /root/logs
	fi
	
 	UPGRADE_LOG="/root/logs/upgrade_out-`/bin/date | /bin/sed 's/ //g'`"

	if ( [ "${HARDCORE}" != "1" ] )
	then   
		status "##################################################################################################"
		status "I am about to make software changes on this machine. If you are OK with that, please press <enter>"
		status "##################################################################################################"
		read x
	fi

	status "##################################################################################################################################################"
	status "Checking that the build software is up to date on this machine. Please wait .....This might take a few minutes the first time you run this script"
	status "This is best practice to make sure that all the software is at its latest versions prior to the build process"
	status "A log of the process is available at: ${UPGRADE_LOG}"
	status "##################################################################################################################################################"

	if ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Ubuntu"`" != "" ] )
	then
 			/bin/touch /root/PERFORM_REBOOT
			status "Performing software update....."
			${BUILD_HOME}/installscripts/Update.sh "ubuntu"  >>${UPGRADE_LOG} 2>&1
			status "Performing software upgrade....."
			${BUILD_HOME}/installscripts/Upgrade.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
   			status "Installing Firewall"
   			${BUILD_HOME}/installscripts/InstallFirewall.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Initialising Firewall"
   			${BUILD_HOME}/providerscripts/security/firewall/InitialiseFirewall.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating go"
			${BUILD_HOME}/installscripts/InstallGo.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating curl"
			${BUILD_HOME}/installscripts/InstallCurl.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating JQ"
			${BUILD_HOME}/installscripts/InstallJQ.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Lego"
			${BUILD_HOME}/installscripts/InstallLego.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Ruby"
			${BUILD_HOME}/installscripts/InstallRuby.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating SSHPass"
			${BUILD_HOME}/installscripts/InstallSSHPass.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Sudo"
			${BUILD_HOME}/installscripts/InstallSudo.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating SysVBanner"
			${BUILD_HOME}/installscripts/InstallSysVBanner.sh "ubuntu" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Cron"
			${BUILD_HOME}/installscripts/InstallCron.sh "ubuntu" >>${UPGRADE_LOG} 2>&1 
			/bin/touch ${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE
	elif ( [ "`/usr/bin/awk -F= '/^NAME/{print $2}' /etc/os-release | /bin/grep "Debian"`" != "" ] )
	then
  			/bin/touch /root/PERFORM_REBOOT
			status "Performing software update....."
			${BUILD_HOME}/installscripts/Update.sh "debian"  >>${UPGRADE_LOG} 2>&1
			status "Performing software upgrade....."
			${BUILD_HOME}/installscripts/Upgrade.sh "debian" >>${UPGRADE_LOG} 2>&1
   			status "Installing Firewall"
   			${BUILD_HOME}/installscripts/InstallFirewall.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Initialising Firewall"
   			${BUILD_HOME}/providerscripts/security/firewall/InitialiseFirewall.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating go"
			${BUILD_HOME}/installscripts/InstallGo.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating curl"
			${BUILD_HOME}/installscripts/InstallCurl.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating JQ"
			${BUILD_HOME}/installscripts/InstallJQ.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Lego"
			${BUILD_HOME}/installscripts/InstallLego.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Ruby"
			${BUILD_HOME}/installscripts/InstallRuby.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating SSHPass"
			${BUILD_HOME}/installscripts/InstallSSHPass.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Sudo"
			${BUILD_HOME}/installscripts/InstallSudo.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating SysVBanner"
			${BUILD_HOME}/installscripts/InstallSysVBanner.sh "debian" >>${UPGRADE_LOG} 2>&1
			status "Installing/Updating Cron"
			${BUILD_HOME}/installscripts/InstallCron.sh "debian" >>${UPGRADE_LOG} 2>&1 
			/bin/touch ${BUILD_HOME}/runtimedata/EXUPDATEDSOFTWARE
	fi
	/bin/touch ~/UPDATEDSOFTWARE
fi
