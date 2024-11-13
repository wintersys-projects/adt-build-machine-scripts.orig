#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : If the build machine is created without to the adt-vpc from the GUI system
# then we check for that if "BUILD_MACHINE_VPC=1" and try and remedy it here
###################################################################################
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

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
	build_machine_id="`/usr/local/bin/doctl compute droplet list | grep ${build_machine_ip} | /usr/bin/awk '{print $1}'`"

	vpc_id="`/usr/local/bin/doctl vpcs list  | /bin/grep "adt-vpc" | /bin/grep "${REGION}" | /usr/bin/awk '{print $1}'`"

	if ( [ "`/usr/local/bin/doctl compute droplet get ${build_machine_id} | /bin/grep ${vpc_id}`" = "" ] )
	then
		status "It looks like this build machine droplet wasn't attached to the adt-vpc when you created it and I was expecting it to be (BUILD_MACHINE_VPC) and that might cause problems"
		status "Press <enter> to acknowledge"
		if ( [ "${HARDCORE}" != "1" ] )
		then
			read x
		fi
	fi
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
	if ( [ "`/usr/bin/exo compute private-network list -O text | /bin/grep adt_private_net_${REGION}`" = "" ] )
	then
		/usr/bin/exo compute private-network create adt_private_net_${REGION} --zone ${REGION} --start-ip 10.0.0.20 --end-ip 10.0.0.200 --netmask 255.255.255.0
	fi

	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
        build_machine_id="`/usr/bin/exo compute instance list --zone ${REGION} -O json | /usr/bin/jq -r '.[] | select (.ip_address =="'${build_machine_ip}'").id'`"
	if ( [ "`/usr/bin/exo compute instance show  ${build_machine_id} | /bin/grep adt_private_net_${REGION}`" = "" ] )
	then
		status "#################################################################################"
		status "Attempting to attach your build machine to the private network because it wasn't created"
		status "Connected to it through the GUI system. Your connection may or may not drop."
		status "If this happens you will need to reconnect and rerun the build from the beginning"
		status "To prevent this happening in the future create your build machine connected to a private network"
		status "When you provision it using the exoscale GUI system and BUILD_MACHINE_VPC=1"
		status "#################################################################################"
		status "This will only happen once and as a remedial intervention to avoid future problems"
		status "Press <enter> to continue"
  
		if ( [ "${HARDCORE}" != "1" ] )
		then
			read x
		fi
  
		count="0" 
		while ( [ "`/usr/bin/exo compute instance show  ${build_machine_id} | /bin/grep adt_private_net_${REGION}`" = "" ] && [ "${count}" -lt "5" ] )
		do
			/bin/sleep 5
			count="`/usr/bin/expr ${count} + 1`"
			/usr/bin/exo compute instance private-network attach  ${build_machine_id} adt_private_net_${REGION} --zone ${REGION} 
		done
  
		if ( [ "${count}" = "5" ] )
		then
			status "It looks like your build machine couldn't be connected to the Private Network, please investigate"
			exit
		fi
	fi  
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
	if ( [ "`${BUILD_HOME}/providerscripts/server/GetServerPrivateIPAddresses.sh ${build_machine_ip} ${CLOUDHOST}`" = "" ] )
	then
 		if ( [ "${BUILD_MACHINE_VPC}" = "1" ] )
   		then
			status "NOTICE: Your build machine isn't attached to a VPC and BUILD_MACHINE_VPC is set to 1"
   			status "I will change BUILD_MACHINE_VPC to 0"
      			BUILD_MACHINE_VPC="0"
   		fi
	fi
fi

if (  [ "${CLOUDHOST}" = "vultr" ] )
then
	export VULTR_API_KEY="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/TOKEN`"

	build_machine_ip="`${BUILD_HOME}/helperscripts/GetBuildClientIP.sh`"
	build_machine_id="`/usr/bin/vultr instance list | /bin/grep -w ${build_machine_ip} | /usr/bin/awk '{print $1}'`"
	
	vpc_id="`/usr/bin/vultr vpc2 list -o json | /usr/bin/jq -r '.vpcs[] | select (.description == "adt-vpc").id'`"

	if ( [ "${vpc_id}" = "" ] )
	then
		/usr/bin/vultr vpc2 create --region="${REGION}" --description="adt-vpc" --ip-type="v4" --ip-block="192.168.0.0" --prefix-length="16"
	fi

	if ( [ "`/usr/bin/vultr vpc2 nodes list ${vpc_id} | /bin/grep ${build_machine_id}`" = "" ] )
	then
		status "#################################################################################"
		status "Attempting to attach your build machine to the VPC because it wasn't created"
		status "Connected to a VPC using the GUI system. Your connection may or may not drop."
		status "If this happens you will need to reconnect and rerun the build from the beginning"
		status "To prevent this happening in the future create your build machine connected to a VPC"
		status "When you provision it using the vultr GUI system and BUILD_MACHINE_VPC=1"
		status "#################################################################################"
		status "This will only happen once and as a remedial intervention to avoid future problems"
		status "Press <enter> to continue"
		if ( [ "${HARDCORE}" != "1" ] )
		then
			read x
		fi
		count="0"
		while ( [ "`/usr/bin/vultr vpc2 nodes list ${vpc_id} | /bin/grep ${build_machine_id}`" = "" ] && [ "${count}" -lt " 5" ] )
		do
			count="`/usr/bin/expr ${count} + 1`"
			/usr/bin/vultr vpc2 nodes attach ${vpc_id} --nodes="${build_machine_id}"
			/bin/sleep 5
		done
		if ( [ "${count}" = "5" ] )
		then
			status "It looks like your build machine couldn't be connected to the VPC, please investigate"
			exit
		fi
	fi
fi
