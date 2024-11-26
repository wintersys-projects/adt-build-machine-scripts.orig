#!/bin/sh
#########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will just check that we haven't got any ADT servers running already
#########################################################################################
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
authorised="no"
machine_types="as-${REGION}-${BUILD_IDENTIFIER} ws--${REGION}-${BUILD_IDENTIFIER} db--${REGION}-${BUILD_IDENTIFIER}"

for machine_type in ${machine_types}
do
	authorised="no"
	while ( [ "${authorised}" = "no" ] )
	do
		if (    [ "`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh "${machine_type}" ${CLOUDHOST} 2> /dev/null`" != "" ] )
		then
			status "#####################################################################################"
			status "It seems like there is an ${machine_type} already running please close it down and rebuild"
			status "#####################################################################################"
			status "Press <enter> to try again (once the ${machine_type} I found is offline"
   			read x
  		else
   			authorised="yes"
		fi
 	done
done

