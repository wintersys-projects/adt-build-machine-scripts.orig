To support a new database engine type you will need to modify or add to the following files:

>      adt-webserver-scripts/ws.sh
>      adt-webserver-scripts/providerscripts/utilities/dbalive/
>      adt-webserver-scripts/providerscripts/utilities/InstallDatabaseClient.sh
>      adt-webserver-scripts/providerscripts/utilities/CheckServerAlive.sh

>      adt-database-scripts/security/ListAuthorisationIPs.sh
>      adt-database-scripts/security/GatewayGuardian.sh:
>      adt-database-scripts/providerscripts/utilities/ListAuthorisationIPs.sh
>      adt-database-scripts/providerscripts/utilities/IsDatabaseUp.sh
>      adt-database-scripts/providerscripts/utilities/EnsureAccessForWebservers.sh
>      adt-database-scripts/providerscripts/utilities/AccessDB.sh
>      adt-database-scripts/providerscripts/git/utilities/PlainDumpDatabase.sh
>      adt-database-scripts/providerscripts/database/singledb
>      adt-database-scripts/applicationdb
>      adt-database-scripts/applicationdb/InstallApplicationDB.sh

>      adt-build-machine-scripts/buildscripts/BuildAndDeployDBaaS.sh
