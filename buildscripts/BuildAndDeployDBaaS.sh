#!/bin/sh
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2021
# Description : This is a script which enables you to shortcut the deployment of DBaaS systems
# when using the hardcore or expedited build. You do it by setting the DATABASE_DBaaS_INSTALLATION_TYPE
# variable in the way described for each provider. When set as described for your provider,
# when you make the deployment this script will try and spin up a DBaaS system and use that. 
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

#############################################################################################################
# You might want to manually configure a remote database using a gui system.
# If you want to do that you will need to setup the database manually and then set the 
# DATABASE_DBaaS_INSTALLATION_TYPE field according to the following nomenclature in your template
# DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:MANUAL:<hostname>:<username>:<password>:<dbname>"
# DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:MANUAL:<hostname>:<username>:<password>:<dbname>"
# Obviously the type of database you have manually provisioned using a GUI system will have to match with what
# you have set in your template in other words, one of MySQl or Postgres
#############################################################################################################

if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS | /bin/grep MANUAL`" != "" ] )
then
	database_details="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/sed 's/^.*DBAAS:MANUAL//g'`"
	DBaaS_HOSTNAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $1}'`"
	DBaaS_USERNAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $2}'`"
	DBaaS_PASSWORD="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $3}'`"
	DBaaS_DBNAME="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $4}'`"
