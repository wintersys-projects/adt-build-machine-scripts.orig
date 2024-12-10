#!/bin/sh
####################################################################################
# Description: This sets the bare minimum configuration.php values to get the joomla
# application online
# Date: 07/11/2024
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
 
#dbprefix="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} DBPREFIX:* | /usr/bin/awk -F':' '{print $NF}'`"
#secret="`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} SECRET:*  | /usr/bin/awk -F':' '{print $NF}'`"

if ( [ ! -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/dbp.dat ] )
then
 status "Error, cannot find database prefix file"
fi

dbprefix="`/bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/dbp.dat`"
secret="`/usr/bin/openssl rand -base64 32 | /usr/bin/tr -cd 'a-zA-Z0-9' | /usr/bin/cut -b 1-16 | /usr/bin/tr '[:upper:]' '[:lower:]'`"

/bin/sed -i "/\$dbprefix /c\        public \$dbprefix = \'${dbprefix}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$secret /c\        public \$secret = \'${secret}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$user/c\       public \$user = \'${database_username}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$password/c\   public \$password = \'${database_password}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$db /c\        public \$db = \'${database_name}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default

if ( [ "${DATABASE_INSTALLATION_TYPE}" = "Postgres" ] || ( [ "${DATABASE_INSTALLATION_TYPE}" = "DBaaS" ] && [ "`/bin/echo ${DATABASE_DBaaS_INSTALLATION_TYPE} | /bin/grep 'Postgres'`" != "" ] ) )
then
        /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'pgsql\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
        /bin/sed -i "/\$port /d" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
        /bin/sed -i "/\$host /c\        public \$host = \'${database_identifier}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
        /bin/sed -i "/\$host /a        public \$port = \'${DB_PORT}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
else
 /bin/sed -i "/\$dbtype /c\        public \$dbtype = \'mysqli\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
 /bin/sed -i "/\$host = /c\   public \$host = \'${database_identifier}:${DB_PORT}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
fi


/bin/sed -i "/\$cachetime /c\        public \$cachetime = \'30\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$cache_handler /c\        public \$cache_handler = \'file\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$caching /c\        public \$caching = \'1\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$sef /c\        public \$sef = \'0\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$sef_suffix /c\        public \$sef_suffix = \'0\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$sef_rewrite /c\        public \$sef_rewrite = \'0\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$gzip /c\        public \$gzip = \'1\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$force_ssl /c\        public \$force_ssl = \'2\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$shared_session /c\        public \$shared_session = \'0\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$tmp_path /c\        public \$tmp_path = \'/var/www/html/tmp\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$log_path /c\        public \$log_path = \'/var/www/html/logs\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default

/bin/sed -i "/\$mailer /c\        public \$mailer = \'smtp\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$mailfrom /c\        public \$mailfrom = \'${SYSTEM_FROMEMAIL_ADDRESS}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$replyto /c\        public \$replyto = \'${SYSTEM_TOEMAIL_ADDRESS}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$fromname /c\        public \$fromname = \'${WEBSITE_NAME} Webmaster\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$replytoname /c\        public \$replytoname = \'${WEBSITE_NAME} Webmaster\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$smtpauth /c\        public \$smtpauth = \'1\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$smtpuser /c\        public \$smtpuser = \'${SYSTEM_EMAIL_USERNAME}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$smtppass /c\        public \$smtppass = \'${SYSTEM_EMAIL_PASSWORD}\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
/bin/sed -i "/\$smtpsecure /c\        public \$smtpsecure = \'tls\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default

if ( [ "${SYSTEM_EMAIL_PROVIDER}" = "1" ] )
then
        /bin/sed -i "/\$smtpport /c\        public \$smtpport = \'2525\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
        /bin/sed -i "/\$smtphost /c\        public \$smtphost = \'smtp-pulse.com\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
elif ( [ "${SYSTEM_EMAIL_PROVIDER}" = "2" ] )
then
        /bin/sed -i "/\$smtpport /c\        public \$smtpport = \'587\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
        /bin/sed -i "/\$smtphost /c\        public \$smtphost = \'in-v3.mailjet.com\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
elif ( [ "${SYSTEM_EMAIL_PROVIDER}" = "3" ] )
then
        /bin/sed -i "/\$smtpport /c\        public \$smtpport = \'587\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
        /bin/sed -i "/\$smtphost /c\        public \$smtphost = \'email-smtp.eu-west-1.amazonaws.com\';" ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default
fi

${BUILD_HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${WEBSITE_URL} ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/configuration.php.default joomla_configuration.php

if ( [ "`${BUILD_HOME}/providerscripts/datastore/configwrapper/ListFromConfigDatastore.sh ${WEBSITE_URL} joomla_configuration.php`" = "" ] )
then
 status "Didn't generate the joomla configuration file in the config datastore, this will cause trouble later"
fi
