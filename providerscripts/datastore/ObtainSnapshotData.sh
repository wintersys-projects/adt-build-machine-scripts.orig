#!/bin/sh
##############################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This script will copy our generated snapshots data from the datastore
###############################################################################
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
#################################################################################
#################################################################################
#set -x

BUILD_HOME="`/usr/bin/pwd | /bin/sed 's/\/helperscripts//g'`"

if ( [ "${SNAPSHOT_ID}" != "" ] )
then
	if ( [ "`/bin/grep "^DATASTORETOOL:*" ${BUILD_HOME}/builddescriptors/buildstylesscp.dat | /usr/bin/awk -F':' '{print $NF}'`" = "s3cmd" ] )
	then
		snapshot_bucket="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{ for(i = 1; i <= NF; i++) { print $i; } }' | /usr/bin/cut -c1-3 | /usr/bin/tr '\n' '-' | /bin/sed 's/-//g'`-snaps"
		if ( [ "`/usr/bin/s3cmd ls s3://${snapshot_bucket}`" != "" ] )
		then
			/usr/bin/s3cmd get s3://${snapshot_bucket}/snapshots.tar.gz
		fi

		if ( [ ! -d ${BUILD_HOME}/snapshots ] )
		then
			/bin/mkdir ${BUILD_HOME}/snapshots
		fi

		if ( [ -f ./snapshots.tar.gz ] )
		then
			/bin/tar xvfz ./snapshots.tar.gz -C ${BUILD_HOME}/snapshots
		fi

		if ( [ -f ./snapshots.tar.gz ] )
		then
			/bin/rm ./snapshots.tar.gz
		fi
	 
		if ( [ "${SNAPSHOT_ID}" != "" ] )
		then
			FULL_SNAPSHOT_ID="`/bin/ls ${BUILD_HOME}/snapshots | /bin/grep ${SNAPSHOT_ID}`"
	   
			if ( [ "${FULL_SNAPSHOT_ID}" != "" ] )
			then
				snapshotids="`/bin/cat ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/snapshotIDs.dat`"
	
				if ( [ "${snapshotids}" != "" ] )
				then
					if ( [ "${AUTOSCALER_IMAGE_ID}" = "" ] && [ "${WEBSERVER_IMAGE_ID}" = "" ] && [ "${DATABASE_IMAGE_ID}" = "" ] )
					then
						AUTOSCALER_IMAGE_ID="`/bin/echo ${snapshotids} | /usr/bin/awk -F':' '{print $1}'`"
						WEBSERVER_IMAGE_ID="`/bin/echo ${snapshotids} | /usr/bin/awk -F':' '{print $2}'`"
						DATABASE_IMAGE_ID="`/bin/echo ${snapshotids} | /usr/bin/awk -F':' '{print $3}'`"
					fi
				fi
			fi
		fi
		/bin/cp -r ${BUILD_HOME}/snapshots/${FULL_SNAPSHOT_ID}/sshkeys/* /root/.ssh
	   /bin/chmod 400 /root/.ssh/*
	fi
fi
