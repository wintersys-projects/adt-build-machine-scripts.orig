#!/bin/sh
###################################################################################
# Description : This generates an override template from the environment passed in
# from the user data script of the build machine VPS
# Author: Peter Winter
# Date  : 13/07/2020
###################################################################################
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

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
	while read line
	do
		variables="${variables} `/bin/echo ${line} | /bin/grep "^export" | /usr/bin/awk -F'=' '{print $1}' | /usr/bin/awk '{print $NF}' | /bin/sed '/^$/d'`"
	done < /root/Environment.env

	for variable in ${variables}
	do
		/bin/sed -i "/${variable}=/d" ${templatefile}
		eval "payload=\${$variable}"
		/bin/echo "export ${variable}=\"${payload}\"" >> ${templatefile}
	done
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
	while read line
	do
		variables="${variables} `/bin/echo ${line} | /bin/grep "^export" | /usr/bin/awk -F'=' '{print $1}' | /usr/bin/awk '{print $NF}' | /bin/sed '/^$/d'`"
	done < /root/Environment.env

	for variable in ${variables}
	do
		/bin/sed -i "/${variable}=/d" ${templatefile}
		eval "payload=\${$variable}"
		/bin/echo "export ${variable}=\"${payload}\"" >> ${templatefile}
	done
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
	while read line
	do
		variables="${variables} `/bin/echo ${line} | /bin/grep "UDF" | /usr/bin/awk -F'"' '{print $2}' | /bin/sed '/^$/d'`"
	done < /root/StackScript

	for variable in ${variables}
	do
		/bin/sed -i "/${variable}=/d" ${templatefile}
		eval "payload=\${$variable}"
		/bin/echo "export ${variable}=\"${payload}\"" >> ${templatefile}
	done
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
	while read line
	do
		variables="${variables} `/bin/echo ${line} | /bin/grep "^export" | /usr/bin/awk -F'=' '{print $1}' | /usr/bin/awk '{print $NF}' | /bin/sed '/^$/d'`"
	done < /root/Environment.env

	for variable in ${variables}
	do
		/bin/sed -i "/${variable}=/d" ${templatefile}
		eval "payload=\${$variable}"
		/bin/echo "export ${variable}=\"${payload}\"" >> ${templatefile}
	done
fi


