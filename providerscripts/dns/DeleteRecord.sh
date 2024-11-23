#!/bin/sh
##################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will delete a DNS record from your DNS provider
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

domain="${7}"
domainurl="`/bin/echo ${domain} | /usr/bin/cut -d'.' -f2-`"
recordid="${2}"
dns="${5}"

if ( [ "${dns}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute domain records delete --force ${domainurl} ${recordid}
fi

zoneid="${1}"
recordid="${2}"
email="${3}"
authkey="${4}"
dns="${5}"

if ( [ "${dns}" = "cloudflare" ] )
then
	/usr/bin/curl -X DELETE "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records/${recordid}" -H "X-Auth-Email: ${email}"  -H "X-Auth-Key: ${authkey}" -H "Content-Type: application/json"
fi

recordid="${2}"
authkey="${4}"
dns="${5}"
domainurl="`/bin/echo ${7} | /usr/bin/cut -d'.' -f2-`"

if ( [ "${dns}" = "exoscale" ] )
then
	/usr/bin/exo dns remove ${domainurl} ${recordid} -Q -f
	#Alternative
	#/usr/bin/curl  -H "X-DNS-Token: ${authkey}"  -H 'Accept: application/json' -X DELETE  https://api.exoscale.com/dns/v1/domains/${domainurl}/records/${recordid} 1>/dev/null 2>/dev/null
fi

record_id="${2}"
dns="${5}"
domain_url="`/bin/echo ${7} | /usr/bin/cut -d'.' -f2-`"
#domain_url="${7}"

if ( [ "${dns}" = "linode" ] )
then
	domain_id="`/usr/local/bin/linode-cli --json linodes list | /usr/bin/jq -r '.[] | select (.domain | contains("'${domain_url}'")).id'`"
	/usr/local/bin/linode-cli domains records-delete ${domain_id} ${record_id}
fi

recordid="${2}"
authkey="${4}"
dns="${5}"
domainurl="`/bin/echo ${7} | /usr/bin/cut -d'.' -f2-`"

if ( [ "${dns}" = "vultr" ] )
then
	/usr/bin/vultr dns record delete ${domainurl} ${recordid}
fi


