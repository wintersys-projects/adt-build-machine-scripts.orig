#!/bin/sh
####################################################################################
# Description: This script will check for assets that have been stored in a particular
# datastore bucket from previous application deployments. If we are deploying a new
# baseline that wants to use the same bucket as a previous application has used then
# the baseline will overwrite any assets previously stored so we need to check with the
# user that they are OK with this and they intend it. This script will make a backup
# of the assets in the bucket to be overwritten as a safety measure which may take a bit
# of time depending on the size of the bucket. In truth this most likely won't happen
# in regular use but in testing it happened quite a lot which is why I could see that
# a check was needed.
#
# Date: 07-11/2016
# Author: Peter Winter
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
#####################################################################################
#####################################################################################
#set -x

#When we are a baseline, we want to persist all our assets to our datastore. This involves deleting any existing assets from the bucket
#we are persisting to so we issue a warning here, that the existing assets will be purged

if ( [ "${BUILD_CHOICE}" = "0" ] || [ "${BUILD_CHOICE}" = "1" ] )
then
	status "Checking to see if there are any assets already existing for the ${WEBSITE_URL} build in your datastore..."
	for assettype in `/bin/echo ${DIRECTORIES_TO_MOUNT} | /bin/sed 's/:/ /'`
	do
 		assetbucket="`/bin/echo "${WEBSITE_URL}" | /bin/sed 's/\./-/g'`-${assettype}"
		if ( [ "`${BUILD_HOME}/providerscripts/datastore/ListFromDatastore.sh "${assets_bucket}" | /usr/bin/wc -l`" -gt "0" ] )
		then
			status "###################################################################################################################"
			status "=CRITICAL WARNING    CRITICAL WARNING   CRITICAL WARNING   CRITICAL WARNING   CRITICAL WARNING   CRITICAL WARNING="
			status "###################################################################################################################"
			status "Hi Mate, there's some assets in your datastore for this website. They are probably from a previous build"
			status "You have selected a baseline or a virgin build this means existing assets will be deleted."
			status "With this in mind, I will take a safety backup for you of your existing assets. The bucket name of the copy"
			status "Will be displayed which you might want to make a note of for future reference should you need to reinstall the previous"
			status "version."
			status "-------------"
			status "IMPORTANT:FYI"
			status "-------------"
			status "Additional warning, backups of your application sourcode and database stored in your git repository will also be overwritten"
			status "During normal operation of this particular deployment. You might want to CHECK IF YOU HAVE SOURCECODE AND DATABASE BACKUPS"
			status "From previous builds in your git repository that clash with what you are trying to deploy here"
			status "If you are fine with previous builds being overwritten (its a deliberate redeploy of the same application, right on),"
			status "But, if not, proceed with caution. Thanks"
			status "###########################################################################################"
			status "IT IS STRONGLY ADVISED THAT YOU MAKE A SAFETY BACKUP OF THE ASSETS I HAVE DISCOVERED"
			status "DEPENDING ON THE SIZE OF THE ASSETS IN YOUR DATASTORE THIS COULD TAKE SOME TIME TO COMPLETE"
			status "###########################################################################################"
			status "##############################################################################################################################"
			status "TYPE 'Y' or 'y' to make a safety backup or 'NO BACKUP' to not make one ('NO BACKUP') IS A DESTRUCTIVE CHOICE THAT CANNOT BE RECOVERED)"
			status "If you don't understand what 'NO BACKUP' does, don't type it"
			status "Enter your choice now:"
			if ( [ "${HARDCORE}" != "1" ] || [ "${PARAMETERS}" = "1" ]  )
			then
				read input
			fi

			while ( [ "${input}" != "Y" ] && [ "${input}" != "y" ] && [ "${input}" != "NO BACKUP" ] )
			do
				status "That is not a valid input, please enter 'Y', 'y', or 'NO BACKUP'"
				status "Make sure you understand what 'NO BACKUP' means if you don't understand, don't type 'NO BACKUP'"
				if ( [ "${HARDCORE}" != "1" ]  || [ "${PARAMETERS}" = "1" ] )
				then
					read input
				fi
			done

			if ( [ "${input}" = "Y" ] || [ "${input}" = "Y" ] ) 
			then
				status "Making a safety backup: s3://${assets_bucket}-backup-$$ in your ${DATASTORE_CHOICE} datastore from a previous build of this website - ${WEBSITE_URL} , please wait....."
			
				${BUILD_HOME}/providerscripts/datastore/MountDatastore.sh ${assets_bucket}-backup-$$
				${BUILD_HOME}/providerscripts/datastore/SyncDatastore.sh ${assets_bucket} ${assets_bucket}-backup-$$
				${BUILD_HOME}/providerscripts/datastore/DeleteFromDatastore.sh ${assets_bucket}
			
				status "OK, thanks for waiting. You can find your previously deployed assets in s3://${assets_bucket}-backup-$$ in your ${DATASTORE_CHOICE} datastore."
				status " please press <enter> to continue"
				if ( [ "${HARDCORE}" != "1" ]  || [ "${PARAMETERS}" = "1" ] )
				then
					read x
				fi
			fi
		fi
	done
fi
