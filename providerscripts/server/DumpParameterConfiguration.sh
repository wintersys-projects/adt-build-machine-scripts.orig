#!/bin/sh
#####################################################################################
# Author: Peter Winter
# Date  : 13/07/2021
# Description : This records the build parameters into the requisite .dat file
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
######################################################################################
######################################################################################
#set -x  

if ( [ "${1}" = "autoscaler" ] )
then
	/bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat      
	while read param
	do
		param1="`eval /bin/echo ${param}`"
		 if ( [ "${param1}" != "" ] )
		 then
			 /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
		 fi
	done < ${BUILD_HOME}/builddescriptors/autoscalerscp.dat
fi  
   
if ( [ "${1}" = "webserver" ] )
then
	/bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat     
	while read param
	do
		param1="`eval /bin/echo ${param}`"
		if ( [ "${param1}" != "" ] )
		then
			/bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat
		fi
	done < ${BUILD_HOME}/builddescriptors/webserverscp.dat
fi  
	   
if ( [ "${1}" = "database" ] )
then
	/bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
		
	while read param
	do
		param1="`eval /bin/echo ${param}`"
		if ( [ "${param1}" != "" ] )
		then
			/bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
		fi
	done < ${BUILD_HOME}/builddescriptors/databasescp.dat
fi
