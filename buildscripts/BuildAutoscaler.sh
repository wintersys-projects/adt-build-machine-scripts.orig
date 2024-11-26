#!/bin/sh
###############################################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This script builds the autoscaler. It depends on having the environment it requires set up through the
#"initialisation" scripts which you can find in the same directory. These scripts look more complicated than they really
# are. All that is happening is we are copying over some files to our new autoscaler and executing a few commands (mostly
# to install software) remotely on the autoscaler.
# The purpose of the autoscaler is to monitor the number of active and responsive webservers and if, according to
# configuration, there should be more or less than are currently active, they are shutdown or newly provisioned
# accordingly. For more information on how to configure the autoscaling, please review the documentation.
# Note, the autoscaling is not dynamic, so in a way it is scaling rather than autoscaling. Autoscaling requires that
# machine usage is monitored and additional capacity provisioned or removed accordingly. The way this works is
# you review machine usage and adjust your capacity accordingly which will then be automatically scaled out.
# If you application has huge and unpredicable swings in usage, then this mechanism might not be suitable rather,
# it is for applications that have consistent predictable usage profiles within tight bounds.
###############################################################################################################
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

done=0
counter="0"
count="0"

status ""
status ""
status ""
status "#########################AUTOSCALER#######################"

#For our remote commands, we have various options that we want to be set. To keep things as clean as possible
#We set out options for our ssh command and scp command here and pass them in through the variable ${OPTIONS}

