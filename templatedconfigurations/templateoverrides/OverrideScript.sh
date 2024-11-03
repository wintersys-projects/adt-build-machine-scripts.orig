#!/bin/sh

#####################################################################################
#THIS SCRIPT IS FOR USE ON A DEBIAN OR UBUNTU VPS SERVER WITH YOUR CHOSEN CLOUDHOST
#IF YOU WISH TO SUPPORT A DIFFERENT FLAVOUR OF LINUX YOU WILL NEED SEPARATE SCRIPTS
#SUITABLE FOR THAT PARTICULAR FLAVOUR
######################################################################################

###############################################################################################
# SET THESE FOR YOUR BUILD CLIENT MACHINE
# THIS WILL NOT START A BUILD IT WILL JUST SETUP THE TOOLKIT
# USE THIS IF YOU WANT TO PERFORM AN EXPEDITED OR A FULL BUILD FROM THE COMMAND LINE
# ssh -i <ssh-private-key> -p ${BUILDCLIENT_SSH_PORT} $BUILDCLIENT_USER@<buildclientip>
# $BUILDCLIENT_USER>sudo su
# password:${BUILDCLIENT_PASSWORD}
# cd adt-build-machine-scripts/logs
#################################################################################################
export BUILDMACHINE_USER="agile-user"
export BUILDMACHINE_PASSWORD="Hjdhfb34hd£" #Make sure any password you choose is strong enough to pass any strength enforcement rules of your OS (vultr is really strict and a weak password will be a problem) also, do not use the dollar symbol in your password
export BUILDMACHINE_SSH_PORT="1035"
export LAPTOP_IP=""

/bin/echo "
#BASE OVERRIDES
export SSH=\"\" #paste your public key here
export SELECTED_TEMPLATE=\"\" #set if using hardcore build
#################################################################
#MODIFY THESE VALUES IF YOU ARE DEPLOYING FROM A FORKED REPOSITORY
#################################################################
#export INFRASTRUCTURE_REPOSITORY_PROVIDER=\"github\"
#export INFRASTRUCTURE_REPOSITORY_OWNER=\"adt-demos\"
#export INFRASTRUCTURE_REPOSITORY_USERNAME=\"adt-demos\"
#export INFRASTRUCTURE_REPOSITORY_PASSWORD=\"none\"
####################################################################################
" > /root/Environment.env

#XXXECHOZZZ
#XXXYYYZZZ
#XXXROOTENVZZZ

. /root/Environment.env

#XXXSTACKYYY

/usr/sbin/adduser --disabled-password --gecos \"\" ${BUILDMACHINE_USER} 
/bin/sed -i '$ a\ ClientAliveInterval 60\nTCPKeepAlive yes\nClientAliveCountMax 10000' /etc/ssh/sshd_config
/bin/echo ${BUILDMACHINE_USER}:${BUILDMACHINE_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd 
 /usr/bin/gpasswd -a ${BUILDMACHINE_USER} sudo 

/bin/mkdir -p /home/${BUILDMACHINE_USER}/.ssh
/bin/echo "${SSH}" >> /home/${BUILDMACHINE_USER}/.ssh/authorized_keys

if ( [ -f /etc/systemd/system/ssh.service.d/00-socket.conf ] )
then
	/bin/rm /etc/systemd/system/ssh.service.d/00-socket.conf
	/bin/systemctl daemon-restart
fi

/bin/systemctl disable --now ssh.socket
/bin/systemctl enable --now ssh.service

/bin/sed -i 's/#*PasswordAuthentication [a-zA-Z]*/PasswordAuthentication no/' /etc/ssh/sshd_config

for file in `/bin/ls /etc/ssh/sshd_config.d`
do
	fullfile="/etc/ssh/sshd_config.d/${file}"
	/bin/sed -i 's/PasswordAuthentication.*$/PasswordAuthentication no/' ${fullfile}
 	/bin/sed -i 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' ${fullfile}
 	/bin/sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" ${fullfile}
	/bin/sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" ${fullfile}
 	/bin/sed -i "s/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g" ${fullfile}
	/bin/sed -i "s/^#KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g" ${fullfile} 	
 	/bin/sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g" ${fullfile}
	/bin/sed -i "s/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g" ${fullfile}
done

if ( [ "${BUILDMACHINE_SSH_PORT}" = "" ] )
then
	BUILDMACHINE_SSH_PORT="22"
fi

/bin/sed -i "s/^Port.*$/Port ${BUILDMACHINE_SSH_PORT}/g" /etc/ssh/sshd_config
/bin/sed -i "s/^#Port.*$/Port ${BUILDMACHINE_SSH_PORT}/g" /etc/ssh/sshd_config

/usr/bin/systemctl daemon-reload
/bin/systemctl restart sshd
/usr/sbin/service ssh restart

/usr/bin/apt-get -qq -y update
/usr/bin/apt-get -qq -y install git

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
#. ${BUILD_HOME}/providerscripts/security/firewall/InitialiseFirewall.sh
 
if ( [ ! /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata ] )
then
	/bin/mkdir -p /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata
fi
/bin/touch /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata/LAPTOPIP:${LAPTOP_IP}
/bin/touch /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata/BUILDMACHINEPORT:${BUILDMACHINE_SSH_PORT}

/usr/bin/find /home/${BUILDMACHINE_USER} -type d -exec chmod 755 {} \;
/usr/bin/find /home/${BUILDMACHINE_USER} -type f -exec chmod 644 {} \;
