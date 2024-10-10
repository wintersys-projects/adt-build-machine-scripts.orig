**YOU MUST HAVE THE MACHINES STILL RUNNING FROM THE PREVIOUS [TUTORIAL](./expedited-baseline-joomla.md) TO COMPLETE THIS TUTORIAL SUCCESSFULLY**

On your build machine, you need to now make hourly periodicity temporal backups of your application sourcecode and your application database. In summary you do this as follows and if you are following this tutorial closely you might need to change your "application github" repos/credentials in the file

>     ${HOME}/.ssh/webserver_configuration_settings.dat and
>     ${HOME}/.ssh/database_configuration_settings.dat

to be something different to the demo repos from the baseline tutorial:

On your build machine, you need to now make temporal backups of your application sourcecode and your application database.
You do this as follows:

>     cd /home/<your username>/adt-build-machine-scripts/helperscripts

Then perform a temporal database backup
  
>     /bin/sh PerformDatabaseBackup.sh
 
Answering all of the questions and picking a periodicity, for example, HOURLY (make sure DISABLE_HOURLY=0) in your template
  
Then perform a temporal website sourcecode backup
  
>     /bin/sh PerformWebsiteBackup.sh
  
Making sure you pick the same periodicity as for the temporal database backup, for example, "HOURLY"
  
What we are then interested in is template 3 which is at:
  
>     /home/wintersys-projects/adt-build-machine-scripts/templatedconfigurations/templates/linode/linode3.tmpl
  
I can extract the values for the following variables from template 1 or template 2 which I used in the previous tutorial and set them in template 3, replace these with your own live values:

>     export S3_ACCESS_KEY="BBBBB"  #MANDATORY
>     export S3_SECRET_KEY="CCCCC"  #MANDATORY
>     export TOKEN="XXXXX"   #MANDATORY
>     export DNS_USERNAME="testemail@testemail.com"  #MANDATORY
>     export DNS_SECURITY_KEY="BBBBB:CCCCC"   #MANDATORY - This is your access key and your secret key, written: DNS_SECURITY_KEY="${ACCESS_KEY}:${SECRET_KEY}"
>     export CLOUDHOST_EMAIL_ADDRESS="testemail@testemail.com" #MANDATORY
>     export WEBSITE_DISPLAY_NAME="Test Social Network" #MANDATORY
>     export WEBSITE_NAME="testdeploy" #MANDATORY - This is the exact value of the core of your WEBSITE_URL, for example, www.nuocial.org.uk would be nuocial
>     export WEBSITE_URL="www.testdeploy.com"  #MANDATORY
>     export APPLICATION_REPOSITORY_OWNER="yourgithubuser" #MANDATORY
>     export APPLICATION_REPOSITORY_USERNAME="yourgithubuser" #MANDATORY
>     export APPLICATION_REPOSITORY_PASSWORD="KKKKK" #MANDATORY
>     export APPLICATION_REPOSITORY_TOKEN="KKKKK" #MANDATORY
>     export CLOUDHOST_PASSWORD="kwshf934^Gyd£"  
  
What I then do is adjust  

**/home/wintersys-projects/adt-build-machine-scripts/templatedconfigurations/templates/linode/linode3.tmpl**  
  
to contain these values instead of its defaults.
  
I then need to set the template to use the temporal backups that I have generated and I do that by setting these values in template3:
  
>     export APPLICATION="joomla" #MANDATORY (joomla or wordpress or drupal or moodle)
>     export BUILD_CHOICE="2" #MANDATORY 2=hourly, 3=daily, 4=weekly, 5=monthly, 6=bimonthly
>     export BUILD_ARCHIVE_CHOICE="hourly" #MANDATORY hourly, daily, weekly, monthly, bimonthly
>     export PERSIST_ASSETS_TO_CLOUD="1" #MANDATORY This should only be 0 if your application has a very small number of assets
>     export DIRECTORIES_TO_MOUNT="images" #MANDATORY - this will define which directories in your webroot will be mounted from S3, if PERSIST_ASSETS_TO_CLOUD=1
  
Shutdown any webservers that you have running from tutorial 2 and you are then ready to perform a temporal build, as shown below:
  
[![Linode baseline Joomla Deployment Using the Agile Deployment Toolkit](https://img.youtube.com/vi/NvH6z9NBwlY/0.jpg)](https://www.youtube.com/watch?v=NvH6z9NBwlY)
  
  If all has gone according to plan, you will have seen a full deployment of your temporal backup. 
  
  ------------------------
  **DEPLOYMENT USING MANAGED DATABASES**
  
  There's something else to be aware of, if you want to deploy a managed DBaaS system instead of just using the one that is built in to the build process you can do that as detailed in [this](../../../doco/AgileToolkitDeployment/DeployingDBaaS.md) document
  
  ------------------------
  **DEPLOYMENT USING SNAPSHOTS**
  
  You can also build your webservers using snapshots that you generate and then use. You can read about how to perform snapshot builds [here](../../../doco/AgileToolkitDeployment/SnapshotsWorkflow.md).
  
  ------------------------
  **OTHER APPLICATION TYPES**
  
In order to do a temporaly build from backups you have made for a different application type (wordpress, drupal or moodle) you will need to alter the following variables in your template compared to what you have used above:
  
  For Wordpress:
  
>     export APPLICATION="wordpress"
>     export DIRECTORIES_TO_MOUNT="wp-content.uploads"
  
  For Drupal:
  
>     export APPLICATION="drupal"
>     export DIRECTORIES_TO_MOUNT="sites.default.files"
  
  For Moodle:
  
>     export APPLICATION="moodle"
>     export DIRECTORIES_TO_MOUNT="moodledata.filedir"
