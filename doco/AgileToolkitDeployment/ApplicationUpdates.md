No doubt the CMS system you have deployed as well as the components, plugins and modules that you have installed will require updating and this is the way to do it.  
Most likely at a time when your website is least busy. This can seem a bit round the houses but once you have it nailed, its not to much of a song and dance. So, to perform application updates on a live site, follow these steps:  

##### BEFORE DOING ANYTHING MAKE SURE YOU HAVE GOT WORKING BACKUPS OF YOUR WEBSITE. YOU MIGHT WANT TO SIMPLY RENAME YOUR HOURLY BACKUPS FOR YOUR WEBROOT AND DATABASE WITH A .orig or .working DIRECTLY USING YOUR GIT PROVIDER'S GUI SO THAT THEY ARE NOT OVERWRITTEN BY THIS PROCESS AND YOU CAN ROLL BACK TO THEM IF SOMETHING GOES WRONG**

1. Put your website into maintenance mode following [this](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/doco/AgileToolkitDeployment/ApplicationConfigurationUpdate.md) process to update configurations. Your visitors should then see "Maintenance mode - come back later"

2. Switch your deployment infrastructure into maintenance mode

>      cd ${BUILD_HOME}/helperscripts  
>      /bin/sh ./ExecuteOnAutoscaler.sh MAINTENANCE_MODE_ON

This will put a flag into the datastore which the autoscalers will pick up on and scale down to 1 machine. Be aware of the time when you are making updates with the knowledge that backups are made on or around the hour with a gap of minutes between when the database is backed up and when the webroot is backed up which could lead to incosnistencies when you are making upgrades such as an upgraded sourcecode and an older database schema. You can either disable backups whilst you are upgrading your website or be mindful of them. To disable backups on the one webserver and the one database that you now have running, go to your webserver and your database and comment out the appropriate backup script call in cron. 

3. Once you have made your maintence updates to your website, thoroughly test your website is operating as expected and then either manually generate temporal backups of your application webroot using "PerformWebsiteBackup.sh" (there is a parameter for making manual backups) or wait for hourly backups to be made by the system. If you are going to scaleup again after you have done the maintenance, then you must have an appropriate (and updated) temporal backup for your new webservers to build off which you can now do by running:

>      cd ${BUILD_HOME}/helperscripts  
>      /bin/sh ./PerformWebsiteBackup.sh

>      cd ${BUILD_HOME}/helperscripts  
>      /bin/sh ./PerformDatabaseBackup.sh

4. Check the integrity of the backups. CheckApplicationRepositoryIntegrity.sh

5. Switch maintenance mode off from the build machine

>      cd ${BUILD_HOME}/helperscripts  
>      /bin/sh ./ExecuteOnAutoscaler.sh MAINTENANCE_MODE_OFF 

6. Your website will then scale up to the number of webservers it is set to scale to when in full operation using your new temporal backup to build from

7. Take your CMS out of maintenance mode using the administration panel of the CMS itself. 

8. Your site should then be online and ready for visitors again. 
