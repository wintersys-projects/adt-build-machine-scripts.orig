



BUILD_HOME="`/bin/cat /home/buildhome.dat`"

cloudhost="${1}"
server_ip="${2}"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
        server_name="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} digitalocean`"
        ${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${server_name} digitalocean 
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
        server_name="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} exoscale`"
        ${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${server_name} exoscale 
fi

if ( [ "${cloudhost}" = "linode" ] )
then
        server_name="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} linode`"
        ${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${server_name} linode 
fi

if ( [ "${cloudhost}" = "vultr" ] )
then
        server_name="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} vultr`"
        ${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${server_name} vultr 
fi
