
#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This will create the DNS record for your current domain and is called
# at the end of building a webserver
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

if ( [ "${alive}" = "/home/${SERVER_USER}/runtime/WEBSERVER_READY" ] && [ "${DNS_CHOICE}" != "NONE" ] )
then
	#If we get to here then we know that the webserver was built correctly
	#We have to configure it some more and add it to the DNS provider's DNS so we can access the webserver
	#Please note, we make use of the implicit DNS loadbalancing system with our webservers
	name="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"

	#Create  zone if it doesn't already exist
			
	zonename="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{$1=""}1' | /bin/sed 's/^ //g' | /bin/sed 's/ /./g'`"
	zoneid="`${BUILD_HOME}/providerscripts/dns/GetZoneID.sh "${zonename}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"
		   
	if ( [ "${zoneid}" = "" ] )
	then
		${BUILD_HOME}/providerscripts/dns/CreateZone.sh "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${DNS_CHOICE}" "${DNS_REGION}"
	fi
		   
	status "We are adding our DNS records to the DNS provider you selected, in this case ${DNS_CHOICE}"
	zoneid="`${BUILD_HOME}/providerscripts/dns/GetZoneID.sh "${zonename}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"
		   
	if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
	then
		while ( [ "${zoneid}" = "" ] )
		do
			status "Attempting to get zone id for the DNS system (this may take a few retries)....if, after some time, I can't get your zone id check that your nameservers are configured correctly. Please wait...."
			/bin/sleep 30
			zoneid="`${BUILD_HOME}/providerscripts/dns/GetZoneID.sh "${zonename}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"
		done
	fi
		  
	recordids="`${BUILD_HOME}/providerscripts/dns/GetAllRecordIDs.sh  "${zoneid}" "${WEBSITE_URL}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}"`"

	if ( [ "${recordids}" != "" ] )
	then
		for recordid in ${recordids}
		do
			${BUILD_HOME}/providerscripts/dns/DeleteRecord.sh "${zoneid}" "${recordid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"
		done
	fi

	#Add our record to the dns. Please note, proxying has to be off, but we need the ip address to be active with our DNS provider
	#provider. The reason why proxying is off is that the system we use to install SSL certificates does not work when proxying is on

	${BUILD_HOME}/providerscripts/dns/AddRecord.sh "${zoneid}" "${DNS_USERNAME}" "${DNS_SECURITY_KEY}" "${WEBSITE_URL}" "${WSIP}" "true" "${DNS_CHOICE}" "${DNS_REGION}" "${WEBSITE_URL}"

fi
