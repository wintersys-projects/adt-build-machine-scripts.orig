#!/bin/sh
#############################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This will make a total backup of application webroot and application database
# for all periodicities. 
###########################################################################################################
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

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "About to attempt backups for each periodicity of your websever's webroot"
/bin/echo "Press <enter> to begin"
read x
/bin/sh ${BUILD_HOME}/helperscripts/ExecuteOnWebserver.sh "/usr/bin/run ./providerscripts/backupscripts/RemoteBackupAllPeriodicities.sh"
/bin/echo "I believe that your webroot is backed up for each periodicity maybe check your datatore or git repositories"
/bin/echo "Press <enter> to continue"
read x
/bin/echo "About to attempt backups for each periodicity of your database"
/bin/echo "Press <enter> to begin"
read x
/bin/sh ${BUILD_HOME}/helperscripts/ExecuteOnDatabase.sh "/usr/bin/run ./providerscripts/backupscripts/RemoteBackupAllPeriodicities.sh"
/bin/echo "I believe that your database is backed up for each periodicity maybe check your datatore or git repositories"

