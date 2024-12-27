#!/bin/sh
###################################################################################
# Description : This will validate our template against the quick spec definition
# its important that I know about new regions that are supported and so on for the
# supported cloud providers so that the quick spec can be updated and validated against
# Author: Peter Winter
# Date  : 13/07/2020
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
####################################################################################
####################################################################################

quick_specification="${BUILD_HOME}/templatedconfigurations/quick_specification.dat"

if ( [ "${1}" != "" ] )
then
	templatefile="${1}"
	. ${templatefile} 2>/dev/null
fi

if ( [ "${2}" != "" ] )
then
	BUILD_HOME="${2}"
fi

status 2>/dev/null

if ( [ "$?" = "0" ] )
then
	log_command="status "
else
	log_command="/bin/echo "
fi


${log_command} "######################################################################################################################################################################"
${log_command} "If you see any warning messages below its because I believe that you might want to double check some values in  your template in some way before you make a deployment"
${log_command} "You may get some soft warnings if you check them out and find them to be soft you can safely continue whilst ignoring them"
${log_command} "Your currently active template is :${templatefile})"
${log_command} "######################################################################################################################################################################"

${log_command} ""

${log_command} "####################TEMPLATE VALIDATION REPORT BEGINNING####################"

if ( [ "`/bin/grep "^BUILDOS " ${quick_specification} | /bin/grep -w "${BUILDOS}"`" = "" 2>/dev/null ] )
then
	${log_command} "Your value for the variable BUILDOS (${BUILDOS}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^BUILDOS_VERSION " ${quick_specification} | /bin/grep -w "${BUILDOS_VERSION}" 2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable BUILDOS_VERSION (${BUILDOS_VERSION}) doesn't appear to be valid please review"
