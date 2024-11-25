#!/bin/sh
###########################################################################################################
# Author: Peter Winter
# Date  : 13/07/2016
# Description : You can edit a template of your choice using this script
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
#set -x

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which cloudhost do you want to view logs for (1)DigitalOcean, (2)Exoscale, (3)Linode or (4)Vultr"
read response

if ( [ "${response}" = "1" ] )
then
        CLOUDHOST="digitalocean"
fi
if ( [ "${response}" = "2" ] )
then
        CLOUDHOST="exoscale"
fi
if ( [ "${response}" = "3" ] )
then
        CLOUDHOST="linode"
fi
if ( [ "${response}" = "4" ] )
then
        CLOUDHOST="vultr"
fi

/bin/echo "The following templates are available, which one do you want?"
/bin/ls ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/*tmpl | /usr/bin/awk -F'/' '{print $NF}'

/bin/echo "Type the name of the template you want from the list above"
read template

/usr/bin/vi ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${template} 
