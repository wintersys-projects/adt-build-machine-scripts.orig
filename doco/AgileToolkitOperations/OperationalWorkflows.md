To use this toolkit productively its necessary to understand the intended workflows. Here is an overview of how I would expect the workflows to operate in common scenarios.

#### Building and deploying your own custom application

1. The deployment in development mode of a virgin application such as joomla by configuring template 1 and running a build either using the expedited or the hardcore method
2. The customisation of the the virgin application (installing modules/components and plugins) that you have deployed in 1 until it meets your business need
3. Making a baseline of your completed application to a (private) repository by running on the build machine the

>     for the website baseline: ${BUILD_HOME}/helperscripts/PerformWebsiteBaseline.sh

>     for the website baseline: ${BUILD_HOME}/helperscripts/PerformDatabaseBaseline.sh

 4. Once you have a baselined application (once you make very sure that the database/webroot) do not contain any sensitive information you can either share that baseline with 3rd parties who have a similar business need or you can use it yourself. It is essential that you are very sure that your baselined application repositories do not contain any sensitive information before you make them public of you share them. If you aren't sure about this I would advise you not to share them.

5. If your intention is to use your new application in a production scenario for yourself then you will need to generate temporal backups of your application to preferably to both git repositories and your datastore as well. The way you generate your temporal backups is to run the following scripts on your build machine:

>     for the website temporal backup:  ${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh
>     for the database temporal backup: ${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh

6. You can then take your development servers offline and deploy in production mode by customising a template 3 to your needs complete with autoscaler provisioning and so on.

#### Deploying from Backups method

1. When you perform step 6 above you can choose to deploy using backups what this means it that when autoscaling webservers will be provisioned using a shortcut method in order to speed the process of proivisioning new webservers over and above buidling them from sratch and that is to take backup of the first webserver that is built using tar, store it in the datastore and overwrite a vanilla machine with the backup image from the datastore when you provision a webserver using scaling. This will make new webservers available and online quicker than the longer method of installing all the software from scratch. When a "build from backup" method is used, some adjustments are made to accomodate the fact that the archive is being extracted to a different machine than it was generated on (such as changed IP addresses have to be accounted for and so on, but, the scripts do that for you).

#### Deploying from autoscaler method

1. To deploy using snapshots you need to follow the above steps and then for step 6  you need to have the toolkit set to "GENERATE_SNAPSHOTS"
2. The build will run as for step 6 but the toolkit will generate snapshot images at the end of the build of your autoscaler, webserver and database.
3. Once the images are generated you need to take your machines offline (shut them down and destroy them) and then run the build process for step 6 again but this time using the "AUTOSCALE_FROM_SNAPSHOTS" option providing snapshot IDs and so on. The system will then build you your server fleet (and perform all future webserver builds) from the snapshot images that you generated. The scripts make some tweaks the the servers but you shouldn't need to worry about them. You should them have (possibly in a quicker time) your server and wesberver fleet online

These are the three basic build scenarios that I envision. You could call them "regular", "bakckup" and "snasphot" if you like.  

You need to be aware of the processes for SSL certificate renewal on long running webserver machines, the backup process works, how to connect to the machines using helperscripts, what firewalling is active in case there are ever connectivity issues (some provider's native firewalls do apply to machines communicating within a VPC and some provider's native firewalls don't). The UFW firewalling system allows (private) commuincation between all machines with the same VPC. 

   
