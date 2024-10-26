#### Adding a new application to the toolkit

The core supports joomla,wordpress,drupal and moodle. If you want to support further applications such as "NextCloud" and a whole host of other potential applications I believe you should be able to integrate support for any (php) application which follows a similar pattern by updating and modifying files in these directories or in the case of specific files particular files themselves.

>     adt-webserver-scripts/security/GatewayGuardian.sh
>     adt-webserver-scripts/providerscripts/webserver/configuration
>     adt-webserver-scripts/providerscripts/application/processing
>     adt-webserver-scripts/providerscripts/application/monitoring
>     adt-webserver-scripts/providerscripts/application/email
>     adt-webserver-scripts/providerscripts/application/configuration

>     adt-build-machine-scripts/providerscripts/application
>     adt-build-machine-scripts/processingscripts

>     adt-autoscaler-scripts/autoscaler/SelectHeadFile.sh

The most major part of the integration is likely to be adt-webserver-scripts/providerscripts/webserver/configuration and will most likely take the majority of your effort