else
	#########################################################################################################
	#If you are deploying to digitalocean provide a setting with the following format in your template
	#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:lon1:1:db-s-1vcpu-1gb:8:testdbcluster1:testdb1:e265abcb-1295-1d8b-af36-0129f89456c2:example-username"
	#DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:pg:lon1:1:db-s-1vcpu-1gb:8:testdbcluster1:testdb1:e265abcb-1295-1d8b-af36-0129f89456c2:example-username"
	#########################################################################################################


	if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
	then
		if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
		then
			database_details="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/sed 's/^.*DBAAS://g'`"
			cluster_engine="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $1}'`"
			cluster_region="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $2}'`"
			cluster_nodes="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $3}'`"
			cluster_size="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $4}'`"
			cluster_version="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $5}'`"
			cluster_name="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $6}'`"
			database_name="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $7}'`"
			adt_vpc="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $8}'`"
   			database_user="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $9}'`"

	
			status "Configuring database cluster ${cluster_name}, please wait..."

			cluster_id="`/usr/local/bin/doctl databases list -o json | /usr/bin/jq -r '.[] | select (.name == "'${cluster_name}'").id'`"
	
			if ( [ "${cluster_id}" = "" ] )
			then
				status "Creating the database cluster ${cluster_name}"
		
				/usr/local/bin/doctl databases create ${cluster_name} --engine ${cluster_engine} --region ${cluster_region}  --num-nodes ${cluster_nodes} --size ${cluster_size} --version ${cluster_version} --private-network-uuid ${adt_vpc} 
				if ( [ "$?" != "0" ] )
				then
					status "I had trouble creating the database cluster will have to exit....."
					exit
				fi
			fi

			while ( [ "${cluster_id}" = "" ] )
			do
				status "Trying to obtain cluster id for the ${cluster_name} cluster..."
				cluster_id="`/usr/local/bin/doctl databases list -o json | /usr/bin/jq -r '.[] | select (.name == "'${cluster_name}'").id'`"
				/bin/sleep 30
			done
	
			status "Tightening the firewall on your database cluster"
	
			#uuids="`/usr/local/bin/doctl databases firewalls list ${cluster_id} | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"
   			uuids="`/usr/local/bin/doctl databases firewalls list ${cluster_id} -o json | /usr/bin/jq -r '.[] | select (.cluster_uuid == "'${cluster_id}'").uuid'`"

			if ( [ "${uuids}" != "" ] )
   			then
				for uuid in ${uuids}  
				do
					/usr/local/bin/doctl databases firewalls remove ${cluster_id} --uuid ${uuid}
				done
    			fi
	   
			status "Creating a database named ${database_name} in cluster: ${cluster_id}"
	
			/usr/local/bin/doctl databases db create ${cluster_id} ${database_name}

			while ( [ "`/usr/local/bin/doctl databases db list ${cluster_id} -o json | /usr/bin/jq -r '.[] | select (.name == "'${database_name}'").name'`" = "" ] )
			do
				status "Probing for a database called ${database_name} in the cluster called ${cluster_name} - Please Wait...."
				status "Note: you can get a %age progress update by referring to the Digital Ocean GUI for your database cluster as it provisions"
				/bin/sleep 30
				/usr/local/bin/doctl databases db create ${cluster_id} ${database_name}
			done

			database_password=""
   
   			if ( [ "`/usr/local/bin/doctl database user list ${cluster_id} -o json | /usr/bin/jq -r '.[] | select (.name == "'${database_user}'").name'`" = "" ] )
   			then
				database_password="`/usr/local/bin/doctl databases user create  ${cluster_id} ${database_user} -o json | /usr/bin/jq -r '.[].password'`"
			else 
				database_password="`/usr/local/bin/doctl database user list ${cluster_id} -o json | /usr/bin/jq -r '.[] | select (.name == "'${database_user}'").password'`"
    			fi
       
			status "######################################################################################################################################################"
			status "You might want to check that a database cluster called ${cluster_name} with a database ${database_name} is present using your Digital Ocean gui system"
			status "######################################################################################################################################################"
			status "Press <enter> when you are satisfied"
		
  			if ( [ "${HARDCORE}" != "1" ] )
			then
				read x
			fi

                        if ( [ "`/usr/local/bin/doctl database firewalls list ${cluster_id} -o json | /usr/bin/jq -r '.[] | select (.value == "'${VPC_IP_RANGE}'").id'`" = "" ] )
                        then
                                /usr/local/bin/doctl databases firewalls append ${cluster_id} --rule ip_addr:${VPC_IP_RANGE}
                        fi
			
			if ( [ "${cluster_engine}" = "mysql" ] )
			then
				export DATABASE_DBaaS_INSTALLATION_TYPE="MySQL"
			elif ( [ "${cluster_engine}" = "postgres" ] )
			then
				export DATABASE_DBaaS_INSTALLATION_TYPE="Postgres"
			fi
	
			export DATABASE_INSTALLATION_TYPE="DBaaS"
			export DATABASE_DBaaS_INSTALLATION_TYPE="${DATABASE_DBaaS_INSTALLATION_TYPE}:${cluster_id}"
			export DBaaS_HOSTNAME="private-`/usr/local/bin/doctl databases connection ${cluster_id} | /usr/bin/awk '{print $3}' | /usr/bin/tail -1`"
			export DBaaS_USERNAME="${database_user}"
			export DBaaS_PASSWORD="${database_password}"
			export DBaaS_DBNAME="${database_name}"
			export DB_PORT="${DB_PORT}"
	
			status "The Values I have retrieved for your database setup are:"
			status "##########################################################"
			status "HOSTNAME:${DBaaS_HOSTNAME}"
			status "USERNAME:${DBaaS_USERNAME}"
			status "PASSWORD:${DBaaS_PASSWORD}"
  			status "DATABASENAME:${DBaaS_DBNAME}"
			status "PORT:${DB_PORT}"
			status "##########################################################"
			status "If these settings look OK to you, press <enter>"
		
  			if ( [ "${HARDCORE}" != "1" ] )
			then
				read x
			fi
		fi
	fi


	#########################################################################################################
	#If you are deploying to exoscale provide a setting with the following format in your template
	#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:ch-gva-2:hobbyist-2:testdb1"
	#DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:pg:ch-gva-2:hobbyist-2:testdb1"
	#If you need to you can turn off termination protection as in the following example:
	#exo dbaas update testdb1 -z ch-gva-2 --termination-protection=false
	#########################################################################################################
	if ( [ "${CLOUDHOST}" = "exoscale" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
	then
		if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
		then
			database_details="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/sed 's/^.*DBAAS://g'`"
			database_engine="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $1}'`"
			database_region="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $2}'`"
			database_size="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $3}'`"
			database_name="`/bin/echo ${database_details} | /usr/bin/awk -F':' '{print $4}'`"
	
			existing_database_name="`/usr/bin/exo dbaas list -O json | /usr/bin/jq -r '.[] | select (.name == "'${database_name}'").name'`"
   
			new=""
			if ( [ "${existing_database_name}" = "" ] )
			then
   				if ( [ "${BYPASS_DB_LAYER}" = "1" ] )
       				then
	   				status "You can't have the BYPASS_DB_LAYER set to on for a newly provisioned database"
					status "Do want me to set BYPASS_DB_LAYER to off so that the build will continue (Y|y) otherwise I will have to exit"
     					read response
	  				if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
       					then
	    					BYPASS_DB_LAYER="0"
	  				else
       						exit
	     				fi
	  			fi
      				status "Creating  database ${database_name}, with engine: ${database_engine}, in region: ${database_region} and at size: ${database_size} please wait..."
                                /usr/bin/exo dbaas create ${database_engine} ${database_size} ${database_name}  --zone ${database_region}
				
    				if ( [ "$?" = "0" ] )
    				then
					new="newly provisioned"
     				fi
	 		else
    				new="previously existing"
   			fi
				
			while ( [ "${database_name}" = "" ] )
			do
				database_name="`/usr/bin/exo dbaas list -O json | /usr/bin/jq -r '.[] | select (.name == "'${database_name}'").name'`"
				/bin/sleep 10
				status "Waiting for your new database cluster to be reponsive and online"
			done

 			status "A ${new} database is available with name ${database_name}"

			export DATABASE_INSTALLATION_TYPE="DBaaS"
			export DBaaS_HOSTNAME="`/usr/bin/exo -O json dbaas show --zone ${database_region} ${database_name} | /usr/bin/jq -r ".${database_engine}.uri_params.host"`"

			while ( [ "${DBaaS_PASSWORD}" = "" ] || [ "${DBaaS_USERNAME}" = "" ] )
			do
				status "Trying to obtain database credentials...This might take a couple of minutes as the new database initialises..."
				/bin/sleep 10
				export DBaaS_USERNAME="`/usr/bin/exo -O json dbaas show --zone ${database_region} ${database_name} | /usr/bin/jq -r ".${database_engine}.uri_params.user"`"
				export DBaaS_PASSWORD="`/usr/bin/exo -O json dbaas show --zone ${database_region} ${database_name} | /usr/bin/jq -r ".${database_engine}.uri_params.password"`"
			done   
	
			export DBaaS_DBNAME="${database_name}"
			export DB_PORT="`/usr/bin/exo -O json dbaas show --zone ${database_region} ${database_name} | /usr/bin/jq -r ".${database_engine}.uri_params.port"`"

			#Open up fully until we are installed and then tighten up the firewall
			if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep Postgres`" = "" ] )
			then 
				/usr/bin/exo dbaas update --zone ${database_region} ${database_name} --mysql-ip-filter="${VPC_IP_RANGE}"
			else
				/usr/bin/exo dbaas update --zone ${database_region} ${database_name} --pg-ip-filter="${VPC_IP_RANGE}"
			fi

	
			status "The Values I have retrieved for your database setup are:"
			status "##########################################################"
			status "HOSTNAME:${DBaaS_HOSTNAME}"
			status "USERNAME:${DBaaS_USERNAME}"
			status "PASSWORD:${DBaaS_PASSWORD}"
   			status "DATABASENAME:${DBaaS_DBNAME}"
			status "PORT:${DB_PORT}"
			status "##########################################################"
			status "If these settings look OK to you, press <enter>"
		
  			if ( [ "${HARDCORE}" != "1" ] )
			then
				read x
			fi
		fi
	fi

	#########################################################################################################
	#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:<engine>:<region>:<machine_type>:<cluster_size>:<cluster_label>:<database_name>
	#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql/8:nl-ams:g6-nanode-1:1:test-cluster:testdb1"
	#DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:<engine>:<region>:<machine_type>:<cluster_size>:<cluster_label>:<database_name>
	#DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:postgresql/14.4:nl-ams:g6-nanode-1:1:test-cluster:testdb1"
	#########################################################################################################
	if ( [ "${CLOUDHOST}" = "linode" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
	then
		if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
		then
			database_type="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $1}'`"
			engine="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $3}'`"
			cluster_size="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $6}'`" 
			db_region="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $4}'`"
			machine_type="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $5}'`"
   			label="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $7}'`"
         		database_name="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $8}'`"

			if ( [ "${database_type}" = "MySQL" ] )
			then
				status "Your database is being provisioned, please wait....."
				database_id="`/usr/local/bin/linode-cli --json databases mysql-list | jq ".[] | select(.[\\"label\\"] | contains (\\"${label}\\")) | .id"`"
		
				if ( [ "${database_id}" = "" ] )
				then
 
					/usr/local/bin/linode-cli databases mysql-create --label "${label}" --region "${db_region}" --type "${machine_type}" --cluster_size "${cluster_size}" --engine "${engine}" --ssl_connection "true" --allow_list "${VPC_IP_RANGE}"
				
					database_id="`/usr/local/bin/linode-cli --json databases mysql-list | jq ".[] | select(.label | contains ("'${label}'")) | .id"`"
				
					while ( [ "${database_id}" = "" ] )
					do
						/bin/sleep 20
      						database_id="`/usr/local/bin/linode-cli --json databases mysql-list | jq ".[] | select(.label | contains ("'${label}'")) | .id"`"
					done
				fi
			elif ( [ "${database_type}" = "Postgres" ] )
			then
				status "Your database is being provisioned, please wait....."
				database_id="`/usr/local/bin/linode-cli --json databases postgresql-list | jq ".[] | select(.[\\"label\\"] | contains (\\"${label}\\")) | .id"`"
		
				if ( [ "${database_id}" = "" ] )
				then
					if ( [ "${HARDCORE}" != "1" ] )
					then
						status "Do you want your database to be encypted at rest? Please enter 'yes' or 'no'"
						read selection
						while ( [ "${selection}" != "yes" ] && [ "${selection}" != "no" ] )
						do
							status "That is not a recognised option, please type 'yes' or 'no'"
							read selection
						done
					else
						selection="yes"
					fi
					if ( [ "${selection}" = "yes" ] )
					then
						/usr/local/bin/linode-cli databases postgresql-create --label ${label} --engine ${engine} --cluster_size ${cluster_size} --region ${db_region} --type ${machine_type} --encrypted 1
					elif ( [ "${selection}" = "no" ] )
					then
						/usr/local/bin/linode-cli databases postgresql-create --label ${label} --engine ${engine} --cluster_size ${cluster_size} --region ${db_region} --type ${machine_type}
					fi
			
					database_id="`/usr/local/bin/linode-cli --json databases postgresql-list | jq ".[] | select(.[\\"label\\"] | contains (\\"${label}\\")) | .id"`"
					while ( [ "${database_id}" = "" ] )
					do
						/bin/sleep 20
						database_id="`/usr/local/bin/linode-cli --json databases postgresql-list | jq ".[] | select(.[\\"label\\"] | contains (\\"${label}\\")) | .id"`"
					done
				fi
			fi


   			export DBaaS_USERNAME="`/usr/local/bin/linode-cli databases mysql-creds-view ${database_id} --json | /usr/bin/jq -r '.[].username'`"
   			export DBaaS_PASSWORD="`/usr/local/bin/linode-cli databases mysql-creds-view ${database_id} --json | /usr/bin/jq -r '.[].password'`"
			export DBaaS_DBNAME="${database_name}"
   
			status ""
			status "####################################################################################################################################################"
			status "I couldn't see how to get the connection information from the linode-cli command line tool, so you will have to obtain it from the linode gui system"
			status "Once your database is provisioned (which you can check in the linode GUI system, please provide us with the following information which you can obra1in through the connection details within the linode gui"
			status "You will need to collect your databases's hostname, username, password, the database's name from the linode GUI system once it has finished provisioning"
			status "####################################################################################################################################################"
			status "Press <enter> to progress AFTER your database is showing as provisioned and you have collected the above information"

			if ( [ "${HARDCORE}" != "1" ] )
			then
				read x
				status "Please enter your databases' private hostname, for example: lin-12134-4213-mysql-primary-private.servers.linodedb.net"
				read response
				export DBaaS_HOSTNAME="${response}"

			fi
		
			if ( [ "${database_type}" = "MySQL" ] )
			then
				/usr/bin/curl -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -X PUT -d "{ \"allow_list\": [ \"0.0.0.0/0\" ] }" https://api.linode.com/v4/databases/mysql/instances/${database_id}
			elif ( [ "${database_type}" = "Postgres" ] )
			then
				/usr/bin/curl -H "Content-Type: application/json" -H "Authorization: Bearer ${TOKEN}" -X PUT -d "{ \"allow_list\": [ \"0.0.0.0/0\" ] }" https://api.linode.com/v4/databases/postgresql/instances/${database_id}
			fi
		fi
	fi

	#########################################################################################################
	#If you are deploying to vultr provide a setting with the following format in your template
	#DATABASE_DBaaS_INSTALLATION_TYPE="MySQL:DBAAS:mysql:8:lhr:vultr-dbaas-hobbyist-cc-1-25-1:testdb:TestDatabase:2fb13fd1-3145-3127-7132-13f28f1912c1
	#DATABASE_DBaaS_INSTALLATION_TYPE="Postgres:DBAAS:pg:14:lhr:vultr-dbaas-hobbyist-cc-1-25-1:testdb:TestDatabase:2fb13fd1-3145-3127-7132-13f28f1912c1
	#########################################################################################################

	if ( [ "${CLOUDHOST}" = "vultr" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
	then
		if ( [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep DBAAS`" != "" ] )
		then
			database_type="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $1}'`"
			label="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $8}'`"
			engine="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $3}'`"
			engine_version="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $4}'`"
			db_region="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $5}'`"
			machine_type="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $6}'`"
			db_name="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $7}'`"
			vpc_id="`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /usr/bin/awk -F':' '{print $9}'`"

			cluster_id="`/usr/bin/vultr database list -o json | /usr/bin/jq -r '.databases[] | select (.label == "'${label}'").id'`"

			new=""
			if ( [ "${cluster_id}" = "" ] )
			then
   				if ( [ "${BYPASS_DB_LAYER}" = "1" ] )
       				then
	   				status "You can't have the BYPASS_DB_LAYER set to on for a newly provisioned database"
					status "Do want me to set BYPASS_DB_LAYER to off so that the build will continue (Y|y) otherwise I will have to exit"
     					read response
	  				if ( [ "${response}" = "y" ] || [ "${response}" = "Y" ] )
       					then
	    					BYPASS_DB_LAYER="0"
	  				else
       						exit
	     				fi
	  			fi
      
            			status "Creating  database ${label}, with engine: ${engine}, in region: ${db_region} and at size: ${machine_type} please wait..."
				/usr/bin/vultr database create --database-engine="${engine}" --database-engine-version="${engine_version}" --region="${db_region}" --plan="${machine_type}" --label="${label}" --vpc-id="${vpc_id}"
				
    				if ( [ "$?" = "0" ] )
    				then
					new="newly provisioned"
     				fi
	 		else
    				new="previously existing"
   			fi
				
			while ( [ "${cluster_id}" = "" ] )
			do
				cluster_id="`/usr/bin/vultr database list -o json | /usr/bin/jq -r '.databases[] | select (.label == "'${label}'").id'`"
				/bin/sleep 10
				status "Waiting for your new database cluster to be reponsive and online"
			done

 			status "A ${new} database cluster is available with id ${cluster_id}"

			export DBaaS_USERNAME="`/usr/bin/vultr database list -o json | /usr/bin/jq -r '.databases[] | select (.id == "'${cluster_id}'").user'`"
			export DBaaS_PASSWORD="`/usr/bin/vultr database list -o json | /usr/bin/jq -r '.databases[] | select (.id == "'${cluster_id}'").password'`"
   			export DBaaS_HOSTNAME="`/usr/bin/vultr database list -o json | /usr/bin/jq -r '.databases[] | select (.id == "'${cluster_id}'").host'`"
         		export DB_PORT="`/usr/bin/vultr database list -o json | /usr/bin/jq -r '.databases[] | select (.id == "'${cluster_id}'").port'`"
         		export DBaaS_DBNAME="${db_name}"

			status ""
			status "The rest of the settings for your database are as follows:"
			status "##########################################################"
			status "USERNAME:${DBaaS_USERNAME}"
			status "PASSWORD:${DBaaS_PASSWORD}"
			status "HOST:${DBaaS_HOSTNAME}"
			status "PORT:${DB_PORT}"
			status "DB NAME:${DBaaS_DBNAME}"
			status "##########################################################"
			status "If these settings look OK to you, press <enter>"
			read response

  			/usr/bin/vultr database update ${cluster_id} --trusted-ips "${VPC_IP_RANGE}"
		fi
	fi
fi

if ( [ -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBaaS_HOSTNAME ] )
then
        /bin/rm ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBaaS_HOSTNAME 
fi

if ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] )
then
	/bin/echo "${DBaaS_HOSTNAME}" > ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/DBaaS_HOSTNAME
fi
