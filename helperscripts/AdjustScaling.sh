#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/01/2022
# Description : This script will adjust the scaling settings for your infrastructure
########################################################################################################
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

if ( [ ! -f  ./AdjustScaling.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

/bin/echo "Remember, scaling takes 15 minutes to come online after the completion of an initial build. If less than 5 minutes has passed, wait a bit, then adjust scaling"
/bin/echo "Press <enter> to acknowledge"
read x

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which cloudhost service are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr. Please Enter the number for your cloudhost"
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
else
	/bin/echo "Unrecognised  cloudhost. Exiting ...."
	exit
fi

/bin/echo "What is the build identifier you want to allow access for?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "${BUILD_IDENTIFIER}" > ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER

/bin/echo "OK, can you please tell me the FULL URL (without the https:// ) for the website you want to scale up/down is (e.g. demo.nuocial.org.uk)"
read website_url

SERVER_USER="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/SERVERUSER`"
TOKEN="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"

configbucket="`/bin/echo "${website_url}"-config | /bin/sed 's/\./-/g'`-${TOKEN}"

if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${CLOUDHOST} ${configbucket}`" = "" ] )
then
	/bin/echo "Can't find the configuration bucket in your datastore for website: ${website_url}"
	/bin/echo "I have to exit, run the script again using a URL with an existing configuration bucket"
	exit
fi

if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh ${CLOUDHOST} ${configbucket}/SWITCHOFFSCALING`" != "" ] )
then
	/bin/echo "Sorry, scaling is switched off at the moment. You can't switch it on using this script"
	exit
fi

if ( [ "${2}" = "off" ] )
then
	/bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SWITCHOFFSCALING
	${BUILD_HOME}/providerscripts/datastore/PutToDatastore.sh ${CLOUDHOST} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SWITCHOFFSCALING ${configbucket}/SWITCHOFFSCALING
	/bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/SWITCHOFFSCALING
	exit
fi

if ( [ "${2}" = "on" ] )
then
	${BUILD_HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${CLOUDHOST} ${configbucket}/SWITCHOFFSCALING
fi

${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${CLOUDHOST} ${configbucket}/scalingprofile/profile.cnf ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf

if ( [ ! -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf ] )
then
	/bin/echo "Warning, couldn't find profile file, will try and create a new one for you"
fi

original_no_webservers="`/bin/grep "NO_WEBSERVERS" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf | /usr/bin/awk -F'=' '{print $NF}'`"

if ( [ "${original_no_webservers}" = "" ] )
then
	original_no_webservers="0"
	/bin/echo  "SCALING_MODE=static" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf
	/bin/echo  "NO_WEBSERVERS=0" >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf
fi

/bin/echo "##################################################################################################################"
/bin/echo "Your number of webservers is currently set to: ${original_no_webservers}"
/bin/echo "What do you want to set your number of webservers to, please enter the number (2 or more) of webservers you want - as an integer"
/bin/echo "##################################################################################################################"
read no_webservers

while ( [ "${no_webservers}" = "" ] || [ "${no_webservers}" -lt "2" ] )
do
	/bin/echo "Number of webservers has to be 2 or more. Please input a different value"
	read no_webservers
done

/bin/echo ""
/bin/echo "Your number of webservers is about to be set to ${no_webservers}"
/bin/echo "Enter 'Y' or 'y' to accept, anything else to abort"
read response

if ( [ "${response}" != "Y" ] && [ "${response}" != "y" ] )
then
	exit
fi

/bin/sed -i "s/NO_WEBSERVER.*/NO_WEBSERVERS=${no_webservers}/" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf

${BUILD_HOME}/providerscripts/datastore/PutToDatastore.sh ${CLOUDHOST} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf ${configbucket}/scalingprofile/profile.cnf 
${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${CLOUDHOST} ${configbucket}/scalingprofile/profile.cnf ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf

new_no_webservers="`/bin/grep "NO_WEBSERVERS" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf | /usr/bin/awk -F'=' '{print $NF}'`"

/bin/echo ""
/bin/echo "Your number of webservers has been successfully set to: ${new_no_webservers}"
/bin/echo ""

/bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/profile.cnf




