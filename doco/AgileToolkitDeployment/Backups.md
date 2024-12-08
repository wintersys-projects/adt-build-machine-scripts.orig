**NOTE:** 

You can also use your cloudhost#s backup service to make backups of your machines if you want super safe backups above and beyond what is provided here. 

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


-------------------------------------------------------------------------------------------------------------

#####  IF THE ASSETS ARE STORED IN THE CLOUD THEY ARE NOT PART OF THE BACKUPS   
	
Its normal to set PERSIST_ASSETS_TO_CLOUD to 0 for baselines and virgin builds. This is because the cloud is only used to offload assets for a production build.
So ordinarily if your application users are going to be generating assets you want them to be stored in your datastore and distributed from there using a CDN (see elsewhere in this doco). Note, if your assets are stored in the cloud i.e. PERSIST_ASSETS_TO_CLOUD is set to 1, then, it is the only place where those assets are stored, there aren't any backups, so if you were to delete the assets from the bucket they are stored in by mistake, for example, it might hose your application. Therefore it is up to you to set up a backup policy for the assets that are stored in you S3 bucket. Its just a bucket with assets in it at the end of the day, so its not hard to make backups if you want to but some applications can generated GBs and GBs of assets and so can be hard to backup. Bottom line, be very cautious deleting assets that are stored in S3 because by default they are the only copy.  

