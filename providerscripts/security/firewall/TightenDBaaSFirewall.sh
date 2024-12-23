#!/bin/sh
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2016
# Description: If you are deploying a DBaaS system, this will tighten the firewalling system
# so that the databases are only accessible by ip addresses that we are using. 
# This is applied towards the end of the build process
########################################################################################
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
#########################################################################################
#########################################################################################
#set -x

if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
	:
   #Because the DBaaS setup is in the same VPC as your machines we don't need to tighten its firewall because its only accessible from within the VPC
#   if ( [ "${ASIP}" != "" ] )
#   then
#       status "Tightening the firewall on your database cluster for your autoscaler"    
#       /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${ASIP}  
#   fi
#   status "Tightening the firewall on your database cluster for your webserver"    
#   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${WSIP}  
#   status "Tightening the firewall on your database cluster for your database"    
#   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${DBIP}  
#    status "Tightening the firewall on your database cluster for your build client"    
#   /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${BUILD_CLIENT_IP}  
   
fi


if ( [ "${CLOUDHOST}" = "exoscale" ] && [ "${DATABASE_INSTALLATION_TYPE}"="DBaaS" ] )
then
	webserver_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh  'ws-' ${CLOUDHOST}`"
 	database_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh  'db-' ${CLOUDHOST}`"
	#The DBaaS solution from exoscale is not accessible from the private network ip address range so we have to allow the public IP addresses individually
 
   	ips="${webserver_ip},${database_ip}"
    	database_type="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $1}'`"

        if ( [ "${database_type}" = "Postgres" ] )
	then
		status "Tightening the firewall on your postgres database for your webserver with following IPs: ${ips}"    
		/usr/bin/exo dbaas update --zone ${DATABASE_REGION} ${DBaaS_DBNAME} --pg-ip-filter=${ips}
	elif ( [ "${database_type}" = "MySQL" ] )
	then
		status "Tightening the firewall on your mysql database for your webserver with following IPs: ${ips}"    
		/usr/bin/exo dbaas update --zone ${DATABASE_REGION} ${DBaaS_DBNAME} --mysql-ip-filter=${ips}
	fi
 fi

if ( [ "${CLOUDHOST}" = "linode" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
	webserver_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh  'ws-' ${CLOUDHOST}`"
 	database_ip="`${BUILD_HOME}/providerscripts/server/GetServerIPAddresses.sh  'db-' ${CLOUDHOST}`"
  	#The DBaaS solution from linode is not accessible from the vpc ip address range so we have to allow the public IP addresses individually

        allow_list=" --allow_list ${webserver_ip}/32 --allow_list ${database_ip}/32"
        database_type="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $1}'`"

        if ( [ "${database_type}" = "MySQL" ] )
        then
                database_id="`/usr/local/bin/linode-cli --json databases mysql-list | /usr/bin/jq '.[] | select(.label | contains ("'${CLUSTER_NAME}'")) | .id'`"
                /usr/local/bin/linode-cli databases mysql-update ${database_id} ${allow_list}
        elif ( [ "${database_type}" = "Postgres" ] )
        then
                database_id="`/usr/local/bin/linode-cli --json databases postgresql-list | /usr/bin/jq '.[] | select(.label | contains ("'${CLUSTER_NAME}'")) | .id'`"
                /usr/local/bin/linode-cli databases mysql-update ${database_id} ${allow_list}
        fi
fi

#The vultr managed database should be in the same VPC as the webserver machines which means that the managed database can only be accessed from within that VPC
#This means that you have no need to have trusted IP addresses on an IP address by IP address basis for vultr. I have left the code below commented out in case
#You do want to have specific IP addresses as trusted IPs but as long as your managed database is in the same VPC as your main machines then you shouldn't need this

if ( [ "${CLOUDHOST}" = "vultr" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
:
  # export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"

  # if ( [ "${ASIP}" != "" ] )
  # then
  #     ips="\"${ASIP}\",\"${WSIP}\",\"${DBIP}\",\"${ASIP_PRIVATE}\",\"${WSIP_PRIVATE}\",\"${DBIP_PRIVATE}\",\"${BUILD_CLIENT_IP}\""
  # else
  #     ips="\"${WSIP}\",\"${DBIP}\",\"${WSIP_PRIVATE}\",\"${BUILD_CLIENT_IP}\""
  # fi

  # label="`/bin/echo ${DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $7}'`"

  # if ( [ "${label}" = "" ] )
  # then
  #     label="`/bin/echo ${DBaaS_DBNAME}`"
  # fi
   
  # databaseids="`/usr/bin/vultr database list | /bin/egrep "^ID" | /usr/bin/awk '{print $NF}'`"
   
  # while ( [ "${databaseids}" = "" ] )
  # do
  #     status "Attempting to obtain managed database id...."
  #     databaseids="`/usr/bin/vultr database list | /bin/egrep "^ID" | /usr/bin/awk '{print $NF}'`"
  #     /bin/sleep 30
  # done

  # for databaseid in ${databaseids}
  # do
  #      if ( [ "`/usr/bin/vultr database get ${databaseid} | /bin/grep "${DBaaS_HOSTNAME}"`" != "" ] )
  #      then
  #           selected_databaseid="${databaseid}"
  #      fi
  # done
   
  # if ( [ "${selected_databaseid}" = "" ] )
  # then
  #      status "Could not establish the correct database id for your DBaaS Firewall insitialisation"
  #      status "Press <enter> to acknowledge"
  #      read x
  # else
  #      status "Tightening the firewall on your mysql or postgres database for your webserver with following IPs: ${ips}"  
  #      /usr/bin/vultr database update ${selected_databaseid} --trusted-ips="${ips}"
  # fi  
fi



