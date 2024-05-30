1. To perform an expedited build you need to grab a copy of the script [here](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/templatedconfigurations/templateoverrides/OverrideScript.sh)

2. You can keep your copy of this script on your laptop (the first build you do is much more longwinded than subsequent ones where you can just copy and paste configurations you have already set up) and you need to set the following settings in it before the build can proceed:

>     BUILDMACHINE_USER="agile-deployer"
>     BUILDMACHINE_PASSWORD="Hjdhfb34hd£"
>     BUILDMACHINE_SSH_PORT="1035"
>     LAPTOP_IP="111.111.111.111"
>     SSH="\<your ssh public key here\>"- generate a new keypair according to if you haven't got a keypair already
>     SELECTED_TEMPLATE="3" - only need to set this if you are following this as part of a "hardcore" build process

To generate a new keypair you can follow: [keygen](https://www.ssh.com/academy/ssh/keygen)  

3. Now paste the modified script into the cloud-init portion of a new VPS machine of your chosen cloudhost provider and this machine will become your new build machine so you might want to name it accordingly through the GUI system

4. In a couple of minutes your machine should be online and you can ssh into it, something like:

>     ssh -p 1035 agile-deployer@<machine_ip_address>

   and you will see a directory

>     adt-build-machine-scripts

   and this means that this toolkit is available on the machine

5. You should then use the firewalling system of your cloudhost provider to disallow access to your new build machine to all IP addresses and all ports except the IP address of your laptop and the SSH port you are using (in this case 1035). If your latop IP address changes you will need to allow access to the new IP address through the native firewalling system of your cloudhost provider. You could bypass this step because UFW will still be setup on your buildmachine but to be very tight about things you should have your native firewall setup as well because this build-machine will have some goodies on it that you don't want to give away to easily.

6. What you now need to so is setup your template for which you must pick the appropriate one from here on your new machine:

>     ${BUILD_HOME}/templatedconfiguration/templates/<provider>

7. Each default template has some fields marked **MANDATORY** these fields are the minimum set of fields which you must provide values to for your build process to have any chance of succeeding. If you don't provide a suffficient set of **valid** values, then, you should be warned about it as you try to start the build. If you want to study some of the possible behaviours that your template can be configured for have a look [here](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/doco/AgileToolkitOperations/TemplateConfigurationsBehaviours.md)

8. Once you are happy that your template is configured correctly you can start the build by running the following script:

>     ${BUILD_HOME}/ExpeditedAgileDeploymentToolkit.sh  

9. When you run this toolkit it will follow several prebuild steps to make sure that it has everything that the build process needs in order to proceed. The main steps that the script needs to run through needs to complete successfully before the build can begin are:

- Make sure the needed software is up to date and installed  
- Select the cloudhost that you are deploying to (this overrides any values you set in the template when you deploy using the Expedited method)  
- Load the values you have set in your template into memory for use in the build process (including soft errors you can act on if the template has values are considered erroneous)
- Configure the cloudhost CLI tools that you will be using for the build this involves reading a cloudhost cli template file and replacing placeholder values with live values from the template. The cloudhost cli template file is stored at:
     
>     ${BUILD_HOME}/initscripts/configfiles

- Checking if you want to set SMTP settings for system emails if the values aren't set in your template  
- Initialise the configuration file for the CLI tool you are using to access your S3 datastore (currently only s3cmd). This config file is also located at
     
>     ${BUILD_HOME}/initscripts/configfiles
     
- Find out what type of application you are deploying by interrogating the application sourcecode and looking for indicators based on file structure as to which application type it it  
- Setup/create the native firewalls but don't add any rules or machines to them machines to them.  
- Insitialise the SSH security keys so that we can SSH onto our machines using a known BUILD_KEY public/private pair  
- If we believe that the build machine is in the same VPC as our new servers will be check that it is and if it isn't add it to the VPC to be sure  
- Generate the SSL certificate for your webserver and securely copy it to the S3 datastore where it can be obtained by any of our main server machines (webservers basically)  
   
10. When you begin a build with this buildkit it will expect you to have selected a build chain in the file by setting a value for BUILDCHAINTYPE: <br> <br>

>     ${BUILD_HOME}/builddescriptors/buildstylesscp.dat  

   If you have selected the "standard" build chain time which you most probabaly have then for production mode the build process will build autoscaler(s), webserver and database machines by calling the files  

>     ${BUILD_HOME}/buildscripts/BuildAutoscaler.sh  
>     ${BUILD_HOME}/buildscripts/BuildWebserver.sh  
>     ${BUILD_HOME}/buildscripts/BuildDatabase.sh  

   If you are building for DEVELOPMENT rather than production only a webserver and a database will be built  

11. Once the build kit considers these machines to have been fully built a finalisation process takes place which ensures that the servers are ready for use. The finalisation process involves the exchange of configuration details making sure that each machine type has claimed to have built correctly and also that the connection to the database from the webserver is established and operational. After all of this has taken place the native firewall has rules added to it suitable for our needs (as tight as possible basically) and each of the machines we have built are added to the native firewall if our template is configured to require the use of a native firewall.

12. Once the machines have built, you will get a message saying that tbe build was successful together with, possibly, some pertinent information that you might need to interact with your application. Once the build is complete you can interact with each of your machines using the scripts in the

>     ${BUILD_HOME}/helperscripts  

   directory. You can login to your machines and have a nose around to see what is going on.  

   Once you are on a machine (you have authenticated to it using the correct SSH Key as obtained by the helperscript you have used, you can become root as follows:  

>     cd ${HOME}/super/  
>     /bin/sh ./Super.sh  

   You will then be root because having the correct key to login to the machine is considered strong authentication. root user logins are disabled and password based logins are disabled also.  

   13. The machines work by having scripts run from cron on a regular basis to either initiate a scaling process on an autoscaler a backup process on a webserver or database processes to do with the firewall and application configuration and so on. If you want to find out what the machines are doing the advice is to studu what is configured in cron which you can do by tying
  
>     crontab -e  

   14. The configuration files that are representations of the values that you either entered into your template or added interactively during an expedited build process are stored in the directory:
  
>     ${HOME}/.ssh  

   I chose this directory because these configuration files were copied here using SSH so it reminds us that they have come from the build-machine  

   The scripts regularly interrogate these configuration files to see what they need to be doing in order to go about their business. For example, if a backup script is making a backup to your (definitely should be private) github application repository then the script will look in this ssh directory for the username and authentication token for your github account which you will have set in your template. Obviously your template has to contain accurate and valid information for the toolkit to be able to work properly.  

   15. Another interesting directory on each of the machines is

>     ${HOME}/runtime

   This directory basically contains information that the scripts are generating as they go about their business.

   16. You can find and examine the rest of the sourcecode for this toolkit by looking in the ${HOME} directory
     
   17. A webserver may be configured to mount its "dynamic assets" directory (the images folder for example in joomla) from a bucket in your datastore. This gives a very large amount of "space" for dynamic assets to be stored but by default the bucket they are stored in is the only source of truth for those assets so you might want to set up a process that makes backups of that bucket because if you have a problem and can't access that bucket for some reason (failures do happen) it might hose your whole application. The tool I use by default for mounting the assets directory to all of the n webservers that I am running is s3fs but other tools are available.
     
   18. On the autoscaler(s) machines are scaled according to scaling requirements which can be set by running:
     
>     ${BUILD_HOME}/helperscripts/AdjustScaling.sh  

   When a machine is built in response to a scaling requirement it can be built as a regular build, a build from snasphot build, or a build from backup build  

   19. With the database machine the database can either we run locally on this machine (only recommended during development) or you can run a DBaaS instance remotely (most probably with the same VPC) in which case the database machine won't be accessed by the webservers but rather will be used to perform backups and installation to the DBaaS database by performing the functions it would usually perform for its own locally running database but for the remote DBaaS database instead.



