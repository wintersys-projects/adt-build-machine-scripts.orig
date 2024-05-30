#!/bin/sh
######################################################################################################################
# Description: This will override and overwrite any setting that you have for CLOUDHOST in your template
# I ask for an interactive value for CLOUDHOST for operational reasons
# Author: Peter Winter
# Date: 13/06/2021
######################################################################################################################
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
######################################################################################################
#set -x

status "####################################################################################"
status "Please tell me which of the supported cloudhosts you are deploying to"
status " 1. Digital Ocean (www.digitalocean.com)"
status " 2. Exoscale (www.exoscale.com)"
status " 3. Linode (www.linode.com)"
status " 4. Vultr (www.vultr.com)"
status " Any value you give here will override and overwrite whatever you have set in your template"
status "####################################################################################"
status "You can indicate your choice by entering a number between 1 and 4"
read response

valid="0"

while ( [ "${valid}" = "0" ] )
do
	if ( [ "${response}" != "0" ] )
	then 
		if ( [ ${response} ] && [ ${response} -eq ${response} 2>/dev/null ] )
		then
			if ( [ "${response}" -lt "1" ] || [ "${response}" -gt "4" ] )
			then
				valid="0"
			else
				valid="1"
			fi
		else
			valid="0"
		fi
		if ( [ "${valid}" = "0" ] )
		then
			status "That was not a valid input, please try again...."
			read response
		else
			case  ${response}  in
				1)       
					CLOUDHOST="digitalocean"
					${BUILD_HOME}/installscripts/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
					 if ( [ "${BUILDOS}" = "ubuntu" ] )
					 then
						 DEFAULT_USER="root"
					 elif ( [ "${BUILDOS}" = "debian" ] )
					 then
						 DEFAULT_USER="root"
					 fi
					;;
				2)
					CLOUDHOST="exoscale"
					${BUILD_HOME}/installscripts/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
					if ( [ "${BUILDOS}" = "ubuntu" ] )
					then
						 DEFAULT_USER="ubuntu"
					elif ( [ "${BUILDOS}" = "debian" ] )
					then
						DEFAULT_USER="debian"
					fi
					;;            
				3)       
					CLOUDHOST="linode"
			${BUILD_HOME}/installscripts/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
					if ( [ "${BUILDOS}" = "ubuntu" ] )
					then
						DEFAULT_USER="root"
					 elif ( [ "${BUILDOS}" = "debian" ] )
					 then
						 DEFAULT_USER="root"
					 fi
					 ;;
				4)       
					CLOUDHOST="vultr"
			${BUILD_HOME}/installscripts/InstallCloudhostTools.sh ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}
					 if ( [ "${BUILDOS}" = "ubuntu" ] )
					 then
						 DEFAULT_USER="root"
					 elif ( [ "${BUILDOS}" = "debian" ] )
					 then
						 DEFAULT_USER="root"
					 fi
					 ;;
				*)
		   esac 
	   fi
	else
		status "That was not a valid input, please try again...."
		read response
	fi
done

status "Your cloudhost is set to ${CLOUDHOST}"
