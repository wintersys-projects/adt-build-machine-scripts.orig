To support another cloudhost provider (for example, AWS, google cloud, OVH cloud and so on) you should be able to get it going by modfying the following files:

>     adt-webserver-scripts/security/SetupFirewall.sh
>     adt-webserver-scripts/security/SetupDNSFirewall.sh
>     adt-webserver-scripts/security/ObtainSSLCertificate.sh
>     adt-webserver-scripts/installscripts/InstallMonitoringGear.sh

>     adt-database-scripts/applicationdb/maria/InstallMariaDB.sh
>     adt-database-scripts/installscripts/InstallMonitoringGear.sh
>     adt-database-scripts/applicationdb/maria/InstallMariaDB.sh

>     adt-build-machine-scripts/selectionscripts/SelectCloudhost.sh
>     adt-build-machine-scripts/providerscripts/server/
>     adt-build-machine-scripts/providerscripts/security/
>     adt-build-machine-scripts/providerscripts/dns
>     adt-build-machine-scripts/providerscripts/datastore/configwrapper/DisplayCredentials.sh
>     adt-build-machine-scripts/providerscripts/cloudhost/
>     adt-build-machine-scripts/installscripts/InstallCloudhostTools.sh
>     adt-build-machine-scripts/helperscripts

>     adt-autoscaler-scripts/security/SetupFirewall.sh
>     adt-autoscaler-scripts/providerscripts/server/
>     adt-autoscaler-scripts/providerscripts/security/
>     adt-autoscaler-scripts/providerscripts/dns
>     adt-autoscaler-scripts/providerscripts/cloudhost
>     adt-autoscaler-scripts/installscripts/InstallMonitoringGear.sh
>     adt-autoscaler-scripts/installscripts/InstallCloudhostTools.sh

If you want to add a new cloudhost to your the toolkit you will need to configure a template with placeholders for your new cloudhost's CLI tool  
You can find examples here:  

>     ${BUILD_HOME}/initscripts/configfiles

This script wil then initialise your config file template by replacing placeholder values with live values

>     ${BUILD_HOME}/initscripts/InitialiseCloudhostConfig.sh


Its the same process on the autoscaler where you put your template in

>      ${HOME}/providerscripts/cloudhost/configfiles

and the script below will swap out the placeholders you have set for live values:

>     ${HOME}/providerscripts/cloudhost/InitialiseCloudhostConfig.sh

NOTE: originally the core supported AWS but I found I had to make various AWS specific customisations so I stripped AWS out of the core to keep the core as simple and consistent as possible. If you want to put the work in to add support for AWS, then, you might get some clues from my archived repositories which you can find below:  

[build-machine-with-aws](https://github.com/wintersys-projects/adt-build-machine-scripts-withaws)  
[autoscaler-with-aws](https://github.com/wintersys-projects/adt-autoscaler-scripts-withaws)  
[webserver-with-aws](https://github.com/wintersys-projects/adt-webserver-scripts-withaws)  
[database-with-aws](https://github.com/wintersys-projects/adt-database-scripts-withaws)  
