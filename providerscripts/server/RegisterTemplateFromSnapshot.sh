#!/bin/bash
####################################################################################
# Author : Peter Winter
# Date   : 13/06/2016
# Description : Some provider's need to register generated snapshots as image templates.
# If that is the case, this script can be used. 
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

if ( [ "${CLOUDHOST}" = "digitalocean" ] )
then
	 :
fi

if ( [ "${CLOUDHOST}" = "exoscale" ] )
then
	SNAPSHOT_ID=${snapshot_id}
	TEMPLATE_ID=$(/usr/bin/exo vm snapshot show --output-template {{.TemplateID}} ${SNAPSHOT_ID})
	BOOTMODE=$(/usr/bin/exo vm template show --output-template {{.BootMode}} ${TEMPLATE_ID})
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
	 :
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
	 :
fi

