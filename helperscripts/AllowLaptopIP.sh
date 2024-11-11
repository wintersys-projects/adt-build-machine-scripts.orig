#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/01/2022
# Description : You can grant laptop ip addresses access to your build machine using this script.
# The firewall of your build machine will allow SSH connections from the ip address that you provide
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
set -x

if ( [ "`/bin/ls /root/FIREWALL-BUCKET:*  2>/dev/null`" != "" ] )
then
        IDENTIFIER="`/bin/ls /root/FIREWALL-BUCKET:* | /usr/bin/awk -F':' '{print $NF}'  2>/dev/null`"
else
        /bin/echo "Could not find an identifier for your datastore's firewall bucket"
        exit
fi

if ( [ ! -f  ./AllowLaptopIP.sh ] )
then
        /bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
        exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which datastore provider are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
        DATASTORE_PROVIDER="digitalocean"
        token_to_match="*autoscaler*"
elif ( [ "${response}" = "2" ] )
then
        DATASTORE_PROVIDER="exoscale"
        token_to_match="autoscaler"
elif ( [ "${response}" = "3" ] )
then
        DATASTORE_PROVIDER="linode"
        token_to_match="*autoscaler*"
elif ( [ "${response}" = "4" ] )
then
        DATASTORE_PROVIDER="vultr"
        token_to_match="*autoscaler*"
else
        /bin/echo "Unrecognised  cloudhost. Exiting ...."
        exit
fi

if ( [ ! -d ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips ] )
then
        /bin/mkdir -p ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips
fi

/bin/echo "Please enter the IP address of your laptop that you are modifying access for. You can find the ip address of your laptop using: www.whatsmyip.com"
read ip

/bin/echo "Do you want to add or remove access for this ip address?"
/bin/echo "1) Add  2) Remove"
read mode

while ( [ "`/bin/echo "1 2" | /bin/grep ${mode}`" = "" ] )
do
        /bin/echo "I don't recognise that input..."
        /bin/echo "Please enter 1 or 2"
        read mode
done

${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${DATASTORE_PROVIDER} ${IDENTIFIER}/authorised-ips.dat ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat

if ( [ ! -f ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat ] )
then
        /bin/echo "Couldn't find existing authorised ip addresses"
        ${BUILD_HOME}/providerscripts/datastore/MountDatastore.sh ${DATASTORE_PROVIDER} ${IDENTIFIER}
fi

if ( [ "${mode}" = "1" ] )
then
        /bin/echo ${ip} >> ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat
else
        /bin/sed -i "/${ip}/d" ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat
fi

/bin/cat ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat | /usr/bin/sort | /usr/bin/uniq >> ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat.$$
/bin/mv ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat.$$ ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat
${BUILD_HOME}/providerscripts/datastore/SyncDatastore.sh ${DATASTORE_PROVIDER} ${BUILD_HOME}/runtimedata/${DATASTORE_PROVIDER}/ips/authorised-ips.dat ${IDENTIFIER}/authorised-ips.dat
/bin/touch  ${BUILD_HOME}/runtimedata/FIREWALL-EVENT
${BUILD_HOME}/providerscripts/datastore/SyncDatastore.sh ${DATASTORE_PROVIDER} ${BUILD_HOME}/runtimedata/FIREWALL-EVENT ${IDENTIFIER}/FIREWALL-EVENT
/bin/rm ${BUILD_HOME}/runtimedata/FIREWALL-EVENT
