#!/bin/sh
#################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will retrieve all the record id's for the selected
# domain name (website url)
#################################################################################
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
###################################################################################
###################################################################################
#set -x

websiteurl="${2}"
domainurl="`/bin/echo ${2} | /usr/bin/cut -d'.' -f2-`"
subdomain="`/bin/echo ${2} | /usr/bin/awk -F'.' '{print $1}'`"
dns="${5}"

if ( [ "${dns}" = "digitalocean" ] )
then
	/usr/local/bin/doctl compute domain records list ${domainurl} | /bin/grep ${subdomain} | /usr/bin/awk '{print $1}'
fi

zoneid="${1}"
websiteurl="${2}"
email="${3}"
authkey="${4}"
dns="${5}"

if ( [ "${dns}" = "cloudflare" ] )
then
	/usr/bin/curl -X GET "https://api.cloudflare.com/client/v4/zones/${zoneid}/dns_records?type=A&name=${websiteurl}&page=1&per_page=20&order=type&direction=desc&match=all" -H "X-Auth-Email: ${email}" -H "X-Auth-Key: ${authkey}" -H "Content-Type: application/json" | /usr/bin/jq -r '.result[].id'
fi

domainurl="`/bin/echo ${2} | /usr/bin/cut -d'.' -f2-`"
subdomain="`/bin/echo ${2} | /usr/bin/awk -F'.' '{print $1}'`"
authkey="`/bin/echo ${4} | /usr/bin/awk -F':' '{print $NF}'`"
dns="${5}"

if ( [ "${dns}" = "exoscale" ] )
then
	/usr/bin/exo -O json dns show ${domainurl}  | /usr/bin/jq -r '.[] | select (.name | contains("'${domain_url}'")).id'`"
 	#Alternative
	#/usr/bin/curl  -H "X-DNS-Token: ${authkey}" -H 'Accept: application/json' https://api.exoscale.com/dns/v1/domains/${domainurl}/records | /usr/bin/jq --arg tmp_subdomain "${subdomain}" '.[].record | select (.name == $tmp_subdomain) | .id'
fi

domain_url="`/bin/echo ${2} | /usr/bin/cut -d'.' -f2-`"
#domain_url="${2}"
subdomain="`/bin/echo ${2} | /usr/bin/awk -F'.' '{print $1}'`"
dns="${5}"

if ( [ "${dns}" = "linode" ] )
then
	/usr/local/bin/linode-cli --json linodes list | /usr/bin/jq -r '.[] | select (.domain | contains("'${domain_url}'")).id'
fi

domainurl="`/bin/echo ${2} | /usr/bin/cut -d'.' -f2-`"
subdomain="`/bin/echo ${2} | /usr/bin/awk -F'.' '{print $1}'`"
authkey="${4}"
dns="${5}"

if ( [ "${dns}" = "vultr" ] )
then
	/usr/bin/vultr dns record list ${domainurl} -o json | /usr/bin/jq -r '.records[] | select (.name == "'${subdomain}'").id'
fi
