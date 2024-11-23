#!/bin/sh
########################################################################################
# Description: This script will create a zone with your DNS provider. With some providers
# it may be necessary to manually create the initial zone for your domain using their gui
# Author: Peter Winter
# Date: 02/01/2017
########################################################################################
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
########################################################################################
########################################################################################
#set -x

email="${1}"
apikey="${2}"
websiteurl="`/bin/echo ${3} | /usr/bin/cut -d'.' -f2-`"
dns="${4}"

if ( [ "${dns}" = "" ] )
then
	/bin/echo "-1"
else

	if ( [ "${dns}" = "cloudflare" ] )
	then
		/usr/bin/curl -X POST "https://api.cloudflare.com/client/v4/zones" -H "X-Auth-Email: ${email}" -H "X-Auth-Key: ${apikey}" -H "Content-Type: application/json" --data "{\"name\":\"${websiteurl}\"}" > /dev/null 2>&1
	fi
	
	domainurl="`/bin/echo ${3} | /usr/bin/cut -d'.' -f2-`"
	dns="${4}"
	
	if ( [ "${dns}" = "digitalocean" ] )
	then
		/usr/local/bin/doctl compute domain create ${domainurl}
	fi

	email="${1}"
	apikey="${2}"
	websiteurl="`/bin/echo ${3} | /usr/bin/cut -d'.' -f2-`"
	domainurl="`/bin/echo ${3} | /usr/bin/cut -d'.' -f2-`"
	dns="${4}"

	if ( [ "${dns}" = "exoscale" ] )
	then
	   /usr/bin/exo dns create ${domainurl}    
	   #Alternatively:
	   # /usr/bin/curl -H "X-DNS-Token: ${apikey}" -H 'Accept: application/json' -X DELETE https://api.exoscale.com/dns/v1/domains/${domainurl}/zone 1>/dev/null 2>/dev/null
	   # /bin/sleep 5
	   # /usr/bin/curl -H "X-DNS-Token: ${apikey}" -H 'Accept: application/json' -H 'Content-Type: application/json' -d "{\"domain\":{\"name\":\"${websiteurl}\"}}" -X POST https://api.exoscale.com/dns/v1/domains 1>/dev/null 2>/dev/null
	fi
	
	email="${1}"
	domainurl="`/bin/echo ${3} | /usr/bin/cut -d'.' -f2-`"
	dns="${4}"
	
	if ( [ "${dns}" = "linode" ] )
	then
		/usr/local/bin/linode-cli domains create --type master --domain ${domainurl} --soa_email ${email}
	fi
	
	email="${1}"
	authkey="${2}"
	domainurl="`/bin/echo ${3} | /usr/bin/cut -d'.' -f2-`"
	dns="${4}"
	
	if ( [ "${dns}" = "vultr" ] )
	then
		/usr/bin/vultr dns domain create -d ${domainurl}
	fi
	
fi
