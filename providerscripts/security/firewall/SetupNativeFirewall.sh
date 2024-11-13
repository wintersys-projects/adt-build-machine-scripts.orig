#!/bin/sh
########################################################################################
# Author: Peter Winter
# Date  : 12/07/2021
# Description : This will apply any native firewalling if necessary
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

if ( [ "${ACTIVE_FIREWALLS}" = "2" ] || [ "${ACTIVE_FIREWALLS}" = "3" ] )
then
	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"

	status ""
	status ""
	status "###############################################################"
	status "Just adjusting your native firewalling system , please wait...."
	status "###############################################################"

	if ( [ "${CLOUDHOST}" = "digitalocean" ] )
	then
		if ( [ "${PRE_BUILD}" = "0" ] )
		then
			autoscaler_ids="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh autoscaler ${CLOUDHOST}`"
			
			rules=""
			
			if ( [ "${autoscaler_ids}" != "" ] )
			then
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					rules="protocol:tcp,ports:${SSH_PORT},address:${build_machine_ip}/32"
				fi

				rules="${rules} protocol:tcp,ports:${SSH_PORT},address:${VPC_IP_RANGE} protocol:icmp,address:0.0.0.0/0"
				rules="`/bin/echo ${rules} | /usr/bin/tr -s ' '`"

				autoscaler_firewall_id="`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-autoscaler" ).id'`"
				/usr/local/bin/doctl compute firewall add-rules ${autoscaler_firewall_id} --inbound-rules "${rules}"
			
				for autoscaler_id in ${autoscaler_ids}
				do
					/usr/local/bin/doctl compute firewall add-droplets ${autoscaler_firewall_id} --droplet-ids ${autoscaler_id}                
				done
			fi

			webserver_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh webserver ${CLOUDHOST}`"

			if ( [ "${webserver_id}" != "" ] )
			then
				rules=""

				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					 rules="protocol:tcp,ports:${SSH_PORT},address:${build_machine_ip}/32"
				fi
		
				. ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh
						
		
				if ( [ "${alldnsproxyips}" != "" ] )
				then
					for ip in ${alldnsproxyips}
					do
						rules=${rules}" protocol:tcp,ports:443,address:${ip} " 
					done
					rules=${rules}" protocol:tcp,ports:${SSH_PORT},address:${VPC_IP_RANGE} "
				else
					rules=${rules}" protocol:tcp,ports:${SSH_PORT},address:${VPC_IP_RANGE} protocol:tcp,ports:443,address:0.0.0.0/0 "
				fi
    
		     		rules=${rules}"  protocol:tcp,ports:443,address:${VPC_IP_RANGE} " 

				rules=${rules}" protocol:icmp,address:0.0.0.0/0"
				rules="`/bin/echo ${rules} | /usr/bin/tr -s ' '`"
			
				webserver_firewall_id="`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-webserver" ).id'`"
				/usr/local/bin/doctl compute firewall add-rules ${webserver_firewall_id} --inbound-rules "${rules}"
				/usr/local/bin/doctl compute firewall add-droplets ${webserver_firewall_id} --droplet-ids ${webserver_id}
			fi
			
			database_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh database ${CLOUDHOST}`"

			if ( [ "${database_id}" != "" ] )
			then
				rules=""
		
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					rules="protocol:tcp,ports:${SSH_PORT},address:${build_machine_ip}/32"
				fi

				rules="${rules} protocol:tcp,ports:${SSH_PORT},address:${VPC_IP_RANGE} protocol:tcp,ports:${DB_PORT},address:${VPC_IP_RANGE} protocol:icmp,address:0.0.0.0/0"

				rules="`/bin/echo ${rules} | /usr/bin/tr -s ' '`"

				database_firewall_id="`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-database" ).id'`"
				/usr/local/bin/doctl compute firewall add-rules ${database_firewall_id} --inbound-rules "${rules}"
				/usr/local/bin/doctl compute firewall add-droplets ${database_firewall_id} --droplet-ids ${database_id}                
			fi
		
		elif ( [ "${PRE_BUILD}" = "1" ] )
                then
                        autoscaler_firewall_id="`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-autoscaler" ).id'`"

                        if ( [ "${autoscaler_firewall_id}" != "" ] )
                        then
                                /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${autoscaler_firewall_id} --force 
                        fi

                        while ( [ "`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-autoscaler" ).id'`" != "" ] )
                        do
                                /bin/sleep 5
                        done

                        /usr/local/bin/doctl compute firewall create --name "adt-autoscaler" --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0 protocol:udp,ports:all,address:0.0.0.0/0 protocol:icmp,address:0.0.0.0/0"


                        webserver_firewall_id="`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-webserver" ).id'`"

                        if ( [ "${webserver_firewall_id}" != "" ] )
                        then
                                /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${webserver_firewall_id} --force 
                        fi

                        while ( [ "`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-webserver" ).id'`" != "" ] )
                        do
                                /bin/sleep 5
                        done

                        /usr/local/bin/doctl compute firewall create --name "adt-webserver" --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0 protocol:udp,ports:all,address:0.0.0.0/0 protocol:icmp,address:0.0.0.0/0"

                        database_firewall_id="`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-database" ).id'`"

                        if ( [ "${database_firewall_id}" != "" ] )
                        then
                                /bin/echo "y" | /usr/local/bin/doctl compute firewall delete ${database_firewall_id} --force 
                        fi

                        while ( [ "`/usr/local/bin/doctl -o json compute firewall list | /usr/bin/jq -r '.[] | select (.name == "adt-database" ).id'`" != "" ] )
                        do
                                /bin/sleep 5
                        done

                        /usr/local/bin/doctl compute firewall create --name "adt-database" --outbound-rules "protocol:tcp,ports:all,address:0.0.0.0/0 protocol:udp,ports:all,address:0.0.0.0/0 protocol:icmp,address:0.0.0.0/0"

                fi 
	fi

	if ( [ "${CLOUDHOST}" = "exoscale" ] )
	then
		if ( [ "${PRE_BUILD}" = "0" ] )
		then
			autoscaler_ids="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh autoscaler ${CLOUDHOST}`"

			if ( [ "${autoscaler_ids}" != "" ] )
			then
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					/usr/bin/exo compute security-group rule add adt-autoscaler --network ${build_machine_ip}/32 --port ${SSH_PORT}
				fi
				/usr/bin/exo compute security-group rule add adt-autoscaler --network ${VPC_IP_RANGE} --port ${SSH_PORT}
				/usr/bin/exo compute security-group rule add adt-autoscaler --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8
			
				for autoscaler_id in ${autoscaler_ids}
				do
					/usr/bin/exo compute instance security-group add ${autoscaler_id} adt-autoscaler
				done
			fi

			webserver_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh webserver ${CLOUDHOST}`"

			if ( [ "${webserver_id}" != "" ] )
			then
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					/usr/bin/exo compute security-group rule add adt-webserver --network ${build_machine_ip}/32 --port ${SSH_PORT}
				fi
			
				/usr/bin/exo compute security-group rule add adt-webserver --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8
				/usr/bin/exo compute security-group rule add adt-autoscaler --network ${VPC_IP_RANGE} --port ${SSH_PORT}
			
				. ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh

				if ( [ "${alldnsproxyips}" != "" ] )
				then
					alldnsproxyips="`/bin/echo ${alldnsproxyips} | /bin/sed 's/,/ /g' | /bin/sed 's/^"//g' | /bin/sed 's/"$//g'`"
					for ip in ${alldnsproxyips}
					do
						/usr/bin/exo compute security-group rule add adt-webserver --network ${ip} --port 443
					done
     					/usr/bin/exo compute security-group rule add adt-webserver --network ${VPC_IP_RANGE} --port 443
				else
					/usr/bin/exo compute security-group rule add adt-webserver --network 0.0.0.0/0 --port 443
				fi

				/usr/bin/exo compute instance security-group add ${webserver_id} adt-webserver
			fi

			database_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh database ${CLOUDHOST}`"

			if ( [ "${database_id}" != "" ] )
			then
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					/usr/bin/exo compute security-group rule add adt-database --network ${build_machine_ip}/32 --port ${SSH_PORT}
					/usr/bin/exo compute security-group rule add adt-database --network ${build_machine_ip}/32 --port ${DB_PORT}
				fi
				
				/usr/bin/exo compute security-group rule add adt-database --protocol icmp --network 0.0.0.0/0 --icmp-code 0 --icmp-type 8
				/usr/bin/exo compute security-group rule add adt-autoscaler --network ${VPC_IP_RANGE} --port ${SSH_PORT}
				/usr/bin/exo compute security-group rule add adt-autoscaler --network ${VPC_IP_RANGE} --port ${DB_PORT}

				/usr/bin/exo compute instance security-group add ${database_id} adt-database
			fi
			
		elif ( [ "${PRE_BUILD}" = "1" ] )
		then
			/bin/echo "y" | /usr/bin/exo compute security-group delete adt-autoscaler 2>/dev/null
			while ( [ "`/usr/bin/exo -O json compute security-group list adt-autoscaler | /usr/bin/jq '.[] | select (.name == "adt-autoscaler")'`" != "" ] )
			do 
				/bin/sleep 5
			done
			/usr/bin/exo compute security-group create adt-autoscaler  
			
			/bin/echo "y" | /usr/bin/exo compute security-group delete adt-webserver 2>/dev/null
			while ( [ "`/usr/bin/exo -O json compute security-group list adt-webserver | /usr/bin/jq '.[] | select (.name == "adt-webserver")'`" != "" ] )
			do 
				/bin/sleep 5
			done
			/usr/bin/exo compute security-group create adt-webserver  
			
			/bin/echo "y" | /usr/bin/exo compute security-group delete adt-database 2>/dev/null
			while ( [ "`/usr/bin/exo -O json compute security-group list adt-database | /usr/bin/jq '.[] | select (.name == "adt-database")'`" != "" ] )
			do 
				/bin/sleep 5
			done
			/usr/bin/exo compute security-group create adt-database  
		fi
	fi

	if ( [ "${CLOUDHOST}" = "linode" ] )
	then       
		if ( [ "${PRE_BUILD}" = "0" ] )
		then
			autoscaler_firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-autoscaler" ).id'`"
			
			if ( [ "${autoscaler_firewall_id}" != "" ] )
			then
				/usr/local/bin/linode-cli firewalls delete ${autoscaler_firewall_id}
			fi
		   
			/usr/local/bin/linode-cli firewalls create --label "adt-autoscaler" --rules.inbound_policy DROP   --rules.outbound_policy ACCEPT
			autoscaler_firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-autoscaler" ).id'`"
			autoscaler_ids="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh autoscaler ${CLOUDHOST}`"

			if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
			then
				/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[\"${build_machine_ip}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${autoscaler_firewall_id}
			elif ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
			then
				/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${autoscaler_firewall_id}
			fi

			webserver_firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-webserver" ).id'`"
			
			if ( [ "${webserver_firewall_id}" != "" ] )
			then
				/usr/local/bin/linode-cli firewalls delete ${webserver_firewall_id}
			fi
		   
			/usr/local/bin/linode-cli firewalls create --label "adt-webserver" --rules.inbound_policy DROP   --rules.outbound_policy ACCEPT
			webserver_firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-webserver" ).id'`"
			webserver_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh webserver ${CLOUDHOST}`"
						
						
			. ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh
			ips="`/bin/echo ${ips} | /bin/sed 's/,$//g'`"
						

			if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
			then
				if ( [ "${alldnsproxyips}" = "" ] )
				then
					/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[\"${build_machine_ip}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"443\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${webserver_firewall_id}
				else 
					/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[\"${build_machine_ip}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"},{\"addresses\":{\"ipv4\":[${alldnsproxyips}]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"443\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${webserver_firewall_id}
				fi
			elif ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
			then
				if ( [ "${alldnsproxyips}" = "" ] )
				then
					/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"443\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${webserver_firewall_id}
				else 
					/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[${alldnsproxyips}]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"443\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${webserver_firewall_id}
				fi
			fi

			database_firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-database" ).id'`"
			
			if ( [ "${database_firewall_id}" != "" ] )
			then
				/usr/local/bin/linode-cli firewalls delete ${database_firewall_id}
			fi
		   
			/usr/local/bin/linode-cli firewalls create --label "adt-database" --rules.inbound_policy DROP   --rules.outbound_policy ACCEPT
			database_firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-database" ).id'`"
			database_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh database ${CLOUDHOST}`"

			if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
			then
				/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[\"${build_machine_ip}/32\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"${SSH_PORT}\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${database_firewall_id}
			elif ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
			then
				/usr/local/bin/linode-cli firewalls rules-update --inbound  "[{\"addresses\":{\"ipv4\":[\"${VPC_IP_RANGE}\"]},\"action\":\"ACCEPT\",\"protocol\":\"TCP\",\"ports\":\"1-65535\"},{\"addresses\":{\"ipv4\":[\"0.0.0.0/0\"]},\"action\":\"ACCEPT\",\"protocol\":\"ICMP\"}]" ${database_firewall_id}
			fi

			for autoscaler_id in ${autoscaler_ids}
			do
				/usr/local/bin/linode-cli firewalls device-create --id ${autoscaler_id} --type linode ${autoscaler_firewall_id} 2>/dev/null
			done
		
			/usr/local/bin/linode-cli firewalls device-create --id ${webserver_id} --type linode ${webserver_firewall_id} 
			/usr/local/bin/linode-cli firewalls device-create --id ${database_id} --type linode ${database_firewall_id} 
			
		elif ( [ "${PRE_BUILD}" = "1" ] )
		then
			firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-autoscaler" ).id'`"
		
			if ( [ "${firewall_id}" != "" ] )
			then
				/usr/local/bin/linode-cli firewalls delete ${firewall_id}
			fi

			firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-webserver" ).id'`"
		
			if ( [ "${firewall_id}" != "" ] )
			then
				/usr/local/bin/linode-cli firewalls delete ${firewall_id}
			fi

			firewall_id="`/usr/local/bin/linode-cli --json firewalls list | /usr/bin/jq -r '.[] | select (.label == "adt-database" ).id'`"
		
			if ( [ "${firewall_id}" != "" ] )
			then
				/usr/local/bin/linode-cli firewalls delete ${firewall_id}
			fi
		fi    
	fi


	if ( [ "${CLOUDHOST}" = "vultr" ] )
	then
		export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"

		if ( [ "${PRE_BUILD}" = "0" ] )
		then
			autoscaler_ids="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh autoscaler ${CLOUDHOST}`"

			if ( [ "${autoscaler_ids}" != "" ] )
			then
				firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt-autoscaler' | /usr/bin/awk '{print $1}'`"

				if ( [ "${firewall_id}" = "" ] )
				then
					firewall_id="`/usr/bin/vultr firewall group create | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"  
					/usr/bin/vultr firewall group update ${firewall_id} --description "adt-autoscaler"
				else 
					rule_ids="`/usr/bin/vultr firewall rule list ${firewall_id} | /usr/bin/awk '{print $1}' | /usr/bin/tail -n +2 | /usr/bin/head -n -3`"
					for rule_no in ${rule_ids}
					do
						/usr/bin/vultr firewall rule delete ${firewall_id} ${rule_no}
					done
				fi
			
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=tcp --port=${SSH_PORT} --size=32 --ip-type=v4 --subnet=${build_machine_ip}/32
				fi

				/usr/bin/vultr firewall rule create ${firewall_id} --protocol icmp --size 32 --ip-type v4 -s 0.0.0.0/0
				
				for autoscaler_id in ${autoscaler_ids}
				do
					/usr/bin/vultr instance update-firewall-group ${autoscaler_id} -f ${firewall_id}
				done
			fi  
			webserver_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh webserver ${CLOUDHOST}`"

			if ( [ "${webserver_id}" != "" ] )
			then
				firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt-webserver' | /usr/bin/awk '{print $1}'`"
   
				. ${BUILD_HOME}/providerscripts/security/firewall/GetProxyDNSIPs.sh

				if ( [ "${alldnsproxyips}" != "" ] )
				then
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=tcp --port=443 --size=32 --ip-type=v4  --source=cloudflare --subnet=10.0.0.0/8
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=icmp --size=32 --ip-type=v4 --subnet=${VPC_IP_RANGE}
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=icmp --size=32 --ip-type=v4 --subnet=0.0.0.0/0
    				else 
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=tcp --port=443 --size=32 --ip-type=v4 --subnet=0.0.0.0/0
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=icmp --size=32 --ip-type=v4 --subnet=0.0.0.0/0
				fi
			
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=tcp --port=${SSH_PORT} --size=32 --ip-type=v4 --subnet=${build_machine_ip}/32
				fi

				/usr/bin/vultr firewall rule create ${firewall_id} --protocol icmp --size 32 --ip-type v4 -s 0.0.0.0/0
				/usr/bin/vultr instance update-firewall-group ${webserver_id} -f ${firewall_id}
			fi
			
			database_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh database ${CLOUDHOST}`"

			if ( [ "${database_id}" != "" ] )
			then
				firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt-database' | /usr/bin/awk '{print $1}'`"
			
				if ( [ "${BUILD_MACHINE_VPC}" = "0" ] )
				then
					/usr/bin/vultr firewall rule create ${firewall_id} --protocol=tcp --port=${SSH_PORT} --size=32 --ip-type=v4 --subnet=${build_machine_ip}/32
				fi

				/usr/bin/vultr firewall rule create ${firewall_id} --protocol icmp --size 32 --ip-type v4 -s 0.0.0.0/0
				/usr/bin/vultr instance update-firewall-group ${database_id} -f ${firewall_id}
			fi
		elif ( [ "${PRE_BUILD}" = "1" ] )
		then
			firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt-autoscaler' | /usr/bin/awk '{print $1}'`"

			if ( [ "${firewall_id}" = "" ] )
			then
				firewall_id="`/usr/bin/vultr firewall group create | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"  
				/usr/bin/vultr firewall group update ${firewall_id} --description "adt-webserver"
			else 
				rule_ids="`/usr/bin/vultr firewall rule list ${firewall_id} | /usr/bin/awk '{print $1}' | /usr/bin/tail -n +2 | /usr/bin/head -n -3`"
				for rule_no in ${rule_ids}
				do
					/usr/bin/vultr firewall rule delete ${firewall_id} ${rule_no}
				done
			fi

			firewall_id="`/usr/bin/vultr firewall group list | /usr/bin/tail -n +2 | /bin/grep -w 'adt-database' | /usr/bin/awk '{print $1}'`"

			if ( [ "${firewall_id}" = "" ] )
			then
				firewall_id="`/usr/bin/vultr firewall group create | /usr/bin/tail -n +2 | /usr/bin/awk '{print $1}'`"  
				/usr/bin/vultr firewall group update ${firewall_id} --description "adt-database"
			else 
				rule_ids="`/usr/bin/vultr firewall rule list ${firewall_id} | /usr/bin/awk '{print $1}' | /usr/bin/tail -n +2 | /usr/bin/head -n -3`"
				for rule_no in ${rule_ids}
				do
					/usr/bin/vultr firewall rule delete ${firewall_id} ${rule_no}
				done
			fi
		fi
	fi
fi
