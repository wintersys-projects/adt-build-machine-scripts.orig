#!/bin/sh
#####################################################################################
# Description: This is a script which will generate an SSL Certificate. When a webserver
# is being built from the build client and not through the autoscaling mechanism, there
# are 3 scenarios
#
# 1) No certificate has been issued for the current domain name before in which case,
# one is generated and stored in the build directory hierarchy where it can be retrieved later
#
# 2) A certificate has been generated before for this domain name and we want to reuse it
# by selecting it from the build client filesystem where we stored it in 1. In this case,
# this script will not be used to generate a certificate.
#
# 3) There is a previously issued certificate we can use, but, it has expired, in which case
# this script will be used to generate a new certificate.
#
# Something to be aware of. There are limits set on certificate issuance so, if you run
# scenario 1, several times for some reason - it shouldn't happen in normal usage, then,
# you will hit the limit and certificates will stop being issued. In this case, it is
# necessary to wait some days and then the servers will see that you haven't issued
# certificates for a period and then reallow issuance and so on.
#####################################################################################
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

SUDO="/bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

if ( [ ! -d /usr/local/go ] )
then
	${BUILD_HOME}/installscripts/InstallGo.sh ${BUILDOS}
fi

export GOROOT=/usr/local/go
export GOPATH=$HOME
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

if ( [ ! -f /usr/bin/lego ] )
then
	${BUILD_HOME}/installscripts/InstallLego.sh ${BUILDOS}
fi

if ( [ ! -d ${BUILD_HOME}/.lego/accounts ] )
then
	/bin/mkdir -p  ${BUILD_HOME}/.lego/accounts 
fi

if ( [ ! -d ${BUILD_HOME}/.lego/certificates ] )
then
	/bin/mkdir -p  ${BUILD_HOME}/.lego/certificates 
fi

DOMAIN_URL="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F':' '{print $NF}' | /usr/bin/awk -F'.' '{$1="";print}' | /bin/sed 's/^ //' | /bin/sed 's/ /./g'`"

if ( [ "${DNS_CHOICE}" = "cloudflare" ] )
then
	#For production
	if ( [ "${SSL_LIVE_CERT}" = "1" ] )
	then
		command="CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
	else
	#For Testing
		command="CLOUDFLARE_EMAIL="${DNS_USERNAME}" CLOUDFLARE_API_KEY="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns-timeout=120 --accept-tos run"
	fi
fi

if ( [ "${DNS_CHOICE}" = "digitalocean" ] )
then
	 #For production
	 if ( [ "${SSL_LIVE_CERT}" = "1" ] )
	 then
		command="DO_AUTH_TOKEN="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
	 else
		 #For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
		 command="DO_AUTH_TOKEN="${DNS_SECURITY_KEY}" /usr/bin/lego --email="${DNS_USERNAME}" --server=https://acme-staging-v02.api.letsencrypt.org/directory --domains="${WEBSITE_URL}" --dns="${DNS_CHOICE}" --dns-timeout=120 --accept-tos run"
	 fi
fi

if ( [ "${DNS_CHOICE}" = "exoscale" ] )
then
	EXOSCALE_API_KEY="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $1}'`"
	EXOSCALE_API_SECRET="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $2}'`"

	#Production
	if ( [ "${SSL_LIVE_CERT}" = "1" ] )
	then
		command="EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
	else
		#For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
		command="EXOSCALE_API_KEY=${EXOSCALE_API_KEY} EXOSCALE_API_SECRET=${EXOSCALE_API_SECRET} /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
	fi
fi

if ( [ "${DNS_CHOICE}" = "linode" ] )
then
	LINODE_TOKEN="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $1}'`"

	#For production
	if ( [ "${SSL_LIVE_CERT}" = "1" ] )
	then
		command="LINODE_TOKEN=${LINODE_TOKEN} /usr/bin/lego --email ${DNS_USERNAME} --dns ${DNS_CHOICE}v4 --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
	else
		#For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
		command="LINODE_TOKEN=${LINODE_TOKEN} /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns ${DNS_CHOICE}v4 --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
	fi  
fi

if ( [ "${DNS_CHOICE}" = "vultr" ] )
then
	VULTR_API_KEY="`/bin/echo ${DNS_SECURITY_KEY} | /usr/bin/awk -F':' '{print $1}'`"

	#For production
	if ( [ "${SSL_LIVE_CERT}" = "1" ] )
	then
		command="VULTR_API_KEY=${VULTR_API_KEY} /usr/bin/lego --email ${DNS_USERNAME} --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
	else
		#For Development/Staging (will give insecure message in browser but isnt subject to issuance limits)
		command="VULTR_API_KEY=${VULTR_API_KEY} /usr/bin/lego --email ${DNS_USERNAME} --server=https://acme-staging-v02.api.letsencrypt.org/directory --dns ${DNS_CHOICE} --domains ${WEBSITE_URL} --dns-timeout=120 --accept-tos run"
	fi
fi

if ( [ ! -f ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.issuer.crt ] )
then
	status "Please wait, valid certificate not found, trying to issue SSL certificate for your domain ${WEBSITE_URL}"
	eval ${command}
	count="1"
	while ( [ "`/usr/bin/find ${BUILD_HOME}/.lego/certificates/${WEBSITE_URL}.issuer.crt -mmin -5 2>/dev/null`" = "" ] && [ "${count}" -lt "5" ] )
	do
		count="`/usr/bin/expr ${count} + 1`"
		/bin/sleep 5
		status "Failed to generate SSL Certificate, this is attempt ${count}"
		eval ${command}
	done
fi

if ( [ "${count}" = "5" ] )
then
	status "FAILED TO ISSUE SSL CERTIFICATE  (what is SSL_LIVE_CERT set to and have you hit an issuance limit for ${WEBSITE_URL}?)"
	status "Will have to exit, can't continue without the SSL certificate being set up"
	exit
fi
