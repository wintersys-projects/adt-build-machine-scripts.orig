



BUILD_HOME="`/bin/cat /home/buildhome.dat`"

cloudhost="${1}"
server_ip="${2}"

if ( [ "${cloudhost}" = "vultr" ] )
then
        server_name="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} vultr`"
        ${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${server_name} vultr 
fi
