#!/bin/sh
##################################################################################################################
# Description : This script will reset all the 'build time' files so that just the raw sourcecode is left or
# it is reset to its original state. This is useful if you wish to store updates to the build client in a repository
# and you don't want all the other gubbins to be stored with it.
# Date : 07-11-16
# Author: Peter Winter
##################################################################################################################
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

if ( [ ! -f  ./ResetBuildKit.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/rm .* 2>/dev/null

if ( [ -d ${BUILD_HOME}/logs ] )
then
	/bin/rm -rf ${BUILD_HOME}/logs
fi

if ( [ -d ${BUILD_HOME}/ssl ] )
then
	/bin/rm -rf ${BUILD_HOME}/ssl
fi

if ( [ -d ${BUILD_HOME}/runtimedata ] )
then
	/bin/rm -rf ${BUILD_HOME}/runtimedata
fi

if ( [ -d ${BUILD_HOME}/buildconfiguration ] )
then
	/bin/rm -rf ${BUILD_HOME}/buildconfiguration
fi

if ( [ -d ${BUILD_HOME}/keys ] )
then
	/bin/rm -rf ${BUILD_HOME}/keys
fi

if ( [ -d ${BUILD_HOME}/snapshots ] )
then
	/bin/rm -rf ${BUILD_HOME}/snapshots
fi

/bin/rm ${BUILD_HOME}/*.tar.gz
/bin/rm ${BUILD_HOME}/*.zip

if ( [ -d ${BUILD_HOME}/.git ] )
then
	/bin/rm -r ${BUILD_HOME}/.git
fi

if ( [ -d ${BUILD_HOME}/overridescripts ] )
then
	/bin/rm -rf ${BUILD_HOME}/overridescripts/
fi

/bin/rm -r ${BUILD_HOME}/.lego*
/bin/rm ${BUILD_HOME}/.s3cfg*

