#Get the ip address of our build machine
export BUILD_CLIENT_IP="`/usr/bin/wget http://ipinfo.io/ip -qO -`"

if ( [ "${BUILD_CLIENT_IP}" = "" ] )
then
	export BUILD_CLIENT_IP="`/usr/bin/curl -4 icanhazip.com`"
fi

if ( [ "${BUILD_CLIENT_IP}" = "" ] )
then
	export BUILD_CLIENT_IP="`/bin/hostname -I | /usr/bin/awk '{print $1}'`"
fi

if ( [ "${BUILD_CLIENT_IP}" = "" ] )
then
	/bin/echo "Couldn't get build client IP address after 3 separate attempts, having to exit"
	exit
else 
	/bin/echo ${BUILD_CLIENT_IP}
fi
