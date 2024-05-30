
#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will initialise a new machine with things like its SSH key
# and custom user. Its the same process to intiate a machine for all types of machine
# (autoscaler, webserver, database)
# I choose not to use cloud-init
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
####################################################################################
####################################################################################
#set -x

BUILD_KEY="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}"

loop="0"
connected="0"
sshpass="0"
while ( [ "${connected}" = "0" ] && [ "${loop}" -lt "20" ] )
do
	/usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${DEFAULT_USER}@${initiation_ip} '/bin/touch /tmp/alive.$$' 2>/dev/null
	if ( [ "$?" = "0" ] )
	then
		connected="1"
	fi
	/bin/sleep 10
	loop="`/usr/bin/expr ${loop} + 1`"
done

if ( [ "${connected}" != "1" ] )
then
	status "Sorry could not connect to the ${machine_type}. Is it possible that your CLOUDHOST_PASSWORD hasn't been set?"
	exit
fi

/usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${initiation_ip} "${SUDO} /usr/sbin/useradd ${SERVER_USER} 2>&1 >/dev/null ; /bin/echo ${SERVER_USER}:${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd ; ${SUDO} /usr/bin/gpasswd -a ${SERVER_USER} sudo"

/bin/cat ${BUILD_KEY}.pub | /usr/bin/ssh ${OPTIONS} -o "PasswordAuthentication=no" ${DEFAULT_USER}@${initiation_ip} "${SUDO} /bin/mkdir -p /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chown -R ${DEFAULT_USER}:${DEFAULT_USER} /home/${SERVER_USER}/.ssh ; /bin/cat - >> /home/${SERVER_USER}/.ssh/authorized_keys ; ${SUDO} /bin/chown -R ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}"

/usr/bin/ssh ${OPTIONS} ${DEFAULT_USER}@${initiation_ip} "${SUDO} /bin/chown -R ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chmod 700 /home/${SERVER_USER}/.ssh ; ${SUDO} /bin/chmod 600 /home/${SERVER_USER}/.ssh/authorized_keys ; ${SUDO} /bin/rm /root/.ssh/authorized_keys 2>/dev/null ; ${SUDO} /bin/chmod 700 /home/${DEFAULT_USER}/.ssh 2>/dev/null ;  ${SUDO} /bin/chmod 600 /home/${DEFAULT_USER}/.ssh/authorized_keys 2>/dev/null ; ${SUDO} /bin/sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config ; ${SUDO} /bin/sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config ; ${SUDO} /etc/init.d/ssh reload; ${SUDO} /bin/chown ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}"    

/usr/bin/scp ${OPTIONS} ${BUILD_KEY} ${SERVER_USER}@${initiation_ip}:/home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY

status "It looks like the ${machine_type} machine with ip address ${initiation_ip} is booted and accepting connections, so, let's pass it all our configuration stuff that it needs"
