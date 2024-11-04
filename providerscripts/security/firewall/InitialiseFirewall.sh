#!/bin/sh
######################################################################################################
# Description: Initialise the firewall for the build machine
#
# Author: Peter Winter
# Date: 17/01/2021
#######################################################################################################
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

if ( [ -f /root/FIREWALL-INITIALISED ] )
then
	exit
 fi

BUILD_HOME="`/usr/bin/pwd`"

firewall=""
if ( [ "`/bin/grep "^FIREWALL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "ufw" ] )
then
	firewall="ufw"
elif ( [ "`/bin/grep "^FIREWALL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "iptables" ] )
then
	firewall="iptables"
fi

laptop_ip="`/bin/ls ${BUILD_HOME}/runtimedata/LAPTOPIP:* | /usr/bin/awk -F':' '{print $NF}'`"
buildmachine_ssh_port="`/bin/ls ${BUILD_HOME}/runtimedata/BUILDMACHINEPORT:* | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ "${firewall}" = "ufw" ] )
then
	#/usr/bin/apt-get -qq -y install ufw
	/bin/echo "y" | /usr/sbin/ufw reset	
	/usr/sbin/ufw default deny incoming
	/usr/sbin/ufw default allow outgoing
	#uncomment this if you want more general access than just ssh
	#/usr/sbin/ufw allow from ${LAPTOP_IP}
	/usr/sbin/ufw allow from ${laptop_ip} to any port ${buildmachine_ssh_port}
	/bin/echo "y" | /usr/sbin/ufw enable
 	/bin/touch /root/FIREWALL-INITIALISED
elif ( [ "${firewall}" = "iptables" ] )
then
       # /usr/bin/apt-get -qq -y install iptables

      #  /usr/bin/debconf-set-selections <<EOF
#iptables-persistent iptables-persistent/autosave_v4 boolean true
#iptables-persistent iptables-persistent/autosave_v6 boolean true
#EOF
 #       /usr/bin/apt install -y -qq netfilter-persistent
        /usr/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
        /usr/sbin/iptables -A INPUT -p tcp --dport ${buildmachine_ssh_port} -j ACCEPT
        /usr/sbin/iptables -A INPUT -s ${laptop_ip} -p ICMP --icmp-type 8 -j ACCEPT
        /usr/sbin/iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j DROP
        /usr/sbin/iptables -I INPUT \! -s ${laptop_ip} -m state --state NEW,INVALID -p tcp --dport ${buildmachine_ssh_port} -j DROP
        /usr/sbin/iptables -A INPUT ! -s ${laptop_ip} -p icmp -m state --state INVALID,NEW -m icmp --icmp-type 8  -j DROP
        /usr/sbin/iptables -A INPUT -i lo -j ACCEPT
        /usr/sbin/iptables -A OUTPUT -o lo -j ACCEPT
        /usr/sbin/iptables -P INPUT DROP
        /usr/sbin/iptables -P FORWARD DROP
        /usr/sbin/iptables -P OUTPUT ACCEPT
  	/usr/sbin/ip6tables -P INPUT DROP
	/usr/sbin/ip6tables -P FORWARD DROP
	/usr/sbin/ip6tables -P OUTPUT DROP
	/usr/sbin/service netfilter-persistent save
 
       # /usr/sbin/netfilter-persistent save
       # /usr/sbin/netfilter-persistent reload
	 /bin/touch /root/FIREWALL-INITIALISED
 fi
