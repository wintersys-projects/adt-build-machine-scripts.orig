#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : On Linode, I don't know about other providers but I have implemented this for them too, 
# if I leave an SSH connection to, for example, a webserver open overnight because I forgot or was too lazy to 
# terminate the connection after usage, then after a few hours, the CPU on the build machine ramps up to 100% 
# and I don't know why. 
# The hacky way I have dealt with this is to monitor for any ssh connections which have high CPU and 
# over a period of time and terminate them to free up the CPU. 
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


if ( [ "`/usr/bin/crontab -l | /bin/grep MonitorSSH`" = "" ] )
then
	/bin/echo "*/1 * * * * /bin/sleep 20 && ${BUILD_HOME}/helperscripts/MonitorSSH.sh" >> /var/spool/cron/crontabs/root
	/usr/bin/crontab -u root /var/spool/cron/crontabs/root
fi

process_details="`COLUMNS=9999 /usr/bin/top -bcn1 | sed 's/  *$//' | /bin/grep ssh | /bin/grep UserKnown | /usr/bin/awk '{print $1,$9}'`"

no_processes="`/usr/bin/ps -ef | /bin/grep ssh | /bin/grep UserKnown | /usr/bin/wc -l`"
process_details="`COLUMNS=9999 /usr/bin/top -bcn1 | sed 's/  *$//' | /bin/grep ssh | /usr/bin/head -1 | /bin/grep UserKnown | /usr/bin/awk '{print $1,$9}'`"

pid="`/bin/echo ${process_details} | /usr/bin/awk '{print $1}'`"
cpu="`/bin/echo ${process_details} | /usr/bin/awk '{print $2}'`"

if ( [ "${cpu}" = "" ] )
then
	exit
fi

count="0"
cpu_limit="`/usr/bin/expr 80 / ${no_processes}`"

while ( [ "`/bin/echo "${cpu} > ${cpu_limit}" | /usr/bin/bc -l`" = "1" ] && [ "${count}" -lt "5" ] )
do
	cpu="`COLUMNS=9999 /usr/bin/top -bcn1 | sed 's/  *$//' | /bin/grep ssh | /bin/grep UserKnown | /bin/grep ${pid} | /usr/bin/awk '{print $9}'`"
	count="`/usr/bin/expr ${count} + 1`"
	/bin/sleep 5
done

if ( [ "${count}" -eq "5" ] )
then
	/usr/bin/kill ${pid}
fi
