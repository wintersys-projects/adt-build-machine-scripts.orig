IMPORTANT: This system does not allow updates to configuration files (such as wp-config.php or configuration.php) through the application's GUI system.  

Instead use the following process which will automatically update all of your webserver configurations in one go:

If you want to update your, for example, Joomla "configuration.php" file or your Wordpress "wp-config.php" files, then there's a few ways to go about it.
Presuming that you have several webservers running if you change the configuration file on one of them it will get pushed out to all the others.

The shortcut way to update your application's configuration is as the following 3 step process:

1. Login to one of your webservers using the helperscript on your build machine
2. Go to ${HOME}/runtime and make your updates to the appropriate configuration file joomla_configuration.php, wordpress_config.php, drupal_settings.php, moodle_config.php
3. Once your updates are made to your configuration file run the script /usr/bin/config to push it to your S3 datastore. Syntax checking has to be passed before the changes you make are accepted by the system. 

WARNING RUNNING THIS SCRIPT WILL PUSH YOUR CHANGES TO ALL YOUR WEBSERVERS  

Configuration changes you make using the application's GUI system to an individual webserver will be overwritten by default. The reason for this is that when you have say 8 webservers running if you use the GUI system to make your configuration updates it will only update one of the webservers and the rest will remain as they were. You can't tell which webserver you have updated and which webserver you haven't. You could modify the scripts to make the configuration files in /var/www/html authoritative but I chose to make needed update changes to the ${HOME}/runtime/ the authoritative file instead and push them out from there in a conscious and deliberate way.   

The longer way to update the application configurations on your server fleet is as follows:

####  JOOMLA

1. Login to one of your webservers
2. Go to &#0036;HOME/runtime/joomla_configuration.php and edit the file (MAKING VERY SURE THAT THE CONFIGURATION IS CORRECT AS INCORRECT CONFIG WILL CRASH ALL YOUR SERVERS ONCE YOU PERFORM STEP 3)
3.
>      /usr/bin/run ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh &#0036;HOME/runtime/joomla_configuration.php joomla_configuration.php

The system wil then push out the updated config from S3 to any other running servers

####  WORDPRESS

1. Login to one of your webservers
2. Go to &#0036;HOME/runtime/wordpress_config.php and edit the file (MAKING VERY SURE THAT THE CONFIGURATION IS CORRECT AS INCORRECT CONFIG WILL CRASH ALL YOUR SERVERS ONCE YOU PERFORM STEP 3)
3.
>      /usr/bin/run ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh &#0036;HOME/runtime/wordpress_config.php wordpress_config.php

The system wil then push out the updated config from S3 to any other running servers

####  DRUPAL

1. Login to one of your webservers
2. Go to ${HOME}/runtime/drupal_settings.php and edit the file (MAKING VERY SURE THAT THE CONFIGURATION IS CORRECT AS INCORRECT CONFIG WILL CRASH ALL YOUR SERVERS ONCE YOU PERFORM STEP 3)
3.
>      /usr/bin/run ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh &#0036;HOME/runtime/drupal_settings.php drupal_settings.php

The system wil then push out the updated config from S3 to any other running servers

####  MOODLE

1. Login to one of your webservers
2. Go to ${HOME}/runtime/moodle_config.php and edit the file (MAKING VERY SURE THAT THE CONFIGURATION IS CORRECT AS INCORRECT CONFIG WILL CRASH ALL YOUR SERVERS ONCE YOU PERFORM STEP 3)
3.
>      /usr/bin/run &#0036;HOME/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh &#0036;HOME/runtime/moodle_config.php moodle_config.php

The system wil then push out the updated config from S3 to any other running servers




