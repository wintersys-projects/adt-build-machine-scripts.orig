#!/bin/sh
#################################################################################################
#THIS SCRIPT IS FOR USE ON A DEBIAN OR UBUNTU LINODE SERVER WITH THE LINODE CLOUDHOST EXCLUSIVELY
#IF YOU WISH TO SUPPORT A DIFFERENT FLAVOUR OF LINUX YOU WILL NEED SEPARATE SCRIPTS
#SUITABLE FOR THAT PARTICULAR FLAVOUR
################################################################################################
###############################################################################################
# SET THESE FOR YOUR BUILD CLIENT MACHINE
# THIS WILL NOT START A BUILD IT WILL JUST SETUP THE TOOLKIT
# USE THIS IF YOU WANT TO PERFORM AN EXPEDITED OR A FULL BUILD FROM THE COMMAND LINE
# ssh -i <ssh-private-key> -p ${BUILDCLIENT_SSH_PORT} $BUILDCLIENT_USER@<buildclientip>
# $BUILDCLIENT_USER>sudo su
# password:${BUILDCLIENT_PASSWORD}
# cd adt-build-machine-scripts/logs
#################################################################################################
# <UDF name="SSH" label="SSH Public Key from your laptop" />
# <UDF name="BUILDMACHINE_USER" label="The username for your build machine" />
# <UDF name="BUILDMACHINE_PASSWORD" label="The password for your build machine user" />
# <UDF name="BUILDMACHINE_SSH_PORT" label="The SSH port for your build machine" />
# <UDF name="LAPTOP_IP" label="IP address of your laptop" />
##################################################################################################

#XXXSTACKYYY

/usr/sbin/adduser --disabled-password --gecos \"\" ${BUILDMACHINE_USER} 
/bin/sed -i '$ a\ ClientAliveInterval 60\nTCPKeepAlive yes\nClientAliveCountMax 10000' /etc/ssh/sshd_config
/bin/sed -i 's/.*PermitRootLogin.*$/PermitRootLogin no/g' /etc/ssh/sshd_config
/bin/echo ${BUILDMACHINE_USER}:${BUILDMACHINE_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd 
 /usr/bin/gpasswd -a ${BUILDMACHINE_USER} sudo 
/bin/mkdir -p /home/${BUILDMACHINE_USER}/.ssh
/bin/echo "${SSH}" >> /home/${BUILDMACHINE_USER}/.ssh/authorized_keys
/bin/sed -i 's/#*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config
if ( [ "${BUILDMACHINE_SSH_PORT}" = "" ] )
then
	BUILDMACHINE_SSH_PORT="22"
fi
/bin/sed -i "s/^Port.*$/Port ${BUILDMACHINE_SSH_PORT}/g" /etc/ssh/sshd_config
/bin/sed -i "s/^#Port.*$/Port ${BUILDMACHINE_SSH_PORT}/g" /etc/ssh/sshd_config
/usr/bin/systemctl daemon-reload
systemctl restart sshd
service ssh restart
/usr/bin/apt-get -qq -y update
/usr/bin/apt-get -qq -y install git
/usr/bin/apt-get -qq -y install ufw
/usr/sbin/ufw enable
/usr/sbin/ufw default deny incoming
/usr/sbin/ufw default allow outgoing
/usr/sbin/ufw allow from ${LAPTOP_IP}
################################################################################################################################################
#It is possible to lock down ssh connections to only from a specific ip address which is more secure, but, if the IP address of your machine changes,
#for example, if you connect your laptop to a different network, then, you will have to connect to the build client machine through the console of
#your VPS system provider and allow your new IP address through the firewall. This might be more of a hassle than its worth
#################################################################################################################################################
/usr/sbin/ufw allow ${BUILDMACHINE_SSH_PORT}/tcp 
#/usr/sbin/ufw allow from ${LAPTOP_IP} to any port ${BUILDMACHINE_SSH_PORT}
cd /home/${BUILDMACHINE_USER}
if ( [ "${INFRASTRUCTURE_REPOSITORY_OWNER}" != "" ] )
then
	/usr/bin/git clone https://github.com/${INFRASTRUCTURE_REPOSITORY_OWNER}/adt-build-machine-scripts.git
else
	/usr/bin/git clone https://github.com/wintersys-projects/adt-build-machine-scripts.git
fi

/bin/mkdir -p /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/logs

OUT_FILE="buildmachine-out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>/home/${BUILDMACHINE_USER}/adt-build-machine-scripts/logs/${OUT_FILE}
ERR_FILE="buildmachine-err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>/home/${BUILDMACHINE_USER}/adt-build-machine-scripts/logs/${ERR_FILE}

export BUILD_HOME="/home/${BUILDMACHINE_USER}/adt-build-machine-scripts"

/bin/mkdir /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata
/bin/touch /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata/LAPTOPIP:${LAPTOP_IP}

/usr/bin/find /home/${BUILDMACHINE_USER} -type d -exec chmod 755 {} \;
/usr/bin/find /home/${BUILDMACHINE_USER} -type f -exec chmod 644 {} \;

