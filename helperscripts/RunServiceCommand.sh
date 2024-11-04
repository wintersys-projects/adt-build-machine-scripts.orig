#!/bin/sh

service_type="${1}"
service_function="${2}"

buildos="`/bin/grep ID /etc/*-release | /bin/grep debian | /usr/bin/awk -F'=' '{print $NF}'`"

if ( [ "${buildos}" = "ubuntu" ] )
then
    /usr/sbin/service ${service_type} ${service_function}
fi

if ( [ "${buildos}" = "debian" ] )
then
    /usr/sbin/service ${service_type} ${service_function}
fi