else
	if ( [ "${BUILDOS_VERSION}" != "20.04" ] && [ "${BUILDOS_VERSION}" != "22.04" ] && [ "${BUILDOS_VERSION}" != "24.04" ] && [ "${BUILDOS}" = "ubuntu" ] )
	then
		${log_command} "Your value for the variable BUILDOS_VERSION (${BUILDOS_VERSION}) doesn't appear to be valid please review"
	elif ( [ "${BUILDOS_VERSION}" != "11" ] && [ "${BUILDOS_VERSION}" != "12" ] && [ "${BUILDOS}" = "debian" ] )
	then
		${log_command} "Your value for the variable BUILDOS_VERSION (${BUILDOS_VERSION}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^APPLICATION " ${quick_specification} | /bin/grep -w "${APPLICATION}" 2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable APPLICATION (${APPLICATION}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^APPLICATION_IDENTIFIER " ${quick_specification} | /bin/grep -w "${APPLICATION_IDENTIFIER}" 2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable APPLICATION_IDENTIFIER (${APPLICATION_IDENTIFIER}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^S3_HOST_BASE " ${quick_specification} | /bin/grep -w "${S3_HOST_BASE}" 2>/dev/null `" = "" ] )
then
	datastore_choice="`/bin/echo ${DATASTORE_CHOICE} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^S3_HOST_BASE " ${quick_specification} | /bin/grep -w "${S3_HOST_BASE}" | /bin/grep ${datastore_choice}  2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable S3_HOST_BASE (${S3_HOST_BASE}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^S3_LOCATION " ${quick_specification} | /bin/grep -w "${S3_LOCATION}" 2>/dev/null `" = "" ] )
then
	datastore_choice="`/bin/echo ${DATASTORE_CHOICE} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^S3_LOCATION " ${quick_specification} | /bin/grep -w "${S3_LOCATION}" | /bin/grep ${datastore_choice}  2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable S3_LOCATION (${S3_LOCATION}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^EMAIL_NOTIFICATION_LEVEL " ${quick_specification} | /bin/grep -w "${EMAIL_NOTIFICATION_LEVEL}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable EMAIL_NOTIFICATION_LEVEL (${EMAIL_NOTIFICATION_LEVEL}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^DNS_CHOICE " ${quick_specification} | /bin/grep -w "${DNS_CHOICE}" 2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable DNS_CHOICE (${DNS_CHOICE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^APPLICATION_REPOSITORY_PROVIDER " ${quick_specification} | /bin/grep -w "${APPLICATION_REPOSITORY_PROVIDER}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable APPLICATION_REPOSITORY_PROVIDER (${APPLICATION_REPOSITORY_PROVIDER}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^BUILD_MACHINE_VPC " ${quick_specification} | /bin/grep -w "${BUILD_MACHINE_VPC}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable BUILD_MACHINE_VPC (${BUILD_MACHINE_VPC}) doesn't appear to be valid please review"
	#export BUILD_MACHINE_VPC="0"
fi

if ( [ "`/bin/grep "^SYSTEM_EMAIL_PROVIDER " ${quick_specification} | /bin/grep -w "${SYSTEM_EMAIL_PROVIDER}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable SYSTEM_EMAIL_PROVIDER (${SYSTEM_EMAIL_PROVIDER}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^PRODUCTION " ${quick_specification} | /bin/grep -w "${PRODUCTION}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable PRODUCTION (${PRODUCTION}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^DEVELOPMENT " ${quick_specification} | /bin/grep -w "${DEVELOPMENT}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable DEVELOPMENT (${DEVELOPMENT}) doesn't appear to be valid please review"
fi

if ( [ "${PRODUCTION}" = "1" ] && [ "${DEVELOPMENT}" != "0" ] || [ "${PRODUCTION}" = "0" ] && [ "${DEVELOPMENT}" != "1" ]  )
then
	 ${log_command} "It looks like your values for PRODUCTION ( ${PRODUCTION}) and DEVELOPMENT (${DEVELOPMENT}) are inconsistent"
fi

if ( [ "`/bin/grep "^WEBSERVER_CHOICE " ${quick_specification} | /bin/grep -w "${WEBSERVER_CHOICE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable WEBSERVER_CHOICE (${WEBSERVER_CHOICE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^DATABASE_INSTALLATION_TYPE " ${quick_specification} | /bin/grep -w "${DATABASE_INSTALLATION_TYPE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable DATABASE_INSTALLATION_TYPE (${DATABASE_INSTALLATION_TYPE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^PERSIST_ASSETS_TO_CLOUD " ${quick_specification} | /bin/grep -w "${PERSIST_ASSETS_TO_CLOUD}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable PERSIST_ASSETS_TO_CLOUD (${PERSIST_ASSETS_TO_CLOUD}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^BUILD_CHOICE " ${quick_specification} | /bin/grep -w "${BUILD_CHOICE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable BUILD_CHOICE (${BUILD_CHOICE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^BUILD_ARCHIVE_CHOICE " ${quick_specification} | /bin/grep -w "${BUILD_ARCHIVE_CHOICE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable BUILD_ARCHIVE_CHOICE (${BUILD_ARCHIVE_CHOICE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^APPLICATION_LANGUAGE " ${quick_specification} | /bin/grep -w "${APPLICATION_LANGUAGE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable APPLICATION_LANGUAGE (${APPLICATION_LANGUAGE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^INPARALLEL " ${quick_specification} | /bin/grep -w "${INPARALLEL}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable INPARALLEL (${INPARALLEL}) doesn't appear to be valid please review"
	export INPARALLEL="0"
fi

if ( [ "`/bin/grep "^NO_AUTOSCALERS " ${quick_specification} | /bin/grep -w "${NO_AUTOSCALERS}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable NO_AUTOSCALERS (${NO_AUTOSCALERS}) doesn't appear to be valid please review"
fi

if ( [ "${DEVELOPMENT}" = "1" ] && [ "${NO_AUTOSCALERS}" != "0" ] )
then
	${log_command} "You are in development mode, NO_AUTOSCALERS should be 0 not  (${NO_AUTOSCALERS}) and so doesn't appear to be valid please review"
	export NO_AUTOSCALERS="0"
fi

if ( [ "${PRODUCTION}" = "1" ] && [ "${NO_AUTOSCALERS}" = "0" ] )
then
	${log_command} "You are in production mode, NO_AUTOSCALERS should not be 0 and so doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^PHP_VERSION " ${quick_specification} | /bin/grep -w "${PHP_VERSION}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable PHP_VERSION (${PHP_VERSION}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^REGION " ${quick_specification} | /bin/grep -w "${REGION}"  2>/dev/null `" = "" ] )
then
	cloudhost="`/bin/echo ${CLOUDHOST} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	#this is only set for the exoscale host
	if ( [ "${cloudhost}" = "exoscale" ] )
	then
		if ( [ "`/bin/grep "^REGION " ${quick_specification} | /bin/grep -w "${REGION}" | /bin/grep ${cloudhost} 2>/dev/null `" = "" ] )
		then
			${log_command} "Your value for the variable REGION (${REGION}) doesn't appear to be valid please review"
		fi
	fi
fi

if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] && [ "${DB_PORT}" != "25060" ] )
then
	${log_command} "Your value for the variable DB_PORT is ${DB_PORT} and it can only be '25060' in this configuration"
fi

if ( [ "`/bin/grep "^DB_SIZE " ${quick_specification} | /bin/grep -w "${DB_SIZE}"  2>/dev/null `" = "" ] )
then
	cloudhost="`/bin/echo ${CLOUDHOST} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^DB_SIZE " ${quick_specification} | /bin/grep -w "${DB_SIZE}" | /bin/grep ${cloudhost} 2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable DB_SIZE (${DB_SIZE}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^AS_SIZE " ${quick_specification} | /bin/grep -w "${AS_SIZE}"  2>/dev/null `" = "" ] )
then
	cloudhost="`/bin/echo  ${CLOUDHOST} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^AS_SIZE " ${quick_specification} | /bin/grep -w "${AS_SIZE}" | /bin/grep ${cloudhost} 2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable AS_SIZE (${AS_SIZE}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^WS_SIZE " ${quick_specification} | /bin/grep -w "${WS_SIZE}"  2>/dev/null `" = "" ] )
then
	cloudhost="`/bin/echo ${CLOUDHOST} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^WS_SIZE " ${quick_specification} | /bin/grep -w "${WS_SIZE}" | /bin/grep ${cloudhost} 2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable WS_SIZE (${WS_SIZE}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^DB_SERVER_TYPE " ${quick_specification} | /bin/grep -w "${DB_SERVER_TYPE}"  2>/dev/null `" = "" ] )
then
	cloudhost="`/bin/echo ${CLOUDHOST} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^DB_SERVER_TYPE " ${quick_specification} | /bin/grep -w "${DB_SERVER_TYPE}" | /bin/grep ${cloudhost} 2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable DB_SERVER_TYPE (${DB_SERVER_TYPE}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^AS_SERVER_TYPE " ${quick_specification} | /bin/grep -w "${AS_SERVER_TYPE}"  2>/dev/null `" = "" ] )
then
	cloudhost="`/bin/echo ${CLOUDHOST} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^AS_SERVER_TYPE " ${quick_specification} | /bin/grep -w "${AS_SERVER_TYPE}" | /bin/grep ${cloudhost} 2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable AS_SERVER_TYPE (${AS_SERVER_TYPE}) doesn't appear to be valid please review"
	fi
fi

if ( [ "`/bin/grep "^WS_SERVER_TYPE " ${quick_specification} | /bin/grep -w "${WS_SERVER_TYPE}"  2>/dev/null `" = "" ] )
then
	cloudhost="`/bin/echo ${CLOUDHOST} | /usr/bin/tr '[:lower:]' '[:upper:]'`"
	if ( [ "`/bin/grep "^WS_SERVER_TYPE " ${quick_specification} | /bin/grep -w "${WS_SERVER_TYPE}" | /bin/grep ${cloudhost} 2>/dev/null `" = "" ] )
	then
		${log_command} "Your value for the variable WS_SERVER_TYPE (${WS_SERVER_TYPE}) doesn't appear to be valid please review"
	fi
fi

if ( [ "${AUTOSCALER_IMAGE_ID}" != "" ] || [ "${WEBSERVER_IMAGE_ID}" != "" ] || [ "${DATABASE_IMAGE_ID}" != "" ] )
then
  if ( [ "`/bin/echo ${BUILD_IDENTIFIER} | /bin/grep "^s-"`" = "" ] )
  then
    status "It look like you are performing a snapshot style build but your BUILD_IDENTIFIER is set to ${BUILD_IDENTIFIER}"
    status "A snapshot style build needs to have a BUILD_IDENTIFIER prefixed with the prefix 's-' so you need to set your BUILD_IDENTIFIER to s-${BUILD_IDENTIFIER}"
    exit
  fi
  if ( [ "${GENERATE_SNAPSHOTS}" = "1" ] )
  then
    status "It looks like you are trying to generate snapshots when you are building from snapshots, this is not possible"
  else
  	status "This build will be a snapshot style built off previously generated snapshot images (not a regular build style)"
  fi
else
	if ( [ "${GENERATE_SNAPSHOTS}" = "1" ] )
	then
		status "This build will be generating  snapshots of your machines"
	else
		status "This build will be a regular build style (not from snapshots)"
  	fi
fi

if ( [ "`/bin/echo ${BUILD_IDENTIFIER} | /bin/grep "^s-"`" = "" ] )
then
	snapshot_build_identifier="s-${BUILD_IDENTIFIER}"
	if ( [ -d ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${snapshot_build_identifier} ] )
 	then
  		status "A snapshot configuration is available for this build identifier (${BUILD_IDENTIFIER})"
    		status "This means you can't run a build for this exact build identifier (unless you delete/void the snapshot configuration ${snapshot_build_identifier})"
      		status "The snapshot configuration is located at: ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${snapshot_build_identifier} "
		exit
	fi
 fi

if ( [ "`/bin/grep "^MACHINE_TYPE " ${quick_specification} | /bin/grep -w "${MACHINE_TYPE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable MACHINE_TYPE (${MACHINE_TYPE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^ALGORITHM " ${quick_specification} | /bin/grep -w "${ALGORITHM}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable ALGORITHM (${ALGORITHM}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^INFRASTRUCTURE_REPOSITORY_PROVIDER " ${quick_specification} | /bin/grep -w "${INFRASTRUCTURE_REPOSITORY_PROVIDER}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable INFRASTRUCTURE_REPOSITORY_PROVIDER (${INFRASTRUCTURE_REPOSITORY_PROVIDER}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^DATASTORE_CHOICE " ${quick_specification} | /bin/grep -w "${DATASTORE_CHOICE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable DATASTORE_CHOICE (${DATASTORE_CHOICE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^BYPASS_DB_LAYER " ${quick_specification} | /bin/grep -w "${BYPASS_DB_LAYER}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable BYPASS_DB_LAYER (${BYPASS_DB_LAYER}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^SSL_GENERATION_METHOD " ${quick_specification} | /bin/grep -w "${SSL_GENERATION_METHOD}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable SSL_GENERATION_METHOD (${SSL_GENERATION_METHOD}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^SSL_GENERATION_SERVICE " ${quick_specification} | /bin/grep -w "${SSL_GENERATION_SERVICE}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable SSL_GENERATION)_SERVICE (${SSL_GENERATION_SERVICE}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^SSL_LIVE_CERT " ${quick_specification} | /bin/grep -w "${SSL_LIVE_CERT}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable SSL_LIVE_CERT (${SSL_LIVE_CERT}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^ACTIVE_FIREWALLS " ${quick_specification} | /bin/grep -w "${ACTIVE_FIREWALLS}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable ACTIVE_FIREWALLS (${ACTIVE_FIREWALLS}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^GENERATE_STATIC " ${quick_specification} | /bin/grep -w "${GENERATE_STATIC}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable GENERATE_STATIC (${GENERATE_STATIC}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/grep "^INSTALL_MONITORING_GEAR " ${quick_specification} | /bin/grep -w "${INSTALL_MONITORING_GEAR}"  2>/dev/null `" = "" ] )
then
	${log_command} "Your value for the variable INSTALL_MONITORING_GEAR (${INSTALL_MONITORING_GEAR}) doesn't appear to be valid please review"
fi

if ( [ "${APPLICATION}" = "joomla" ] && [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
then
   joomla_version="`/bin/echo ${JOOMLA_VERSION} | /bin/sed 's/\./-/g'`"
   joomla_major_version="`/bin/echo ${joomla_version} | /usr/bin/awk -F'-' '{print $1}'`"

	if ! /usr/bin/curl --head --silent --fail https://downloads.joomla.org/cms/joomla${joomla_major_version}/${joomla_version}/Joomla_${joomla_version}-Stable-Full_Package.zip 1>&2 >/dev/null 
	then
		${log_command} "I don't seem to be able to find a download link for the joomla version you are wanting to install (${JOOMLA_VERSION})"
	fi
	if ( [ "${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}" != "JOOMLA:${JOOMLA_VERSION}" ] )
	then
		${log_command} "Your value for variable APPLICATION_BASELINE_SOURCECODE_REPOSITORY (${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}) doesn't appear to be valid please review"
	fi
fi

if ( [ "${APPLICATION}" = "drupal" ] && [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
then
	if ! /usr/bin/curl --head --silent --fail https://ftp.drupal.org/files/projects/drupal-${DRUPAL_VERSION}.tar.gz 1>&2 >/dev/null
	then
		${log_command} "I don't seem to be able to find a download link for the drupal version you are wanting to install (${DRUPAL_VERSION})"
	fi
	if ( [ "${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}" != "DRUPAL:${DRUPAL_VERSION}" ] )
	then
		${log_command} "Your value for variable APPLICATION_BASELINE_SOURCECODE_REPOSITORY (${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}) doesn't appear to be valid please review"
	fi
fi

if ( [ "${APPLICATION}" = "moodle" ] && [ "${BUILD_ARCHIVE_CHOICE}" = "virgin" ] )
then
	if ( [ "${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}" != "MOODLE" ] )
	then
		${log_command} "Your value for variable APPLICATION_BASELINE_SOURCECODE_REPOSITORY (${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}) doesn't appear to be valid please review"
	fi
fi

if ( [ ! "`echo "${DNS_USERNAME}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] && [ ! "`/bin/echo "${DNS_USERNAME}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] )
then
	${log_command} "It looks to me like the email address for the variable DNS_USERNAME (${DNS_USERNAME}) doesn't appear to be valid please review"
fi

if ( [ ! "`echo "${SYSTEM_TOEMAIL_ADDRESS}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] && [ ! "`/bin/echo "${SYSTEM_TOEMAIL_ADDRESS}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] )
then
	${log_command} "It looks to me like the email address for the variable SYSTEM_TOEMAIL_ADDRESS (${SYSTEM_TOEMAIL_ADDRESS}) doesn't appear to be valid please review"
fi

if ( [ ! "`echo "${SYSTEM_FROMEMAIL_ADDRESS}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] && [ ! "`/bin/echo "${SYSTEM_FROMEMAIL_ADDRESS}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] )
then
	${log_command} "It looks to me like the email address for the variable SYSTEM_FROMEMAIL_ADDRESS (${SYSTEM_FROMEMAIL_ADDRESS}) doesn't appear to be valid please review"
fi

#Not all email usernames are email addresses that can be checked for but if you know that yours are then you can uncomment this check

#if ( [ ! "`echo "${SYSTEM_EMAIL_USERNAME}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] && [ ! "`/bin/echo "${SYSTEM_EMAIL_USERNAME}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] )
#then
#       ${log_command} "It looks to me like the email address for the variable SYSTEM_EMAIL_USERNAME (${SYSTEM_EMAIL_USERNAME}) doesn't appear to be valid please review"
#fi

if ( [ ! "`echo "${GIT_EMAIL_ADDRESS}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] && [ ! "`/bin/echo "${GIT_EMAIL_ADDRESS}" | grep '^[a-zA-Z0-9]*@[a-zA-Z0-9]*\.[a-zA-Z0-9]*\.[a-zA-Z0-9]*$'`" ] )
then
	${log_command} "It looks to me like the email address for the variable GIT_EMAIL_USERNAME (${GIT_EMAIL_ADDRESS}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/echo ${WEBSITE_URL} | /bin/grep -P '(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'`" = "" ] )
then
	${log_command} "It looks to me like the value for the variable WEBSITE_URL ${WEBSITE_URL}) doesn't appear to be valid please review"
fi

if ( [ "`/bin/echo ${WEBSITE_URL} | /usr/bin/awk -F'.' '{print $2}'`" != "${WEBSITE_NAME}" ] )
then
	${log_command} "It looks to me like the value for the variable WEBSITE_NAME (${WEBSITE_NAME}) doesn't appear to be valid please review"
fi

continents="`cd /usr/share/zoneinfo && /usr/bin/find * -type f -or -type l | /usr/bin/sort | /usr/bin/awk -F'/' '{print $1}' | /usr/bin/uniq | /bin/sed ':a;N;$!ba;s/\n/ /g'`"

if ( [ "`/bin/echo ${continents} | /bin/grep "${SERVER_TIMEZONE_CONTINENT}"`" = "" ] )
then
	${log_command} "It looks like your variable SERVER_TIMEZONE_CONTINENT ${SERVER_TIMEZONE_CONTINENT}) doesn't appear to be valid please review"
fi


cities="`cd /usr/share/zoneinfo/${SERVER_TIMEZONE_CONTINENT} && /usr/bin/find * -type f -or -type l | /usr/bin/sort`" 

if ( [ "`/bin/echo ${cities} | /bin/grep "${SERVER_TIMEZONE_CITY}"`" = "" ] )
then
	${log_command} "It looks like your variable SERVER_TIMEZONE_CITY (${SERVER_TIMEZONE_CITY}) doesn't appear to be valid please review"
fi

if ( [ "${BUILD_ARCHIVE_CHOICE}" = "baseline" ] )
then
	if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${BASELINE_DB_REPOSITORY}`" = "" ] )
	then
		${log_command} "I believe that the repository you have set for variable BASELINE_DB_REPOSITORY (${BASELINE_DB_REPOSITORY}) doesn't appear to be valid please review"
	fi
	if ( [ "`${BUILD_HOME}/providerscripts/git/GitLSRemote.sh ${APPLICATION_REPOSITORY_PROVIDER} ${APPLICATION_REPOSITORY_USERNAME} ${APPLICATION_REPOSITORY_PASSWORD} ${APPLICATION_REPOSITORY_OWNER} ${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}`" = "" ] )
	then
		${log_command} "I believe that the repository you have set for variable APPLICATION_BASELINE_SOURCECODE_REPOSITORY (${APPLICATION_BASELINE_SOURCECODE_REPOSITORY}) doesn't appear to be valid please review"
	fi
fi

if ( [ "${CLOUDHOST}" = "digitalocean" ] && [ "${DEFAULT_USER}" != "root" ] )
then
	${log_command} "It looks like your DEFAULT_USER is set to ${DEFAULT_USER} when it should be root"
fi

if ( [ "${CLOUDHOST}" = "exoscale" ]  && [ "${BUILDOS}" = "ubuntu" ] && [ "${DEFAULT_USER}" != "ubuntu" ] )
then
	${log_command} "It looks like your DEFAULT_USER is set to ${DEFAULT_USER} when it should be ubuntu"
fi

if ( [ "${CLOUDHOST}" = "exoscale" ]  && [ "${BUILDOS}" = "debian" ] && [ "${DEFAULT_USER}" != "debian" ] )
then
	${log_command} "It looks like your DEFAULT_USER is set to ${DEFAULT_USER} when it should be debian"
fi

if ( [ "${CLOUDHOST}" = "linode" ] && [ "${DEFAULT_USER}" != "root" ] )
then
	${log_command} "It looks like your DEFAULT_USER is set to ${DEFAULT_USER} when it should be root"
fi

if ( [ "${CLOUDHOST}" = "vultr" ] && [ "${DEFAULT_USER}" != "root" ] )
then
	${log_command} "It looks like your DEFAULT_USER is set to ${DEFAULT_USER} when it should be root"

fi

if ( ( [ "${CLOUDHOST}" = "linode" ] || [ "${CLOUDHOST}" = "exoscale" ] ) && [ "${CLOUDHOST_ACCOUNT_ID}" = "" ] )
then
	${log_command} "It looks like CLOUDHOST_ACCOUNT_ID is blank this should definitely not be the case for ${CLOUDHOST}"
fi

${log_command} "####################TEMPLATE VALIDATION REPORT ENDING####################"

${log_command} "Press <enter> when you have reviewed and accepted any messages that have appeared above (if there are none then you are all set already and just press enter)"

if ( [ "${HARDCORE}" != "1" ] )
then
	read x
fi
