----------------------
#### IT IS A BIT MORE EFFORT TO GET A HARDCORE BUILD COMPLETED, BUT, ONCE IT IS DONE YOU WILL HAVE A STACKSCRIPT WHICH YOU CAN CONFIGURE DIRECTLY AND REPEATEDLY FOR YOUR USES
----------------------   

**YOU MUST HAVE THE MACHINES STILL RUNNING FROM THE PREVIOUS TUTORIAL TO COMPLETE THIS TUTORIAL SUCCESSFULLY**

On your build machine, you need to now make hourly periodicity temporal backups of your application sourcecode and your application database. In summary you do this as follows and if you are following this tutorial closely you might need to change your "application github" repos/credentials in the file

>     ${HOME}/.ssh/webserver_configuration_settings.dat and
>     ${HOME}/.ssh/database_configuration_settings.dat

to be something different to the demo repos from the baseline tutorial:

>     cd /home/<your username>/adt-build-machine-scripts/helperscripts

Then perform a temporal database backup
  
>     /bin/sh PerformDatabaseBackup.sh
 
Answering all of the questions and picking a periodicity, for example, HOURLY in your template
  
Then perform a temporal website sourcecode backup
  
>     /bin/sh PerformWebsiteBackup.sh
  
Making sure you pick the same periodicity as for the temporal database backup, for example, "HOURLY"
  
What we are then interested in is template 3 which is at:
  
>     /home/wintersys-projects/adt-build-machine-scripts/templatedconfigurations/templates/linode/linode3.tmpl
  
I can extract the values for the following variables from template 1 or template 2 which I used in the previous tutorial and set them in template 3, replace these with your own live values:

>     export S3_ACCESS_KEY="BBBBB"  #MANDATORY
>     export S3_SECRET_KEY="CCCCC"  #MANDATORY
>     export TOKEN="AAAAA"   #MANDATORY
>     export DNS_USERNAME="testemail@testemail.com"  #MANDATORY
>     export DNS_SECURITY_KEY="AAAAA"   #MANDATORY  #MANDATORY
>     export CLOUDHOST_EMAIL_ADDRESS="testemail@testemail.com" #MANDATORY
>     export WEBSITE_DISPLAY_NAME="Test Social Network" #MANDATORY
>     export WEBSITE_NAME="testdeploy" #MANDATORY - This is the exact value of the core of your WEBSITE_URL, for example, www.nuocial.org.uk would be nuocial
>     export WEBSITE_URL="www.testdeploy.com"  #MANDATORY
>     export APPLICATION_REPOSITORY_OWNER="yourgithubuser" #MANDATORY
>     export APPLICATION_REPOSITORY_USERNAME="yourgithubuser" #MANDATORY
>     export APPLICATION_REPOSITORY_PASSWORD="KKKKK" #MANDATORY
>     export APPLICATION_REPOSITORY_TOKEN="KKKKK" #MANDATORY
  
What I then do is adjust  

>     /home/wintersys-projects/adt-build-machine-scripts/templatedconfigurations/templates/linode/linode3.tmpl  
  
to contain these values instead of its defaults.
  
I then need to set the template to use the temporal backups that I have generated and I do that by setting these values in template3:
  
>     export APPLICATION="joomla" #MANDATORY (joomla or wordpress or drupal or moodle)
>     export BUILD_CHOICE="2" #MANDATORY 2=hourly, 3=daily, 4=weekly, 5=monthly, 6=bimonthly
>     export BUILD_ARCHIVE_CHOICE="hourly" #MANDATORY hourly, daily, weekly, monthly, bimonthly
>     export PERSIST_ASSETS_TO_CLOUD="1" #MANDATORY This should only be 0 if your application has a very small number of assets
>     export DIRECTORIES_TO_MOUNT="images" #MANDATORY - this will define which directories in your webroot will be mounted from S3, if PERSIST_ASSETS_TO_CLOUD=1
  
Shutdown any webservers that you have running from tutorial 2 and you are then ready to perform a temporal build, as shown below:
  
**FOLLOW THESE STEPS ON YOUR LAPTOP IF YOU DON'T HAVE A BUILD SERVER RUNNING**

You now need to copy your template as follows on your laptop:  

>     /bin/cp ./adt-build-machine-scripts/templatedconfigurations/templates/linode/linode2.tmpl ./adt-build-machine-scripts/overridescripts/linode2override.tmpl  

Then you need to run the script:

>     cd helperscripts

>     ./GenerateOverrideTemplate.sh (Make sure you review and set all values)

With Linode you can either use a StackScript or userdata (limited regional and OS availability currently) to spin up your machines. In both cases you need to generate a different script. With Linode you have two choices you can either deploy from a Stackscript or you can deploy using the matadata service. 

**Stackscript**

>     ./GenerateHardcoreUserDataScript.sh stack

This will leave you with a script:

>    ../userdatascripts/${userdatascript}   

where ${userdatascript} is the descriptive name you gave when prompted.  

This is a Stack Script - if you don't understand Stack Scripts you can read:  

[Stack Script Tutorial](https://www.linode.com/docs/guides/writing-scripts-for-use-with-linode-stackscripts-a-tutorial/).  

**You need to:**  

1. take a copy of the userdata script (the whole thing) by copying it and pasting it to create a Stack Script out of it. 
2. You then need to populate the main variables and modify (if you need to, the advanced ones) of the Stack Script as you ususally would. 
3. You then need to create a linode from your Stack Script.

**Metadata Service**

>     ./GenerateHardcoreUserDataScript.sh 

This will leave you with a script:

>    ../userdatascripts/${userdatascript}   

where ${userdatascript} is the descriptive name you gave when prompted.  

You will need to enter values to suit your deployment into the userdatascript for:

>     export BUILDMACHINE_USER="agile-user"
>     export BUILDMACHINE_PASSWORD="Hjdhfb34hd£" #Make sure any password you choose is strong enough to pass any strength enforcement rules of your OS
>     export BUILDMACHINE_SSH_PORT="1035"
>     export LAPTOP_IP="111.111.111.111"

>     export SSH=\"\" #paste your public key here
>     export SELECTED_TEMPLATE="3"

This will give you a script which you can post into the userdata script of a linode - the linode that you are deploying as your new build machine. So basically configure a vanilla linode and paste the userdata script into the userdata area of the linode to spin up your the build machine for your deployment.

At this point, you can deploy your build machine should be up and running in short order. Please then review 
  
[Tighten Build Machine](../../../doco/AgileToolkitDeployment/TightenBuildMachineAccess.md) 
 
At this point, your build machine will only accept connections from your laptop. If you need access from other ip addresses you need to use the technique described in "Tightening Build Machine Access" to grant access to additional IP addresses. This will be the case every time your laptop changes its IP address as you travel about, so, you might want to setup and configure an S3 client on your laptop to enable you to grant access to new IP addresses easily. 
  
