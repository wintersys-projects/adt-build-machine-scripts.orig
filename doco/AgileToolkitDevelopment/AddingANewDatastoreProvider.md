To add a new datastore manipulation tool such as rclone or s4cmd in addition to the s3cmd that the core supports you will need to modify or add to the following files:

>     adt-webserver-scripts/providerscripts/datastore/configwrapper
>     adt-webserver-scripts/providerscripts/datastore
>     adt-webserver-scripts/installscripts/InstallDatastoreTools.sh

>     adt-database-scripts/providerscripts/datastore
>     adt-database-scripts/installscripts/InstallDatastoreTools.sh

>     adt-build-machine-scripts/providerscripts/datastore
>     adt-build-machine-scripts/installscripts/InstallDatastoreTools.sh
>     adt-build-machine-scripts/initscripts/InitialiseDatastoreConfig.sh

>     adt-autoscaler-scripts/providerscripts/datastore
>     adt-autoscaler-scripts/providerscripts/datastore/ObtainBuildClientIP.sh
>     adt-autoscaler-scripts/providerscripts/datastore/InitialiseDatastoreConfig.sh
>     adt-autoscaler-scripts/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh
>     adt-build-machine-scripts/installscripts/InstallDatastoreTools.sh


