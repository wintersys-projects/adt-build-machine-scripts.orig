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
