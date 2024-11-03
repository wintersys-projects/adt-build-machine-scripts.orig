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
/bin/echo ${BUILDMACHINE_USER}:${BUILDMACHINE_PASSWORD} | /usr/bin/sudo -S -E /usr/sbin/chpasswd 
 /usr/bin/gpasswd -a ${BUILDMACHINE_USER} sudo 
/bin/mkdir -p /home/${BUILDMACHINE_USER}/.ssh
/bin/echo "${SSH}" >> /home/${BUILDMACHINE_USER}/.ssh/authorized_keys

/bin/sed -i '$ a\ ClientAliveInterval 60\nTCPKeepAlive yes\nClientAliveCountMax 10000' /etc/ssh/sshd_config
/bin/sed -i 's/PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
/bin/sed -i 's/^#PasswordAuthentication.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
/bin/sed -i "s/^PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
/bin/sed -i "s/^#PermitRootLogin.*/PermitRootLogin no/g" /etc/ssh/sshd_config
/bin/sed -i "s/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g" /etc/ssh/sshd_config
/bin/sed -i "s/^#KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/g" /etc/ssh/sshd_config 	
/bin/sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g" /etc/ssh/sshd_config
/bin/sed -i "s/^#ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/g" /etc/ssh/sshd_config

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

firewall=""
if ( [ "`/bin/grep "^FIREWALL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "ufw" ] )
then
	firewall="ufw"
elif ( [ "`/bin/grep "^FIREWALL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "iptables" ] )
then
	firewall="iptables"
fi

if ( [ "${firewall}" = "ufw" ] )
then
	/usr/bin/apt-get -qq -y install ufw
	/bin/echo "y" | /usr/sbin/ufw reset	
	/usr/sbin/ufw default deny incoming
	/usr/sbin/ufw default allow outgoing
	#uncomment this if you want more general access than just ssh
	#/usr/sbin/ufw allow from ${LAPTOP_IP}
	/usr/sbin/ufw allow from ${LAPTOP_IP} to any port ${BUILDMACHINE_SSH_PORT}
	/bin/echo "y" | /usr/sbin/ufw enable
elif ( [ "${firewall}" = "iptables" ] )
then
        /usr/bin/apt-get -qq -y install iptables

        /usr/bin/debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
        /usr/bin/apt install -y -qq netfilter-persistent
        /usr/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        /usr/sbin/iptables -A INPUT -p tcp --dport ${BUILDMACHINE_SSH_PORT} -j ACCEPT
        /usr/sbin/iptables -A INPUT -s ${LAPTOP_IP} -p ICMP --icmp-type 8 -j ACCEPT
        /usr/sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j DROP
        /usr/sbin/iptables -I INPUT \! -s ${LAPTOP_IP} -m state --state NEW,INVALID -p tcp --dport ${BUILDMACHINE_SSH_PORT} -j DROP
        /usr/sbin/iptables -A INPUT ! -s ${LAPTOP_IP} -p icmp -m state --state INVALID,NEW -m icmp --icmp-type 8  -j DROP
        /usr/sbin/iptables -A INPUT -i lo -j ACCEPT
        /usr/sbin/iptables -A OUTPUT -o lo -j ACCEPT
        /usr/sbin/iptables -P INPUT DROP
        /usr/sbin/iptables -P FORWARD DROP
        /usr/sbin/iptables -P OUTPUT ACCEPT
        /usr/sbin/netfilter-persistent save
        /usr/sbin/netfilter-persistent reload
 fi

/bin/mkdir /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata
/bin/touch /home/${BUILDMACHINE_USER}/adt-build-machine-scripts/runtimedata/LAPTOPIP:${LAPTOP_IP}

/usr/bin/find /home/${BUILDMACHINE_USER} -type d -exec chmod 755 {} \;
/usr/bin/find /home/${BUILDMACHINE_USER} -type f -exec chmod 644 {} \;

