
#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This will initialise the configuration files for the cloudhost
# provider's cli tool that you are usning. Templates are held in the "configfiles"
# subdirectory
##################################################################################
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

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
	if ( [ -f ${BUILD_HOME}/.config/doctl/config.yaml ] )
	then
		/bin/rm ${BUILD_HOME}/.config/doctl/config.yaml
	fi
	
	status "Configuring Digital Ocean CLI tool"

	if ( [ ! -d ${BUILD_HOME}/.config/doctl ] )
	then
		/bin/mkdir -p ${BUILD_HOME}/.config/doctl
	fi
	
	/bin/cp ${BUILD_HOME}/initscripts/configfiles/digitalocean/digitalocean.tmpl ${BUILD_HOME}/.config/doctl/config.yaml

	if ( [ "${TOKEN}" != "" ] )
	then
		/bin/sed -i "s/XXXXTOKENXXXX/${TOKEN}/" ${BUILD_HOME}/.config/doctl/config.yaml
	else 
		status "Couldn't find your digital ocean account personal access token in your template, will have to exit"
		exit
	fi

	if ( [ ! -d /root/.config/doctl ] )
	then
		/bin/mkdir -p /root/.config/doctl
	fi

	/bin/echo "${TOKEN}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN
	/bin/chmod 700 ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN
	
	/bin/cp ${BUILD_HOME}/.config/doctl/config.yaml /root/.config/doctl/config.yaml
	/bin/chown root:root ${BUILD_HOME}/.config/doctl/config.yaml /root/.config/doctl/config.yaml
	/bin/chmod 400 ${BUILD_HOME}/.config/doctl/config.yaml /root/.config/doctl/config.yaml

	if ( [ "${HARDCORE}" = "0" ] )
 	then
		/usr/local/bin/doctl balance get >&3
	else
 		/usr/local/bin/doctl balance get
	fi

	if ( [ "$?" != "0" ] )
	then
		status "Couldn't get the Digitalocean CLI tool to work, you will need to look into why. I have to exit..."
		exit
	fi 
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
	if ( [ -f ${BUILD_HOME}/.exoscale.toml ] )
	then
		/bin/rm ${BUILD_HOME}/.exoscale.toml
	fi

	status "Configuring Exoscale CLI tool"

	/bin/cp ${BUILD_HOME}/initscripts/configfiles/exoscale/exoscale.tmpl  ${BUILD_HOME}/.exoscale.toml

	if ( [ "${CLOUDHOST_ACCOUNT_ID}" != "" ] )
	then
		/bin/sed -i "s/XXXXCLOUDEMAILADDRESSXXXX/${CLOUDHOST_ACCOUNT_ID}/" ${BUILD_HOME}/.exoscale.toml
	else 
		status "Couldn't find your exoscale cloud email address in your template, will have to exit"
		exit
	fi

	if ( [ "${REGION}" != "" ] )
	then
		/bin/sed -i "s/XXXXREGIONXXXX/${REGION}/" ${BUILD_HOME}/.exoscale.toml
	else 
		status "Couldn't find your region in your template, will have to exit"
		exit
	fi

	if ( [ "${ACCESS_KEY}" != "" ] )
	then
		/bin/sed -i "s/XXXXACCESSKEYXXXX/${ACCESS_KEY}/" ${BUILD_HOME}/.exoscale.toml
		/bin/echo "${ACCESS_KEY}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ACCESS_KEY
	else 
		status "Couldn't find your access key in your template, will have to exit"
		exit
	fi

	if ( [ "${SECRET_KEY}" != "" ] )
	then
		/bin/sed -i "s/XXXXSECRETKEYXXXX/${SECRET_KEY}/" ${BUILD_HOME}/.exoscale.toml
		/bin/echo "${SECRET_KEY}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SECRET_KEY
	else 
		status "Couldn't find your secret key in your template, will have to exit"
		exit
	fi

	if ( [ ! -d /root/.config/exoscale ] )
	then
		/bin/mkdir -p /root/.config/exoscale
	fi
	
	/bin/cp ${BUILD_HOME}/.exoscale.toml /root/.config/exoscale/exoscale.toml
	/bin/chown root:root ${BUILD_HOME}/.exoscale.toml /root/.config/exoscale/exoscale.toml
	/bin/chmod 400 ${BUILD_HOME}/.exoscale.toml /root/.config/exoscale/exoscale.toml

	if ( [ "${HARDCORE}" = "0" ] )
 	then
		/usr/bin/exo status >&3
  	else
		/usr/bin/exo status
  	fi

	if ( [ "$?" != "0" ] )
	then
		status "Couldn't get the Exoscale CLI tool to work, you will need to look into why. I have to exit..."
		exit
	fi 

fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
	if ( [ -f ${BUILD_HOME}/.linode-cli ] )
	then
		/bin/rm ${BUILD_HOME}/.linode-cli
	fi

	status "Configuring Linode CLI tool"

	/bin/cp ${BUILD_HOME}/initscripts/configfiles/linode/linode-cli.tmpl  ${BUILD_HOME}/.linode-cli

	if ( [ "${CLOUDHOST_ACCOUNT_ID}" != "" ] )
	then
		/bin/sed -i "s/XXXXLINODEACCOUNTUSERNAMEXXXX/${CLOUDHOST_ACCOUNT_ID}/" ${BUILD_HOME}/.linode-cli
	else 
		status "Couldn't find your linode account username in your template, will have to exit"
		exit
	fi

	if ( [ "${TOKEN}" != "" ] )
	then
		/bin/sed -i "s/XXXXTOKENXXXX/${TOKEN}/" ${BUILD_HOME}/.linode-cli
	else 
		status "Couldn't find your linode account personal access token in your template, will have to exit"
		exit
	fi

	if ( [ "${REGION}" != "" ] )
	then
		/bin/sed -i "s/XXXXREGIONXXXX/${REGION}/" ${BUILD_HOME}/.linode-cli
	else 
		status "Couldn't find your region id in your template, will have to exit"
		exit
	fi

	if ( [ ! -d /root/.config ] )
	then
		/bin/mkdir /root/.config
	fi

	/bin/echo "${TOKEN}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN
	/bin/chmod 700 ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN

	/bin/cp  ${BUILD_HOME}/.linode-cli /root/.config/linode-cli
	/bin/chown root:root /root/.config/linode-cli ${BUILD_HOME}/.linode-cli
	/bin/chmod 400 /root/.config/linode-cli ${BUILD_HOME}/.linode-cli
	
 	if ( [ "${HARDCORE}" = "0" ] )
 	then
		/usr/local/bin/linode-cli account view >/dev/null 2>/dev/null >&3
  	else
   		/usr/local/bin/linode-cli account view >/dev/null 2>/dev/null
	fi
	
	if ( [ "$?" != "0" ] )
	then
		status "Couldn't get the Linode CLI tool to work, you will need to look into why. I have to exit..."
		exit
	fi 
	
	/usr/local/bin/linode-cli region-table >/dev/null 2>/dev/null >&3

fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
	if ( [ "${TOKEN}" != "" ] )
	then
	#	export VULTR_API_KEY="${TOKEN}"
		/bin/echo ${TOKEN} > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN
  	#	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN`"
		/bin/echo "api-key: ${TOKEN}" > ${BUILD_HOME}/.vultr-cli.yaml
		/bin/echo "api-key: ${TOKEN}" > /root/.vultr-cli.yaml
		/bin/chown root:root ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN ${BUILD_HOME}/.vultr-cli.yaml /root/.vultr-cli.yaml
		/bin/chmod 400 ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/TOKEN ${BUILD_HOME}/.vultr-cli.yaml /root/.vultr-cli.yaml
	else
		status "Couldn't find your vultr API key from your template - will have to exit...."
		exit
	fi
 
	if ( [ "${HARDCORE}" = "0" ] )
 	then	
		/usr/bin/vultr account >&3
  	else
   		/usr/bin/vultr account
	fi
		
	if ( [ "$?" != "0" ] )
	then
		status "Couldn't get the Vultr CLI tool to work, you will need to look into why. I have to exit..."
		exit
	fi 
fi

if ( [ ! -d ${BUILD_HOME}/runtimedata ] )
then
	/bin/mkdir ${BUILD_HOME}/runtimedata
fi

/bin/echo "${CLOUDHOST}" > ${BUILD_HOME}/runtimedata/BUILD_MACHINE_CLOUDHOST
