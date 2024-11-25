#!/bin/sh
#######################################################################################################################
# Author: Peter Winter
# Date  : 13/07/2023
# Description : This is a way of tailing the output logs of webservers as they are being built by the autoscaler.
# You can go onto the autoscaler and do this directly but you can also use this script to do it from the build machine
#######################################################################################################################
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

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Do you want to tail stdout or stderr?"
/bin/echo "Type '1' for stdout and '2' for stderr"
read choice

if ( [ "`/bin/echo '1 2' | /bin/grep ${choice}`" = "" ] )
then
        /bin/echo "Not a valid option, try again..."
        read choice
fi

${BUILD_HOME}/helperscripts/ExecuteOnAutoscaler.sh "/usr/bin/ls /home/X*X/logs/scaling-events* | /bin/grep webserver"
/bin/echo "############################################################################################"
/bin/echo "Please enter the full name of the webserver that you want to monitor from those listed above"
read webserver_name

if ( [ "${choice}" = "1" ] )
then
        ${BUILD_HOME}/helperscripts/ExecuteOnAutoscaler.sh "/usr/bin/tail -f /home/X*X/logs/scaling-events*/${webserver_name}/*out*"
elif ( [ "${choice}" = "2" ] )
then
        ${BUILD_HOME}/helperscripts/ExecuteOnAutoscaler.sh "/usr/bin/tail -f /home/X*X/logs/scaling-events*/${webserver_name}/*err*"
fi
