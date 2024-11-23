#!/bin/sh
####################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will perform a standard build chain (autoscaler/webserver/database)
####################################################################################
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
####################################################################################
####################################################################################
#set -x

if ( [ -f ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys ] )
then
        /bin/rm ${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys
fi

pids=""

if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" = "0" ] && [ "${BASELINE_DB_REPOSITORY}" != "VIRGIN" ] )
then
        if ( [ "${NO_AUTOSCALERS}" = "" ] )
        then
                status "How many autoscalers do you want to deploy?"

                if ( [ "${HARDCORE}" != "1" ] )
                then
                        read NO_AUTOSCALERS
                fi 

                while ! ( [ "${NO_AUTOSCALERS}" -eq "${NO_AUTOSCALERS}" ] 2> /dev/null )
                do
                        status "Sorry, invalid input, try again"
                        if ( [ "${HARDCORE}" != "1" ] )
                        then
                                read NO_AUTOSCALERS
                        fi
                done
                if ( [ "${NO_AUTOSCALERS}" -lt "1" ] )
                then
                        status "Number of autoscalers can't be less than 1 setting autoscalers to 1"
                        status "Press <enter> to accept"
                        if ( [ "${HARDCORE}" != "1" ] )
                        then
                                read x
                        fi
                        NO_AUTOSCALERS="1"
                elif ( [ "${NO_AUTOSCALERS}" -gt "5" ] )
                then
                        status "Number of autoscalers can't be greater than 5 setting autoscalers to 5"
                        status "Press <enter> to accept"
                        if ( [ "${HARDCORE}" != "1" ] )
                        then
                                read x
                        fi
                        NO_AUTOSCALERS="5"
                else 
                        status "Number of autoscalers set to ${NO_AUTOSCALERS}"
                        status "Press <enter> to accept"
                        if ( [ "${HARDCORE}" != "1" ] )
                        then
                                read x
                        fi
                fi
        fi
        if ( [ "${NO_AUTOSCALERS}" -ne "0" ] && [ "${INPARALLEL}" = "0" ] )
        then
                tally="0"
                if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}${BUILD_IDENTIFIER}/MULTI_AUTOSCALER_BUILT ] )
                then
                        /bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}${BUILD_IDENTIFIER}/MULTI_AUTOSCALER_BUILT
                fi
                while ( [ "${tally}" -lt "${NO_AUTOSCALERS}" ] && [ ! -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}${BUILD_IDENTIFIER}/MULTI_AUTOSCALER_BUILT ] )
                do
                        . ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh
                        tally="`/usr/bin/expr ${tally} + 1`"
                done
        elif ( [ "${NO_AUTOSCALERS}" -ne "0" ] && [ "${INPARALLEL}" = "1" ] )
        then
                tally="0"
                while ( [ "${NO_AUTOSCALERS}" -le "5" ] && [ "${tally}" -lt "${NO_AUTOSCALERS}" ] )
                do
                        . ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh &
                        pids="${pids} $!"
                        /bin/sleep 30
                        tally="`/usr/bin/expr ${tally} + 1`"
                done
        fi
fi 

if ( [ "${INPARALLEL}" = "0" ] )
then
        . ${BUILD_HOME}/buildscripts/BuildWebserver.sh 
        . ${BUILD_HOME}/buildscripts/BuildDatabase.sh 
elif ( [ "${NO_AUTOSCALERS}" -ne "0" ] && [ "${INPARALLEL}" = "1" ]  )
then
        . ${BUILD_HOME}/buildscripts/BuildWebserver.sh &
        pids="${pids} $!"

        /bin/sleep 30
        . ${BUILD_HOME}/buildscripts/BuildDatabase.sh &
        pids="${pids} $!"
fi

if ( [ "${NO_AUTOSCALERS}" -eq "0" ] && [ "${INPARALLEL}" = "1" ]  && [ "${DEVELOPMENT}" = "1" ] )
then
        . ${BUILD_HOME}/buildscripts/BuildWebserver.sh &
        pids="${pids} $!"
        /bin/sleep 30
        . ${BUILD_HOME}/buildscripts/BuildDatabase.sh &
        pids="${pids} $!"
fi

for pid in ${pids}
do
        wait ${pid}
done

if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
then
        AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys"
        if ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -gt "1" ] )
        then
                as_active_ips="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
        elif ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -eq "1" ] )
        then
                as_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
        fi
        ws_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "webserver" "${CLOUDHOST}"`"
        db_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "database" "${CLOUDHOST}"`"
elif ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
then
        if ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -gt "1" ] )
        then
                as_active_ips="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
        elif ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" -eq "1" ] )
        then
                as_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "autoscaler" "${CLOUDHOST}"`"
        fi
        ws_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "webserver" "${CLOUDHOST}"`"
        db_active_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "database" "${CLOUDHOST}"`"
fi

AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/keys/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_keys"
OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "

if ( [ "${as_active_ips}" != "" ] )
then
        for ip in `/bin/echo ${as_active_ips} | /bin/sed 's/:/ /g'`
        do
                /usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/webserver_configuration_settings.dat >/dev/null 2>&1        
                /usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1    
        done
elif ( [ "${as_active_ip}" != "" ] )
then
        /usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/webserver_configuration_settings.dat ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh/webserver_configuration_settings.dat >/dev/null 2>&1        
        /usr/bin/scp ${OPTIONS} -P ${SSH_PORT} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1    
fi

if ( [ "${PRODUCTION}" = "1" ] )
then
        status "Autoscaler, webserver and database built correctly....."
elif ( [ "${DEVELOPMENT}" = "1" ] )
then
        status "Webserver and database built correctly....."
fi

. ${BUILD_HOME}/providerscripts/security/firewall/TightenDBaaSFirewall.sh
/bin/touch ${BUILD_HOME}/runtimedata//PRIME_FIREWALL
cloudhost_holder="${CLOUDHOST}"
. ${BUILD_HOME}/providerscripts/security/firewall/TightenBuildMachineFirewall.sh
export CLOUDHOST="${cloudhost_holder}"

if ( [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
        . ${BUILD_HOME}/providerscripts/application/SetApplicationConfig.sh
fi
       
##Do the build finalisation procedures
. ${BUILD_HOME}/buildscripts/FinaliseBuildProcessing.sh
