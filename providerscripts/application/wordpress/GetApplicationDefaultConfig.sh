#!/bin/sh
####################################################################################
# Description: This will get the default configuration file from the datastore that
# the init webserver has written there during a non-virgin build. We try repeatedly
# because it takes the webserver a bit of time to realise it needs to upload the 
# default application configuration to the datastore
# Date: 07/11/2024
# Author: Peter Winter
####################################################################################
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
#####################################################################################
#####################################################################################
#set -x
 
while ( [ ! -f ${BUILD_HOME}/buildconfiguration/configuration.php.default ] )
do
	${BUILD_HOME}/providerscripts/datastore/configwrapper/GetFromConfigDatastore.sh ${WEBSITE_URL} wp-config-sample.php  ${BUILD_HOME}/buildconfiguration
 	/bin/sleep 10
done
