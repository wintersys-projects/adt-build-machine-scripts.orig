#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This will initialise the s3cmd configuration file for your datastore provider
# that you are using. Template is held in the "configfiles"
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

if ( [ -f ${BUILD_HOME}/.s3cfg ] )
then
	/bin/rm ${BUILD_HOME}/.s3cfg
fi

if ( [ -f ${BUILD_HOME}/.s5cfg ] )
then
	/bin/rm ${BUILD_HOME}/.s5cfg
fi

status ""
status "##############################"
status "Configuring datastore tools..."
status "##############################"

/bin/cp ${BUILD_HOME}/initscripts/configfiles/datastore/s3-cfg.tmpl  ${BUILD_HOME}/.s3cfg

if ( [ "${S3_ACCESS_KEY}" != "" ] )
then
	/bin/sed -i "s/XXXXACCESSKEYXXXX/${S3_ACCESS_KEY}/" ${BUILD_HOME}/.s3cfg
	/bin/echo "[default]" > ${BUILD_HOME}/.s5cfg 
 	/bin/echo "aws_access_key_id = ${S3_ACCESS_KEY}" >> ${BUILD_HOME}/.s5cfg
else 
	status "Couldn't find the access key for your datastore, can't go on without it, will have to exit"
	exit
fi

if ( [ "${S3_SECRET_KEY}" != "" ] )
then
	/bin/sed -i "s/XXXXSECRETKEYXXXX/${S3_SECRET_KEY}/" ${BUILD_HOME}/.s3cfg
 	/bin/echo "aws_secret_access_key = ${S3_SECRET_KEY}" >> ${BUILD_HOME}/.s5cfg

else 
	status "Couldn't find the secret key for your datastore, can't go on without it, will have to exit"
	exit
fi

if ( [ "${S3_LOCATION}" != "" ] )
then
	/bin/sed -i "s/XXXXLOCATIONXXXX/${S3_LOCATION}/" ${BUILD_HOME}/.s3cfg
else 
	status "Couldn't find the secret key for your datastore, can't go on without it, will have to exit"
	exit
fi

if ( [ "${S3_HOST_BASE}" != "" ] )
then
	/bin/sed -i "s/XXXXHOSTBASEXXXX/${S3_HOST_BASE}/" ${BUILD_HOME}/.s3cfg
  	/bin/echo "host_base = ${S3_HOST_BASE}" >> ${BUILD_HOME}/.s5cfg
    	/bin/echo "alias s5cmd='/usr/bin/s5cmd --credentials-file /root/.s5cfg --endpoint-url https://${S3_HOST_BASE}'" >> /root/.bashrc

else 
	status "Couldn't find the hostbase parameter for your datastore, can't go on without it, will have to exit"
	exit
fi

if ( [ -f /root/.s3cfg ] )
then
	/bin/rm /root/.s3cfg
fi

/bin/cp ${BUILD_HOME}/.s3cfg /root/.s3cfg

if ( [ -f /root/.s5cfg ] )
then
	/bin/rm /root/.s5cfg
fi

/bin/cp ${BUILD_HOME}/.s5cfg /root/.s5cfg


${BUILD_HOME}/providerscripts/datastore/MountDatastore.sh "${WEBSITE_URL}" "1$$agile" 3>&1 2>/dev/null
${BUILD_HOME}/providerscripts/datastore/DeleteDatastore.sh "${WEBSITE_URL}" "1$$agile" 3>&1 2>/dev/null

if ( [ "$?" != "0" ] )
then
	status "I can't access your datastore, it isn't possible to continue. Please check the following settings in the template you are using:"
	status "S3_ACCESS_KEY,S3_SECRET_KEY,S3_LOCATION and S3_HOST_BASE"
	exit
fi
	
${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh "${WEBSITE_URL}"

if ( [ "$?" = "0" ] )
then
	status "Purging configuration bucket in datastore (s3://`/bin/echo "${WEBSITE_URL}"-config | /bin/sed 's/\./-/g'`) so it is fresh for this build"
	${BUILD_HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "${WEBSITE_URL}" "purge"
else
	status "Couldn't find an existing configuration bucket so I am creating a new one (s3://`/bin/echo "${WEBSITE_URL}"-config | /bin/sed 's/\./-/g'`) for you"
	${BUILD_HOME}/providerscripts/datastore/configwrapper/MountConfigDatastore.sh "${WEBSITE_URL}"
fi