AUTOSCALER_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/autoscaler_keys"
OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${AUTOSCALER_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "
PUBLIC_KEY_ID="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/credentials/PUBLICKEYID`"

if ( [ "${DEFAULT_USER}" = "root" ] )
then
        SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "
else
        SUDO="DEBIAN_FRONTEND=noninteractive /usr/bin/sudo -S -E "
fi

CUSTOM_USER_SUDO="DEBIAN_FRONTEND=noninteractive /bin/echo ${SERVER_USER_PASSWORD} | /usr/bin/sudo -S -E "

status ""
status ""
status ""
status "========================================================="
status "=================BUILDING AUTOSCALER====================="
status "========================================================="

status "Logging for this autoscaler build is located at ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/${OUT_FILE}"
status "The error stream for this autoscaler build is located at ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/${ERR_FILE}"
status "========================================================="

# If done=1, then we know that the autoscaler has been successfully built. We try up to 5 times before we give up if it fails
while ( [ "${done}" != "1" ] && [ "${counter}" -lt "5" ] )
do
        counter="`/usr/bin/expr ${counter} + 1`"
        autoscaler_no="`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "autoscaler" ${CLOUDHOST} 2>/dev/null`"

        if ( [ "${autoscaler_no}" = "" ] )
        then
                autoscaler_no="1"
        fi

        status ""
        status ""
        status "######################################################################################################"
        status "OK... Building autoscaler `/usr/bin/expr ${no_autoscalers} + 1`. This is the ${counter} attempt of 5"

        WEBSITE_IDENTIFIER="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`"
        WEBSITE_DISPLAY_NAME_FILE="`/bin/echo ${WEBSITE_DISPLAY_NAME} | /bin/sed 's/ /_/g'`"

        if ( [ "${autoscaler_no}" -le "${NO_AUTOSCALERS}" ] )
        then
                ip=""
                #Set a unique identifier and name for our new autoscaler server
                RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"
             #   autoscaler_name="NO-${autoscaler_no}-autoscaler-${RND}-`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
                autoscaler_name="NO-${autoscaler_no}-as-${REGION}-${BUILD_IDENTIFIER}-${RND}"

                
#                autoscaler_name="`/bin/echo ${autoscaler_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

                #See what os type we are building on. Currently only Ubuntu and debian are supported
           #     if ( [ "${OS_TYPE}" = "" ] )
           #     then
           #             OS_TYPE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${AS_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"
           #     fi

                status "Initialising a new server machine, please wait......"

                server_started="0"
                while ( [ "${server_started}" = "0" ] )
                do
                        count="0"
                        #Actually create the autoscaler machine. If the create fails, keep trying again - it must be a provider issue
                        #${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${OS_TYPE}'" "${REGION}" "${AS_SERVER_TYPE}" "${autoscaler_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${AUTOSCALER_IMAGE_ID} ${ENABLE_DDOS_PROTECION} ${VPC_IP_RANGE}
                        ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${AS_SERVER_TYPE}" "${autoscaler_name}" ${AUTOSCALER_IMAGE_ID}

                        #Somehow we failed, let's try again...
                        while ( [ "$?" != 0 ] && [ "${count}" -lt "10" ] )
                        do
                                count="`/usr/bin/expr ${count} + 1`"
                                /bin/sleep 10
                                #${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${OS_TYPE}'" "${REGION}" "${AS_SERVER_TYPE}" "${autoscaler_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${AUTOSCALER_IMAGE_ID} ${ENABLE_DDOS_PROTECION} ${VPC_IP_RANGE}
                                ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${AS_SERVER_TYPE}" "${autoscaler_name}" ${AUTOSCALER_IMAGE_ID}

                        done

                        if ( [ "${count}" -eq "10" ] )
                        then
                                 status "Couldn't autoscaler create server"
                                 exit
                        fi

                        #Get the ip addresses of the server we have just built
                        ip=""
                        private_ip=""
                        count="0"

                        while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "20" ] )
                        do
                                status "Interrogating for autoscaler ip addresses....."
                                ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
                                private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${autoscaler_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
                                /bin/sleep 10
                                count="`/usr/bin/expr ${count} + 1`"
                        done

                        if ( [ "${ip}" != "" ] && [ "${private_ip}" != "" ] )
                        then
                                server_started="1"
                        else
                                status "I haven't been able to start your server for you, trying again...."
                        fi
           done

      #     ${BUILD_HOME}/providerscripts/server/EnsureServerAttachedToVPC.sh "${CLOUDHOST}" "${autoscaler_name}" "${private_ip}"
          
                status "It looks like the machine has booted OK"
                ASIP=${ip}
                ASIP_PRIVATE=${private_ip}

                if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
                then
                        as_active_ip="${ASIP_PRIVATE}"
                elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
                then
                        as_active_ip="${ASIP}"
                fi

                ASIPS="${ASIPS}${ASIP}:"
                ASIP_PRIVATES="${ASIP_PRIVATES}${ASIP_PRIVATE}:"

                ASIPS_CLEANED="`/bin/echo ${ASIPS} | /bin/sed 's/\:/ /g'`"
                ASIPS_PRIVATES_CLEANED="`/bin/echo ${ASIP_PRIVATES} | /bin/sed 's/\:/ /g'`"

                if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
                then
                        as_active_ips="${ASIPS_PRIVATES_CLEANED}"
                elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
                then
                        as_active_ips="${ASIPS_CLEANED}"
                fi

                status "Have got the ip addresses for your autoscaler (${autoscaler_name})"
                status "Public IP address: ${ASIP}"
                status "Private IP address: ${ASIP_PRIVATE}"

                if ( [ ! -d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys ] )
                then
                        /bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys
                fi

                status "Performing SSH keyscan on your new autoscaler machine (I allow up to 10 attempts). If this does fail, check BUILD_MACHINE_VPC in your template"

                AUTOSCALER_PUBLIC_KEYS_NUMBERED="${AUTOSCALER_PUBLIC_KEYS}:${autoscaler_no}"

                if ( [ -f ${AUTOSCALER_PUBLIC_KEYS_NUMBERED} ] )
                then
                        /bin/rm ${AUTOSCALER_PUBLIC_KEYS_NUMBERED}
                fi

                /usr/bin/ssh-keyscan -T 60 ${as_active_ip} >> ${AUTOSCALER_PUBLIC_KEYS_NUMBERED}

                keytry="0"
                while ( [ "`/usr/bin/diff -s ${AUTOSCALER_PUBLIC_KEYS_NUMBERED} /dev/null | /bin/grep identical`" != "" ] && [ "${keytry}" -lt "10" ] )
                do
                        status "Couldn't scan for autoscaler ${autoscaler_name} ssh-keys ... trying again"
                        /bin/sleep 10
                        keytry="`/usr/bin/expr ${keytry} + 1`"
                        /usr/bin/ssh-keyscan -T 60 ${as_active_ip} >> ${AUTOSCALER_PUBLIC_KEYS_NUMBERED}
                done 

                if ( [ "${keytry}" = "10" ] )
                then
                        status "Couldn't obtain ssh-keys, having to destroy the machine and try again"
                        ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${ASIP} ${CLOUDHOST}
                else
                        if ( [ -f ${AUTOSCALER_PUBLIC_KEYS_NUMBERED} ] )
                        then
                                /bin/cat ${AUTOSCALER_PUBLIC_KEYS_NUMBERED} >> ${AUTOSCALER_PUBLIC_KEYS}
                                /bin/rm ${AUTOSCALER_PUBLIC_KEYS_NUMBERED}
                        fi

                        status "Successfully scanned remote autoscaler ${autoscaler_name} for ssh-keys"


                        #We know various parameters which have been set by the initialisation scripts - so we store then like this on our filesystem so that they
                        #can be passed using scp as configuration parameters to our autoscaling server

                        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/${BUILD_IDENTIFIER}

                        #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
                        #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
                        #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
                        /bin/echo "Host ${as_active_ip}" >> ~/.ssh/config
                        /bin/echo "IdentityFile ~/.ssh/${SERVER_USER}.key" >> ~/.ssh/config
                        /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

                        initiation_ip="${as_active_ip}"
                        machine_type="autoscaler"

                        . ${BUILD_HOME}/buildscripts/InitiateNewMachine.sh

                        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat

                        while read param
                        do
                                param1="`eval /bin/echo ${param}`"
                                if ( [ "${param1}" != "" ] )
                                then
                                        /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat
                                fi
                        done < ${BUILD_HOME}/builddescriptors/autoscalerscp.dat

                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/autoscaler_configuration_settings.dat ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1
                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1

                        #Add the private build key to the autoscaler. Because the autoscaler is responsible for building new webserver instances,
                        #it needs the build key so that it can bootstrap with the provider
                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER} ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}
                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/.ssh/id_${ALGORITHM}_AGILE_DEPLOYMENT_BUILD_KEY_${BUILD_IDENTIFIER}.pub

                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/providerscripts/git/GitRemoteInstall.sh ${SERVER_USER}@${as_active_ip}:/home/${SERVER_USER}/InstallGit.sh

                        gitfetchno="0"
                        while ( [ "`/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${as_active_ip} "${CUSTOM_USER_SUDO} /bin/ls /home/${SERVER_USER}/as.sh" 2>/dev/null`" = "" ] && [ "${gitfetchno}" -lt "5" ] )
                        do
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${as_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/InstallGit.sh ; cd /home/${SERVER_USER} ; /usr/bin/git clone https://github.com/${INFRASTRUCTURE_REPOSITORY_OWNER}/adt-autoscaler-scripts.git; /bin/cp -r ./adt-autoscaler-scripts/* .; /bin/rm -r ./adt-autoscaler-scripts ; /bin/chown -R ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}/*; /bin/chmod 500 /home/${SERVER_USER}/as.sh"
                                /bin/sleep 5
                                gitfetchno="`/usr/bin/expr ${gitfetchno} + 1`"
                        done

                        if ( [ "${gitfetchno}" = "5" ] )
                        then
                                status "Had trouble getting the autoscaler infrastructure sourcecode, will have to exit"
                                exit
                        fi

                        #Wicked, we have our scripts so we can build our autoscaler now

                        status "About to build the autoscaler"
                        status "Please Note: The process of building the autoscaler is running on a remote machine with ip address : ${ASIP}"
                        status "To access this machine once it has finished provisioning you can use the scripts in ${BUILD_HOME}/helperscripts"
                        status "Log files (stderr and stdout) are stored on the remote machine so if you need to review them, you will find them there"
                        status "in the directory /home/${SERVER_USER}/logs"
                        status "Starting to build the autoscaler proper"
                        status "`/bin/date`"

                        /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${as_active_ip} "${CUSTOM_USER_SUDO} /bin/sh /home/${SERVER_USER}/as.sh ${SERVER_USER}"

                        status "Finished building an autoscaler (${autoscaler_name})"
                        status "`/bin/date`"

                        #Wait for the machine to become responsive before we check its integrity

                        pingcount="0"

                        while ( [ "$?" != "0" ] )
                        do
                                /usr/bin/ping -c 10 ${as_active_ip} 2>/dev/null
                                pingcount="`/usr/bin/expr ${pingcount} + 1`"
                                if ( [ "${pingcount}" = "10" ] )
                                then
                                        status "I am having trouble pinging your new autoscaling server."
                                        status "If you see this message repeatedly, maybe check that your security policy allows ping requests"
                                        status "----------------------------------------------------------------------------------------------"
                                        pingcount="0"
                                fi
                        done

                        /bin/sleep 10

                        done="0"
                        alive=""
                        #checking that the autoscaler is "built and alive" The last thing that the as.sh script does is reboot the machine
                        #that is our autoscaler. We do some rudimentary checking to detect when it is back up again post reboot.

                        status "Checking that autoscaler ${autoscaler_name} is primed and ready"
           
                        alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${as_active_ip} "/bin/ls /home/${SERVER_USER}/runtime/AUTOSCALER_READY"`"
           
                   count="0"
                   while ( [ "${alive}" != "/home/${SERVER_USER}/runtime/AUTOSCALER_READY" ] && [ "${count}" -le "15" ] )
                   do
                           count="`/usr/bin/expr ${count} + 1`"
                           /bin/sleep 10
                           alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${as_active_ip} "/bin/ls /home/${SERVER_USER}/runtime/AUTOSCALER_READY"`"
                   done
                   
                   if ( [ "${alive}" != "/home/${SERVER_USER}/runtime/AUTOSCALER_READY" ] )
                   then
                                status "#########################################################################################################################"
                                status "Hi, an autoscaler didn't seem to build correctly. I can destroy it and I can try again to build a new autoscaler for you."
                                status "#########################################################################################################################"
                                status "Press the <enter> key to be continue with the next attempt <ctrl - c> to exit"
                                if ( [ "${HARDCORE}" != "1" ] )
                                then
                                        read response
                                fi

                                ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${ASIP} ${CLOUDHOST}

                                #Wait until we are sure that the image server(s) are destroyed because of a faulty build
                                while ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "autoscaler" ${CLOUDHOST} 2>/dev/null`" != "0" ] )
                                do
                                        /bin/sleep 30
                                done
                        else
                                done="1"
                                if ( [ "${NO_AUTOSCALERS}" -eq "1" ] )
                                then
                                        status "An autoscaler (${autoscaler_name}) has built correctly (`/usr/bin/date`)"
                                else
                                        autoscaler_built_rank="`/bin/ls  ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/AUTOSCALER_BUILT-* | /usr/bin/wc -l 2>/dev/null`"
                                        autoscaler_built_rank="`/usr/bin/expr ${autoscaler_built_rank} + 1`"
                                        /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/AUTOSCALER_BUILT-${autoscaler_built_rank}

                                        status "An autoscaler (${autoscaler_name}) has built correctly (`/usr/bin/date`) and is accepting connections"

                                        if ( [ "${autoscaler_built_rank}" -eq "${NO_AUTOSCALERS}" ] )
                                        then
                                                /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/MULTI_AUTOSCALER_BUILT 
                                                /bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/AUTOSCALER_BUILT-*
                                        fi
                                fi
                                counter="0"
                        fi
                fi
        else
                status "Autoscaler is already running. Will use that one..."
                status "Press Enter if this is OK"
                if ( [ "${HARDCORE}" != "1" ] )
                then
                        read response
                fi
                done="1"
        fi
done

#If our count got to 5, then we know that none of the attempts succeeded in building our autoscaler, so, report this and exit because we can't run without an autoscaler

if ( [ "${counter}" = "5" ] )
then
        status "The infrastructure failed to intialise because of a build problem with the autoscaler, please investigate, correct and rebuild"
        exit
fi
