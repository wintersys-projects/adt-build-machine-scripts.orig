**NOTE:** 

If you use the native backup service from your cloudhost as well as regular and supersafe backups from this toolkit, you will have application backups in 3 places - your git provider, your datastore and your native backup with your cloudhost which you could recover your website using it if you had to. This should be pretty solid as a backup strategy. You don't have to use your cloudhost's backup service, it might cost £, but, if you want to go to the extreme with your backups, you can. You can also make manual backups to your build machine using the script: GenerateLocalBackups.sh


##### BACKUP PERIODICITY  

The backup periodicity is as follows:

##### hourly, daily, weekly, monthly, bimonthly, shutdown, manual and all  

What this means is that backups of the webroot and your database will be automatically taken at these different periodicities.

You can make a backup on from the build machine by runining the backup scripts from the build machine: 

**${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh**  

**${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh**  

There is a special periodicity available on the build machine which is "all" and when you select this, it will make a backup for all time based periodicities at once. 

---------------------------------------------------------------------------------------------------------

##### HOW TEMPORAL BACKUPS ARE MADE FROM CRON

The backups are created by calling the script

**${HOME}/cron/BackupFromCron.sh** on the webserver machine  

and  

**${HOME}/cron/BackupFromCron.sh** on the database machine 

You can generate backups directly from the command on your live machines as follows:  

**${HOME}/providerscripts/backupscripts/Backup.sh** on the webserver machine  

and  

**${HOME}/providerscripts/backupscripts/Backup.sh** on the database machine  

You pass in the build periodicity **"HOURLY", "DAILY", "WEEKLY", "MONTHLY", "BIMONTHLY", "SHUTDOWN" or "MANUAL"** and the **BUILD_IDENTIFIER** and that will then create a backup (including the necessary repository) with your git provider.  

---------------------------------------------------------------------------------------------------------

##### MANUAL and SHUTDOWN BACKUPS  

There are two special periodicities, "manual and shutdown".

The manual periodicity is such that you can use it if you were ever to need to generate an adhoc manual backup of your webroot and database from the command line. This gives you a way of creating an adhoc backup at any time you need without overwriting any of your standard time based periodicities. 

The shutdown periodicity is a special case such that if a webserver is being shutdown either through an autoscaling event or as part of a manual shutdown of the webservers, a backup is taken of the webroot of the webserver and labelled as the latest shutdown backup. This is just so there is a record of the state of that webserver at the time it was shutdown. 

A note on shutting down machines: If your website is in active use and you need to shut it down, then, you need to use the script:ShutdownInfrastructure.sh.
This is because users could be generating data which would be lost if you didn't. An alternative method is to put the website into maintenance mode using the CMS before you take it offline and allow a temporal backup to complete so that all data is captured. This would mean that you capture all user data but it would also mean that if you redeploy from a back that was made with the website in maintenance mode, then, the redeployment will be in maintenance mode also and you ill need to switch maintenance mode off before the redeployed application can be used. 

-------------------------------------------------------------------------------------------------------------

#####  IF THE ASSETS ARE STORED IN THE CLOUD THEY ARE NOT PART OF THE BACKUPS   
	
Its normal to set PERSIST_ASSETS_TO_CLOUD to 0 for baselines and virgin builds. This is because the cloud is only used to offload assets for a production build.
So ordinarily if your application users are going to be generating assets you want them to be stored in your datastore and distributed from there using a CDN (see elsewhere in this doco). Note, if your assets are stored in the cloud i.e. PERSIST_ASSETS_TO_CLOUD is set to 1, then, it is the only place where those assets are stored, there aren't any backups, so if you were to delete the assets from the bucket they are stored in by mistake, for example, it might hose your application. Therefore it is up to you to set up a backup policy for the assets that are stored in you S3 bucket. Its just a bucket with assets in it at the end of the day, so its not hard to make backups if you want to but some applications can generated GBs and GBs of assets and so can be hard to backup. Bottom line, be very cautious deleting assets that are stored in S3 because by default they are the only copy.  

-------------------------------------------------------------------------------------------------------------

##### SUPERSAFE BACKUPS  

The authoritative backups that are made for your application are stored in git repositories. However, if you switch on "super safe backups", then, a copy of your backups will also be written to your datastore. This gives you two sets of backups one in your git repositories and one in your datastore. This is common advise, backup and backup again. In other words, under normal operation within a week of running your website, you will have 2 hourly backups available, one with your git provider and one in your datastore, you will have 2 daily backups available, one with your git provider and one with your datastore and you will have 2 weekly backups available, one with your git provider and one with your datastore. This is quite a few backups which you can fall back on and, of course, the weekly backups will be a week old but losing a weeks worth is better than losing it entirely. Most likely you will want to have a native backup strategy with your cloudhost as well. If a backup is absent from the git repository for your chosen periodicity the toolkit looks for a backup in the datastore and uses that if it finds one. If you want even more backup security you could modify these scripts to generate nightly snapshots of your machines which you could always use to recover from using a "SNAPSHOT BUILD" style if you had to. 
