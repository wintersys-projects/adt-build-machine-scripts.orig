        /usr/bin/apt-get -qq -y install iptables

        /usr/bin/debconf-set-selections <<EOF
iptables-persistent iptables-persistent/autosave_v4 boolean true
iptables-persistent iptables-persistent/autosave_v6 boolean true
EOF
        /usr/bin/apt install -y -qq netfilter-persistent
