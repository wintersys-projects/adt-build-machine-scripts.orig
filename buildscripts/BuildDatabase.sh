#!/bin/sh
##############################################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description : This is the script to build the database. It will build a single database server and check
# that it seems to be running OK. These scripts look more complicated than they really are. All that is
# happening is we are copying over some files to our new database and executing a few commands (mostly to
# install software) remotely on the database.
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

#If done=1 then we know that we have build a database correctly so we don't need to run again
#If databases fail to build, we try again up to 5 times

status ""
status ""
status ""
status "#########################DATABASE#######################"

#For our remote commands, we have various options that we want to be set. To keep things as clean as possible
#We set out options for our ssh command and scp command here and pass them in through the variable ${OPTIONS}
DATABASE_PUBLIC_KEYS="${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys/database_keys"
OPTIONS="-o ConnectTimeout=10 -o ConnectionAttempts=5 -o UserKnownHostsFile=${DATABASE_PUBLIC_KEYS} -o StrictHostKeyChecking=yes "
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
status ""
status "========================================================="
status "=================BUILDING DATABASE======================="
status "========================================================="

status "Logging for this database build is located at ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/${OUT_FILE}"
status "The error stream for this database build is located at ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/${ERR_FILE}"
status "========================================================="

#If we don't need a database, then just skip the process of installing a database
#We may have an application which doesn't require a database
if ( [ "${DATABASE_INSTALLATION_TYPE}" = "None" ] )
then
        status "This deployment doesn't need a database passing...."
fi

built="0"

#If we are done then we can stop otherwise retry up to 5 times

