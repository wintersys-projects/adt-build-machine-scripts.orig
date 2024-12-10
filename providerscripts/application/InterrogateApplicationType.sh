#!/bin/sh
####################################################################################
# Description: This script will work out what Application we are deploying, if any.
# There are several scenarios. The 1st is that it is a virgin install of an Application
# in which case we can discern elsewhere which Application it is. The second is if we
# are deploying sourcecode from a repository such as bitbucket or github. The 3rd is
# if we are deploying from a datastore such as Amazon S3 or Google Cloud.  The way things
# work, the repositories are the primary backup mechanism, but backups are also made to
# a datastore. In the case when a repository pull fails, the system falls back to the
# datastore and checks for a copy there. This script is written to deal with all of
# those scenarios.
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

status () {
        /bin/echo "$1" | /usr/bin/tee /dev/fd/3 2>/dev/null
}

website_subdomain="`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $1}'`"



periodicity=""

if ( [ "${BUILD_CHOICE}" = "2" ] )
then
        periodicity="hourly"
elif ( [ "${BUILD_CHOICE}" = "3" ] )
then
        periodicity="daily"
elif ( [ "${BUILD_CHOICE}" = "4" ] )
then
        periodicity="weekly"
elif ( [ "${BUILD_CHOICE}" = "5" ] )
then
        periodicity="monthly"
elif ( [ "${BUILD_CHOICE}" = "6" ] )
then
        periodicity="bimonthly"
fi
if ( [ "${periodicity}" != "" ] )
then
        backuprepository="${website_subdomain}-${WEBSITE_NAME}-webroot-sourcecode-${periodicity}-${BUILD_IDENTIFIER}"
        backuparchive="`/bin/echo ${WEBSITE_URL} | /bin/sed 's/\./-/g'`-${periodicity}/applicationsourcecode.tar.gz"
else
        status "Your build kit doesn't seem to have a valid periodicity set"
fi

interrogation_home="${BUILD_HOME}/interrogation"

if ( [ ! -d ${interrogation_home} ] )
then
        /bin/mkdir -p ${interrogation_home}
fi

if ( [ -d ${interrogation_home} ] )
then
        /bin/rm -r ${interrogation_home}/* 1>/dev/null 2>/dev/null
fi

cd ${interrogation_home}

interrogated="0"

if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
        gitrepo="0"
        if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY} 2>/dev/null`" = "" ] )
        then
                status "Sorry, could not find the baseline repository for you application when I was expecting to, will have to exit..."
                status "Press <enter to exit>"
                if ( [ "${HARDCORE}" != "1" ] )
                then
                        read response
                fi
                exit
        else
                status "I have found potentially usable baseline sourcecode in your git repo. The build can proceed"
        fi
fi


if ( [ "${BUILD_ARCHIVE_CHOICE}" != "baseline" ] && [ "${BUILD_ARCHIVE_CHOICE}" != "virgin" ] )
then
        datastorebucket="0"
        ${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${backuparchive}
        archivename="`/bin/echo ${backuparchive} | /usr/bin/awk -F'/' '{print $NF}'`"
        archive="${interrogation_home}/${archivename}"

        if ( [  -f ${archive} ] )
        then
                status "Found candidate sourcecode from a backup in your datastore"
                status ""
                /bin/rm ${archive}
                datastorebucket="1"
        else
                status "Did not find candidate sourcecode in your datastore"
        fi
fi

if ( [ "${gitrepo}" = "1" ] || [ "${datastorebucket}" = "1" ] )
then
        status ""
        status "############################"
        status "Conclusion of interrogation"
        status "###########################"

        status "I have found potentially usable candidate sourcecode in your datastore. The build can proceed"
else
        status "I HAVE NOT FOUND CANDIDATE SOURCECODE IN EITHER YOUR GIT REPO OR YOUR DATASTORE...THE BUILD CANNOT PROCEED"
fi

status "Press <enter>"
if ( [ "${HARDCORE}" != "1" ] )
then
        read x
fi

if ( [ "${gitrep}" = "1" ] )
then
        ${BUILD_HOME}/providerscripts/git/GitClone.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}
        . ${BUILD_HOME}/providerscripts/application/WhichApplicationByGitAndBaseline.sh
        /bin/rm -rf ${interrogation_home}/${APPLICATION_BASELINE_SOURCECODE_REPOSITORY} 1>/dev/null 2>/dev/null
fi

if ( [ "${datastorebucket}" = "1" ] )
then
        ${BUILD_HOME}/providerscripts/datastore/GetFromDatastore.sh ${backuparchive}
        archivename="`/bin/echo ${backuparchive} | /usr/bin/awk -F'/' '{print $NF}'`"
        archive="${interrogation_home}/${archivename}"
        /bin/tar xvfz ${archive} -C ${interrogation_home}
        . ${BUILD_HOME}/providerscripts/application/WhichApplicationByDatastoreAndBackup.sh
        /bin/rm -rf ${interrogation_home}/tmp 1>/dev/null 2>/dev/null
        /bin/rm ${interrogation_home}/applicationsourcecode.tar.gz 1>/dev/null 2>/dev/null
fi

/bin/rmdir ${interrogation_home}

cd ${BUILD_HOME}
