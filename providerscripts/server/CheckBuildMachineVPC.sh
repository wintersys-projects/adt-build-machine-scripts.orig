

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

cloudhost="${1}"
server_ip="${2}"

if ( [ "${cloudhost}" = "vultr" ] )
then
        server_name="`${BUILD_HOME}/providerscripts/server/GetServerName.sh ${server_ip} vultr`"
        private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${server_name} vultr`"
        vpc_id="`/usr/bin/vultr vpc2 list -o json | /usr/bin/jq -r '.vpcs[] | select (.description == "adt-vpc").id'`"
        checked_private_ip="`/usr/bin/vultr vpc2 nodes list ${vpc_id} -o json | /usr/bin/jq -r '.nodes[] | select (.description == "'${server_name}'").ip_address'`"

        if ( [ "${private_ip}" != "${checked_private_ip}" ] )
        then
                status "It looks like the build machine (${server_name}) is not attached to a VPC when BUILD_MACHINE_VPC=1"
                status "Will have to exit (change BUILD_MACHINE_VPC if necessary)"
        fi
fi
