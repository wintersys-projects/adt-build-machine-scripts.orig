#!/bin/sh
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description: If you have bought your own ssl certificate from a 3rd party, then you can use 
# this script to update your chain file and your private key when that certificate expires. 
# Typically a certificate is valid for a period of 1 year and up.
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
#########################################################################################
#########################################################################################
#set -x

if ( [ ! -f  ./ManuallyUpdateSSLCertificate.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"
BUILD_IDENTIFIER="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER`"

/bin/echo "Which Cloudhost are you using for this server?"
/bin/echo "(1) Digital Ocean (2) Exoscale (3) Linode (4) Vultr"
read response

if ( [ "${response}" = "1" ] )
then
        CLOUDHOST="digitalocean"
elif ( [ "${response}" = "2" ] )
then
        CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
        CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
        CLOUDHOST="vultr"
fi

/bin/echo
/bin/echo "I can currently find the following domains"
domains="`/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl`"
/bin/echo
/bin/echo ${domains}
/bin/echo
/bin/echo "Please enter the URL for the domain you are updating"
read WEBSITE_URL

while ( [ "`/bin/echo ${domains} | /bin/grep ${WEBSITE_URL}`" = "" ] )
do
	/bin/echo "Sorry, that is not a matched domain name, please try again..."
	read WEBSITE_URL
done

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl/${WEBSITE_URL}/fullchain.pem ] )
then
	/bin/echo "Found a certificate for this domain. For your info, this is its expiry date"
	/usr/bin/openssl x509 -in ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl/${WEBSITE_URL}/fullchain.pem -noout -enddate
fi

/bin/echo "Please paste your new SSL certificate chain. <ctrl-d> when done and please make sure the chain is exactly as intended"
/bin/echo "ESSENTIAL - Only copy from the first dash in the file '-' to the last dash in the file. Do not copy any prefixed whitespace or suffixed whitespace"

chain=`cat`

/bin/cp ${BUILD_HOME}/ssl/${WEBSITE_URL}/fullchain.pem ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl/${WEBSITE_URL}/fullchain.pem.previous.`/bin/date | /bin/sed 's/ //g'`

/bin/echo "${chain}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl/${WEBSITE_URL}/fullchain.pem

/bin/echo

/bin/echo "Please paste your new SSL private key. <ctrl-d> when done and please make sure the chain is exactly as intended"
/bin/echo "ESSENTIAL - Only copy from the first dash in the file '-' to the last dash in the file. Do not copy any prefixed whitespace or suffixed whitespace"

privkey=`cat`

/bin/cp ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl/${WEBSITE_URL}/privkey.pem ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl/${WEBSITE_URL}/privkey.pem.previous.`/bin/date | /bin/sed 's/ //g'`

/bin/echo "${privkey}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ssl/${WEBSITE_URL}/privkey.pem

cd ${BUILD_HOME}/helperscripts

sourcefile="SSL"
/bin/echo
/bin/echo "OK, about to update the copy of your SSL certificate on the autoscaler. Are you sure? <enter> for yes, <ctrl-c> for no"
read x
. ./CopyToAutoscaler.sh

/bin/echo
/bin/echo "OK, about to update the copy of your SSL certificate on the webserver(s). Are you sure? <enter> for yes, <ctrl-c> for no"
read x
. ./CopyToWebserver.sh



