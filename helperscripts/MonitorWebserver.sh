#!/bin/sh
####################################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This script will monitor and log the results of your website
#####################################################################################################
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

if ( [ ! -f  ./MonitorWebserver.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

if ( [ "$1" = "" ] )
then
	/bin/echo "Usage: ./MonitorWebserver.sh <website url>"
	exit
fi

export BUILD_HOME="`/bin/pwd | /bin/sed 's/\/helper.*//g'`"

if ( [ ! -d ${BUILD_HOME}/helperscripts/logs ] )
then
	/bin/mkdir ${BUILD_HOME}/helperscripts/logs
fi

/bin/echo "Starting up......<Ctrl-C> to terminate"
/bin/echo "Please enter the periodicity of your monitoring test in second - 1 second between tests, 5 seconds, 20 seconds and so on"
read periodicity

case ${periodicity} in
	''|*[!0-9]*) /bin/echo "That's not a number" ;;
	*) /bin/echo "OK, starting monitoring" ;;
esac

if ( [ ! -f ${BUILD_HOME}/helperscripts/logs ] )
then
	/bin/mkdir ${BUILD_HOME}/helperscripts/logs 2>/dev/null
fi

while ( [ 1 ] )
do

	if ( [ "`/usr/bin/curl -m 3 --insecure -I "https://${1}:443" 2>&1 | /bin/grep \"HTTP\" | /bin/grep -w \"200\|301\"`" ] )
	then
		/bin/echo "${0} `/bin/date`: IT's ALIVE" `/bin/date` >> ${BUILD_HOME}/helperscripts/logs/MonitoringLog.dat
	else
		/bin/echo "${0} `/bin/date`: IT's DEAD" `/bin/date` >> ${BUILD_HOME}/helperscripts/logs/MonitoringLog.dat
	fi

	/bin/sleep ${periodicity}
done
