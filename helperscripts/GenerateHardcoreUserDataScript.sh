#!/bin/sh
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : Ths will generate a "user data" script for use as part of the Hardcore build
# process. You shoud paste the script generated into the userdata of a vanilla VPS build machine
# in order to deploy your infrastructure. 
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

if ( [ ! -f ./GenerateHardcoreUserDataScript.sh ] )
then
	/bin/echo "This script is expected to run from the helperscripts directory"
	exit
fi

export BUILD_HOME="`/bin/pwd | /bin/sed 's/\/helper.*//g'`"

user="`/usr/bin/pwd | /usr/bin/awk -F'/' '{print $3}'`"
/bin/chown -R ${user} ${BUILD_HOME}/.
/bin/chmod -R 700 ${BUILD_HOME}/.

if ( [ "${1}" != "stack" ] )
then
	baseoverridescript="${BUILD_HOME}/templatedconfigurations/templateoverrides/OverrideScript.sh"
else
	baseoverridescript="${BUILD_HOME}/templatedconfigurations/templateoverrides/OverrideScriptLinode.sh"
fi

/bin/echo "Override scripts that you have generated are:"
/bin/echo "#########################################################"
/bin/ls ${BUILD_HOME}/overridescripts/*.tmpl | /usr/bin/awk -F'/' '{print $NF}'
/bin/echo "#########################################################"

/bin/echo "Please enter the exact name of one of them to use it for your user data"
read overridescript

while ( [ ! -f ${BUILD_HOME}/overridescripts/${overridescript} ] )
do
	/bin/echo "I can't seem to find that script, please enter its name again or <ctrl-c> to exit"
	read overridescript
done

/bin/echo "Please enter a discriptive name for your userdata script"
read userdatascript

configurationsettings="${BUILD_HOME}/overridescripts/${overridescript}"
configurationsettings_stack="${BUILD_HOME}/overridescripts/${overridescript}.stack"

if ( [ -f ${configurationsettings_stack} ] )
then
	/bin/sed -i '/^export/d' ${configurationsettings_stack}
fi

if ( [ ! -d ${BUILD_HOME}/userdatascripts ] )
then
	/bin/mkdir ${BUILD_HOME}/userdatascripts
fi

/bin/cp ${baseoverridescript} ${BUILD_HOME}/userdatascripts/${userdatascript}
/bin/sed 's/\"/\\"/g' ${configurationsettings} > ${configurationsettings}.live
if ( [ "${1}" != "stack" ] )
then
	/bin/sed -i 's/#XXXECHOZZZ/\/bin\/echo \"/g' ${BUILD_HOME}/userdatascripts/${userdatascript}
	/bin/sed -e '/#XXXYYYZZZ/ {' -e "r ${configurationsettings}.live" -e 'd' -e '}' -i ${BUILD_HOME}/userdatascripts/${userdatascript}
	/bin/sed -i 's/#XXXROOTENVZZZ/  \" \>\> \/root\/Environment.env/g' ${BUILD_HOME}/userdatascripts/${userdatascript}
	/bin/sed -e '/#XXXYYYZZZ/ {' -e "r ${configurationsettings}.live" -e 'd' -e '}' -i ${BUILD_HOME}/userdatascripts/${userdatascript}
else
	if ( [ -f ${configurationsettings_stack} ] )
	then
		/bin/sed -e '/#XXXSTACKYYY/ {' -e "r ${configurationsettings_stack}" -e 'd' -e '}' -i ${BUILD_HOME}/userdatascripts/${userdatascript}
		/bin/sed -i "s/^export/#export/g" ${BUILD_HOME}/userdatascripts/${userdatascript}
	fi
fi

/bin/echo "cd adt-build-machine-scripts

/bin/sh HardcoreADTWrapper.sh" >> ${BUILD_HOME}/userdatascripts/${userdatascript}

if ( [ "${1}" != "stack" ] )
then
	/bin/echo "Your generated build script is at: ${BUILD_HOME}/userdatascripts/${userdatascript}"
else
	/bin/echo "Your generated linode specific stack script is at: ${BUILD_HOME}/userdatascripts/${userdatascript}"
fi
