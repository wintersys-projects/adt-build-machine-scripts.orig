#!/bin/sh
#########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : This will initialise the error streams/error reporting setup
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

if ( [ ! -d ${BUILD_HOME}/logs ] )
then
	/bin/mkdir -p ${BUILD_HOME}/logs
fi

exec 3>&1
out_file="build_out-`/bin/date | /bin/sed 's/ //g'`"
exec 1>>${BUILD_HOME}/logs/${out_file}
err_file="build_err-`/bin/date | /bin/sed 's/ //g'`"
exec 2>>${BUILD_HOME}/logs/${err_file}

/bin/echo "Most of the messages you will see here are soft errors. All errors are recorded though, should you need to review them" > ${BUILD_HOME}/logs/${err_file}

if ( [ "${HARDCORE}" != "1" ] )
then
	status "#################################################################################################"
	status "If the build process freezes or fails to complete for some reason, please review the error stream"
	status "The error stream for this build is located at: ${BUILD_HOME}/logs/${err_file}"
	status "#################################################################################################"
	status "Press <enter> to continue"
	read x
fi