while ( [ "${done}" != "1" ] && [ "${counter}" -lt "5" ] && [ "${DATABASE_INSTALLATION_TYPE}" != "None" ] )
do
        counter="`/usr/bin/expr ${counter} + 1`"
        status "OK... building a database server. This is attempt ${counter} of 5"

        #Make sure a database is not already running
        WEBSITE_IDENTIFIER="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`"
        if ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "db-${REGION}-${BUILD_IDENTIFIER}" ${CLOUDHOST} 2>/dev/null`" -eq "0" ] )
        then

                ip=""
                #Create an identifier from our the user name we allocated to identify the database server
                RND="`/bin/echo ${SERVER_USER} | /usr/bin/fold -w 4 | /usr/bin/head -n 1`"
                #database_name="database-${RND}-`/bin/echo ${BUILD_IDENTIFIER} | /usr/bin/tr '[:upper:]' '[:lower:]'`"
                database_name="db-${REGION}-${BUILD_IDENTIFIER}-${RND}"

              #  database_name="`/bin/echo ${database_name} | /usr/bin/cut -c -32 | /bin/sed 's/-$//g'`"

                #What type of OS are we building for. Currently, (April 2018) only ubuntu and debian are supported
             #   if ( [ "${OS_TYPE}" = "" ] )
             #   then
             #           OS_TYPE="`${BUILD_HOME}/providerscripts/cloudhost/GetOperatingSystemVersion.sh ${DB_SIZE} ${CLOUDHOST} ${BUILDOS} ${BUILDOS_VERSION}`"
             #   fi

                status "Initialising a new server machine, please wait......"

                server_started="0"
                while ( [ "${server_started}" = "0" ] )
                do
                         count="0"
                        #Actually spin up the machine we are going to build on
                      #  ${BUILD_HOME}/providerscripts/server/CreateServer.sh "'${OS_TYPE}'" "${REGION}" "${DB_SERVER_TYPE}" "${database_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${DATABASE_IMAGE_ID} ${ENABLE_DDOS_PROTECION} ${VPC_IP_RANGE}
                        ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${DB_SERVER_TYPE}" "${database_name}" ${DATABASE_IMAGE_ID}

                        #If for some reason, we failed to build the machine, then, give it another try
                        while ( [ "$?" != "0" ] && [ "${count}" -lt "10" ] )
                        do
                                count="`/usr/bin/expr ${count} + 1`"
                                /bin/sleep 10
                              #  ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${OS_TYPE}" "${REGION}" "${DB_SERVER_TYPE}" "${database_name}" "${PUBLIC_KEY_ID}" ${CLOUDHOST} ${CLOUDHOST_USERNAME} ${CLOUDHOST_PASSWORD} ${SUBNET_ID} ${DATABASE_IMAGE_ID} ${ENABLE_DDOS_PROTECION} ${VPC_IP_RANGE}
                                ${BUILD_HOME}/providerscripts/server/CreateServer.sh "${DB_SERVER_TYPE}" "${database_name}" ${DATABASE_IMAGE_ID}
                        done

                        if ( [ "${count}" = "10" ] )
                        then
                                status "Couldn't create database server"
                                exit
                        fi

                        #Check that the server has been assigned its IP addresses and that they are active
                   ip=""
                   private_ip=""
                   count="0"

                   while ( ( [ "${ip}" = "" ] || [ "${private_ip}" = "" ] ) && [ "${count}" -lt "20" ] )
                   do
                           status "Interrogating for database ip address....."
                           ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
                           private_ip="`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh "${database_name}" ${CLOUDHOST} | /bin/grep -P "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"`"
                           /bin/sleep 10
                           count="`/usr/bin/expr ${count} + 1`"
                   done
                   if ( [ "${ip}" != "" ] && [ "${private_ip}" != "" ] )
                   then
                           server_started="1"
                   else
                           status "Haven't been able to start your server, I will try again....."
                   fi
                done

           #     ${BUILD_HOME}/providerscripts/server/EnsureServerAttachedToVPC.sh "${CLOUDHOST}" "${database_name}" "${private_ip}"

                DBIP="${ip}"
                DBIP_PRIVATE="${private_ip}"

                if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
                then
                        db_active_ip="${DBIP_PRIVATE}"
                elif ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
                then
                        db_active_ip="${DBIP}"
                fi

                if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips/DBIP:* ] )
                then
                        /bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips/DBIP:*
                fi
     
                if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips/DBPRIVATEIP:* ] )
                then
                        /bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips/DBPRIVATEIP:*
                fi

                if ( [ ! -d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips ] )
                then
                        /bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips
                fi
    
                /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips/DBIP:${DBIP}
                /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/ips/DBPRIVATEIP:${DBIP_PRIVATE}

                #We create an ip mask for our server this is used when we set access privileges and so on within the database
                #and we want to allow access from machines on our private network
                IP_MASK="`/bin/echo ${DBIP_PRIVATE} | /bin/grep -oE '[0-9]{1,3}\.[0-9]{1,3}' | /usr/bin/head -1`"
                IP_MASK=${IP_MASK}".%.%"

                status "Have got the ip addresses for your database (${database_name})"
                status "Public IP address: ${DBIP}"
                status "Private IP address: ${DBIP_PRIVATE}"

                if ( [ ! -d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys ] )
                then
                        /bin/mkdir -p ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/keys
                fi

                status "Performing SSH keyscan on your new database machine (I allow up to 10 attempts). If this does fail, check BUILD_MACHINE_VPC in your template"

                if ( [ -f ${DATABASE_PUBLIC_KEYS} ] )
                then
                        /bin/cp /dev/null ${DATABASE_PUBLIC_KEYS}
                fi

                /usr/bin/ssh-keyscan -T 60 ${db_active_ip} >> ${DATABASE_PUBLIC_KEYS}

                keytry="0"
                while ( [ "`/usr/bin/diff -s /dev/null ${DATABASE_PUBLIC_KEYS} | /bin/grep identical`" != "" ] && [ "${keytry}" -lt "10" ] )
                do
                        status "Couldn't scan for database ${database_name} ssh-keys ... trying again"
                        /bin/sleep 10
                        keytry="`/usr/bin/expr ${keytry} + 1`"
                        /usr/bin/ssh-keyscan -T 60 ${db_active_ip} >> ${DATABASE_PUBLIC_KEYS}
                done 

                if ( [ "${keytry}" = "10" ] )
                then
                        status "Couldn't obtain ssh-keys, having to destroy the machine and try again"
                        ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${DBIP} ${CLOUDHOST}
                else
                        status "Successfully scanned remote database ${database_name} for ssh-keys"

                        #We don't want to pass in our private keys to our remote commands every time from the command line as it will look unwieldy.
                        #So, we previously setup unique key files with out ssh private keys in them and now that we know the ip address of our autoscaler,
                        #We can tell ourselves where to look for the private key to that ip address by configuring the config file to point to it
                        /bin/echo "Host ${db_active_ip}" >> ~/.ssh/config
                        /bin/echo "IdentityFile ~/.ssh/${SERVER_USER}.key" >> ~/.ssh/config
                        /bin/echo "IdentitiesOnly yes" >> ~/.ssh/config

                        initiation_ip="${db_active_ip}"
                        machine_type="database"

                        . ${BUILD_HOME}/buildscripts/InitiateNewMachine.sh

                        /bin/cp /dev/null ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat

                        while read param
                        do
                                param1="`eval /bin/echo ${param}`"
                                if ( [ "${param1}" != "" ] )
                                then
                                        /bin/echo ${param1} >> ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat
                                fi
                        done < ${BUILD_HOME}/builddescriptors/databasescp.dat

                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/database_configuration_settings.dat ${SERVER_USER}@${db_active_ip}:/home/${SERVER_USER}/.ssh >/dev/null 2>&1
                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/builddescriptors/buildstylesscp.dat ${SERVER_USER}@${db_active_ip}:/home/${SERVER_USER}/.ssh/buildstyles.dat >/dev/null 2>&1
                        /usr/bin/scp ${OPTIONS} ${BUILD_HOME}/providerscripts/git/GitRemoteInstall.sh ${SERVER_USER}@${db_active_ip}:/home/${SERVER_USER}/InstallGit.sh

                   gitfetchno="0"
                   while ( [ "`/usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /bin/ls /home/${SERVER_USER}/db.sh" 2>/dev/null`" = "" ] && [ "${gitfetchno}" -lt "5" ] )
                   do
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/InstallGit.sh ; cd /home/${SERVER_USER}; /usr/bin/git clone https://github.com/${INFRASTRUCTURE_REPOSITORY_OWNER}/adt-database-scripts.git; /bin/cp -r ./adt-database-scripts/* .; /bin/rm -r ./adt-database-scripts ; /bin/chown -R ${SERVER_USER}:${SERVER_USER} /home/${SERVER_USER}/*; /bin/chmod 500 /home/${SERVER_USER}/db.sh"
                           /bin/sleep 5
                           gitfetchno="`/usr/bin/expr ${gitfetchno} + 1`"
                   done

                        if ( [ "${gitfetchno}" = "5" ] )
                        then
                                status "Had trouble getting the database infrastructure sourcecode, will have to exit"
                                exit
                        fi
  
                   /bin/touch ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/CLOUDHOST:${CLOUDHOST}

                        if ( [ "${BASELINE_DB_REPOSITORY}" != "" ] )
                        then
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/providerscripts/utilities/StoreConfigValue.sh 'BASELINEDBREPOSITORY' ${BASELINE_DB_REPOSITORY}" 
                        fi

                        status "We are about to run the build script to actually build the machine into a database server"
                        status "Please Note: The process of building the database is running on a remote machine with ip address : ${DBIP}"
                        status "To access this machine once it has finished provisioning you can use the scripts in ${BUILD_HOME}/helperscripts"
                        status "Log files (stderr and stdout) are stored on the remote machine in /home/${SERVER_USER}/logs"
                        status "Starting to build the database proper"
                        status "`/bin/date`"

                        #Decide which build we are selecting to build from - virgin, hourly, daily, weekly, monthly, bimonthly
                        if ( [ "${BUILD_CHOICE}" = "0" ] )
                        then
                                #We are building a virgin installation
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'virgin' ${SERVER_USER}"
                        elif ( [ "${BUILD_CHOICE}" = "1" ] )
                        then
                                #We are building from a baseline
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'baseline' ${SERVER_USER}"
                        elif ( [ "${BUILD_CHOICE}" = "2" ] )
                        then
                                #We are building from an hourly backup
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'hourly' ${SERVER_USER}"
                        elif ( [ "${BUILD_CHOICE}" = "3" ] )
                        then
                                #We are building from an daily backup
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'daily' ${SERVER_USER}"
                        elif ( [ "${BUILD_CHOICE}" = "4" ] )
                        then
                                #We are building from an weekly backup
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'weekly' ${SERVER_USER}"
                        elif ( [ "${BUILD_CHOICE}" = "5" ] )
                        then
                                #We are building from an monthly backup
                           /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'monthly' ${SERVER_USER}"
                        elif ( [ "${BUILD_CHOICE}" = "6" ] )
                        then
                                #We are building from an bimonthly backup
                                /usr/bin/ssh ${OPTIONS} ${SERVER_USER}@${db_active_ip} "${CUSTOM_USER_SUDO} /home/${SERVER_USER}/db.sh 'bimonthly' ${SERVER_USER}"
                        fi

                        status "Finished building the database server (${database_name})"
                        status "`/bin/date`"

                        #Wait for the machine to become responsive before we check its integrity

                        /usr/bin/ping -c 10 ${db_active_ip} 2>/dev/null

                        pingcount="0"

                        while ( [ "$?" != "0" ] )
                        do
                                /usr/bin/ping -c 10 ${db_active_ip}
                                pingcount="`/usr/bin/expr ${pingcount} + 1`"
                                if ( [ "${pingcount}" = "10" ] )
                                then
                                        status "I am having trouble pinging your new database server."
                                        status "If you see this message repeatedly, maybe check that your security policy allows ping requests"
                                        status "----------------------------------------------------------------------------------------------"
                                        pingcount="0"
                                fi
                        done

                        /bin/sleep 10

                        done="0"
                        #Check that the database is built and ready for action
                        status "Checking that the database (${database_name}) has built correctly"
                        alive=""
                        count2="0"

                        alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${db_active_ip} "/bin/ls /home/${SERVER_USER}/runtime/DATABASE_READY"`"

                        count="0"
                        while ( [ "${alive}" != "/home/${SERVER_USER}/runtime/DATABASE_READY" ] && [ "${count}" -le "15" ] )
                        do
                                count="`/usr/bin/expr ${count} + 1`"
                                /bin/sleep 10
                                alive="`/usr/bin/ssh -p ${SSH_PORT} ${OPTIONS} ${SERVER_USER}@${db_active_ip} "/bin/ls /home/${SERVER_USER}/runtime/DATABASE_READY"`"
                        done 

                        if ( [ "${alive}" = "/home/${SERVER_USER}/runtime/DATABASE_READY" ] )
                        then
                                done=1
                                built="`/usr/bin/expr ${built} + 1`"
                        fi

                        #If $done != 1 then it means the DB server didn't build correctly and fully, so destroy the machine it was being built on
                        if ( [ "${done}" != "1" ] )
                        then
                                status "###########################################################################################################################"
                                status "Hi, a database server didn't seem to build correctly. I can destroy it and try again to build a new database server for you"
                                status "###########################################################################################################################"
                                status "Press the <enter> key to be continue with the next attempt <ctrl - c> to exit"

                                if ( [ "${HARDCORE}" != "1" ] )
                                then
                                        read response
                                fi

                                ${BUILD_HOME}/providerscripts/server/DestroyServer.sh ${DBIP} ${CLOUDHOST}

                                #Wait until we are sure that the database server(s) are destroyed because of a faulty build
                                while ( [ "`${BUILD_HOME}/providerscripts/server/NumberOfServers.sh "db-${REGION}-${BUILD_IDENTIFIER}" ${CLOUDHOST} 2>/dev/null`" != "${built}" ] )
                                do
                                        /bin/sleep 30
                                done

                                count1="`/usr/bin/expr ${count1} - 1`"

                        else
                                status "A database server (${database_name}) has built correctly (`/usr/bin/date`) and is accepting connections"
                                counter="`/usr/bin/expr ${counter} - 1`"
                        fi
                fi
        else
                status "A Database is already running, using that one......"
                status "Press enter if that is OK"

                if ( [ "${HARDCORE}" != "1" ] )
                then
                        read response
                fi
                done=1
        fi
done

#If we get to here then we know that the database hasn't built correctly, so report it and exit
if ( [ "${counter}" = "5" ] )
then
        status "The infrastructure failed to intialise because of a build problem, please investigate, correct and rebuild"
        exit
fi
