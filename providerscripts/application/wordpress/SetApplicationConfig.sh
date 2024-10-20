/bin/sed -i "/DB_HOST/c\ define('DB_HOST', \"${HOST}:${DB_PORT}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_USER/c\ define('DB_USER', \"${NAME}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_PASSWORD/c\ define('DB_PASSWORD', \"${PASSWORD}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/DB_NAME/c\ define('DB_NAME', \"${DATABASE}\");" ${HOME}/runtime/wordpress_config.php
/bin/sed -i "/\$table_prefix/c\ \$table_prefix=\"${dbprefix}\";" ${HOME}/runtime/wordpress_config.php


/bin/sed -i "/'AUTH_KEY'/i XXYYZZ" ${HOME}/runtime/wordpress_config.php
/bin/sed -i '/AUTH_KEY/,+7d' ${HOME}/runtime/wordpress_config.php
salts="`/usr/bin/curl https://api.wordpress.org/secret-key/1.1/salt`"
/bin/sed -n '/XXYYZZ/q;p' ${HOME}/runtime/wordpress_config.php > /tmp/firsthalf
/bin/sed '0,/^XXYYZZ$/d' ${HOME}/runtime/wordpress_config.php > /tmp/secondhalf
/bin/cat /tmp/firsthalf > /tmp/fullfile
/bin/echo ${salts} >> /tmp/fullfile
/bin/echo "/* SALTEDALREADY */" >> /tmp/fullfile
/bin/echo "define( 'DISALLOW_FILE_EDIT', true );" >> /tmp/fullfile
/bin/echo "define( 'WP_DEBUG', false );" >> /tmp/fullfile
/bin/echo "define('WP_CACHE', false);" >> /tmp/fullfile
/bin/echo "define('CONCATENATE_SCRIPTS', true);" >> /tmp/fullfile
/bin/echo "define('COMPRESS_SCRIPTS', true);" >> /tmp/fullfile
/bin/echo "define('COMPRESS_CSS', true);" >> /tmp/fullfile
/bin/echo "define('DISABLE_WP_CRON', true);" >> /tmp/fullfile
/bin/cat /tmp/secondhalf >> /tmp/fullfile
/bin/rm /tmp/firsthalf /tmp/secondhalf
/bin/mv /tmp/fullfile ${HOME}/runtime/wordpress_config.php

