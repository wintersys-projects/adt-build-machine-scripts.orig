#!/bin/sh
#################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : This just checks that we are on the right type of machine and that
# our id is correct
##################################################################################
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

#Check that we are 64 bit
if ( [ "`/usr/bin/dpkg --print-architecture`" = "i386" ] )
then
	status "############################################################################################################"
	status "Darn it. This script requires a 64 bit machine to run on. I have to exit. If you don't have a 64 bit machine"
	status "To build on of your own, you can spin one up in the cloud (ubuntu 20.04 and up) or (debian 10 and up ) and use that as your build machine to deploy from"
	status "############################################################################################################"
	exit
fi

#Check that you are root and if not make some recommendations
if ( [ "`/usr/bin/id -u`" != "0" ] )
then
	status ""
	status ""
	status "###################################################################################################################################"
	status "You need to run this script either directly as root or with the sudo command as it needs to make some installations to your machine"
	status "If this is a problem and you don't want stuff installed on your machine, I recommend that you spin up a dedicated build machine"
	status "in the cloud for dedicated use when building/deploying with this toolkit (ubuntu 20.04 and up or debian 10 and up) are suitable build machines to use"
	status "###################################################################################################################################"
	exit
fi


