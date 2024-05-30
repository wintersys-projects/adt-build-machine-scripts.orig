#!/bin/sh
###################################################################################
# Author : Peter Winter
# Date   : 16/07/2016
# Description : Fetches an item from the repository
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
#####################################################################################
#####################################################################################
#set -x

repository_provider="${1}"
repository_item="${2}"

if ( [ "${repository_provider}" = "bitbucket" ] )
then
	/usr/bin/git checkout FETCH_HEAD -- ${repository_item}
fi
if ( [ "${repository_provider}" = "github" ] )
then
	/usr/bin/git checkout FETCH_HEAD -- ${repository_item}
fi
if ( [ "${repository_provider}" = "gitlab" ] )
then
	/usr/bin/git checkout FETCH_HEAD -- ${repository_item}
fi

