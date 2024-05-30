#!/bin/sh
#########################################################################################
# Author : Peter Winter
# Date   : 13/07/2016
# Description : I don't mandate that the template has values for SMTP credentials set, so
# I ask for them here as a reminder and a prod that if they are not set then system emails
# will not be sent and to give the user the choice to enter them here.
# Any values entered here will overwrite any values set in the template
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

update="0"

if ( ( [ "${SYSTEM_EMAIL_USERNAME}" = "" ] || [ "${SYSTEM_EMAIL_PASSWORD}" = "" ] || [ "${SYSTEM_EMAIL_PROVIDER}" = "" ] || [ "${SYSTEM_TOEMAIL_ADDRESS}" = "" ] || [ "${SYSTEM_FROMEMAIL_ADDRESS}" = "" ] ) && [ "${HARDCORE}" != "1" ] )
then
	status ""
	status ""
	status "#############################################################################################################################################"
	status "You don't seem to have all the necessary SMTP settings configured. This is fine it just means that you system emails won't be sent"
	status "If you want to interactively setup system email capabilities here just enter 'Y' or 'y'"
	status "If you set up system email credentials here, the settings you give will override  and overwrite any settings that you have in your template"
	status "##############################################################################################################################################"
	status "Please enter 'Y' or 'y' if you want to provide SMTP credential settings anything else to leave well alone"
	read response
	if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
	then
		update="1"
	else
		update="0"
	fi
fi

if ( [ "${update}" = "1" ] && [ "${HARDCORE}" != "1" ] )
then
	status "You have chosen to override the email addresses on the fly rather than in your template for this build so now you must tell me what values you want to use"
	status "So, please enter the email address where you wish system messages to be sent"
	read SYSTEM_TOEMAIL_ADDRESS

	while ( [ "${SYSTEM_TOEMAIL_ADDRESS}" = "" ] || [ "`/bin/echo ${SYSTEM_TOEMAIL_ADDRESS} | /bin/grep -E "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"`" = "" ] )
	do
		status "That seems to be an invalid email address, please try again"
		read SYSTEM_TOEMAIL_ADDRESS
	done

	status "##################################################################################################################################"
	status "We also need to set up an SMTP provider to send the system status emails through"
	status "If you don't have an account with one of the supported smtp providers, please set one up first"
	status "Which SMTP provider are you registered with?"
	status "##################################################################################################################################"
	status "Currently, we support 1) SMTP Pulse (www.sendpulse.com) 2) Mailjet (mailjet.com) 3) Amazon (SES)"
	read SYSTEM_EMAIL_PROVIDER

	while ( [ "${SYSTEM_EMAIL_PROVIDER}" = "" ] || [ "`/bin/echo '1 2 3' | /bin/grep ${SYSTEM_EMAIL_PROVIDER}`" = "" ] )
	do
		status "Invalid choice, please try again"
		read SYSTEM_EMAIL_PROVIDER
	done

	status "Please enter 1) The Address you would like system emails to be sent from"
	read SYSTEM_FROMEMAIL_ADDRESS

	while ( [ "${SYSTEM_FROMEMAIL_ADDRESS}" = "" ] || [ "`/bin/echo ${SYSTEM_FROMEMAIL_ADDRESS} | /bin/grep -E "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"`" = "" ] )
	do
		status "That seems to be an invalid email address, please try again"
		read SYSTEM_FROMEMAIL_ADDRESS
	done

	status "Please enter your email address or username (api key for some providers) for your SMTP provider"
	read SYSTEM_EMAIL_USERNAME
	
	if ( [ "${SYSTEM_EMAIL_PROVIDER}" != "2" ] && [ "${SYSTEM_EMAIL_PROVIDER}" != "3" ] )
	then
		while ( [ "${SYSTEM_EMAIL_USERNAME}" = "" ] || [ "`/bin/echo ${SYSTEM_EMAIL_USERNAME} | /bin/grep -E "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$"`" = "" ] )
		do
			status "That seems to be an invalid email address, please try again"
			read SYSTEM_EMAIL_USERNAME
		done
	fi

	status "Please enter your password (secret key for some providers) for your SMTP provider"
	read SYSTEM_EMAIL_PASSWORD

	export SYSTEM_EMAIL_USERNAME="${SYSTEM_EMAIL_USERNAME}"
	export SYSTEM_EMAIL_PASSWORD="${SYSTEM_EMAIL_PASSWORD}"
	export SYSTEM_EMAIL_PROVIDER="${SYSTEM_EMAIL_PROVIDER}"
	export SYSTEM_TOEMAIL_ADDRESS="${SYSTEM_TOEMAIL_ADDRESS}"
	export SYSTEM_FROMEMAIL_ADDRESS="${SYSTEM_FROMEMAIL_ADDRESS}"

	/bin/echo ${SYSTEM_EMAIL_USERNAME} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SYSTEMEMAILUSERNAME.dat
	/bin/echo ${SYSTEM_EMAIL_PROVIDER} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SYSTEMEMAILPROVIDER.dat
	/bin/echo ${SYSTEM_TOEMAIL_ADDRESS} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/TOEMAILADDRESS.dat
	/bin/echo ${SYSTEM_FROMEMAIL_ADDRESS} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/FROMEMAILADDRESS.dat
	/bin/echo ${SYSTEM_EMAIL_PASSWORD} > ${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}-credentials/SYSTEMEMAILPASSWORD.dat
fi
