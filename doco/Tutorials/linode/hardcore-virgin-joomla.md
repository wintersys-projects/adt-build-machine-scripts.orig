
----------------------
#### IT IS A BIT MORE EFFORT TO GET A HARDCORE BUILD COMPLETED, BUT, ONCE IT IS DONE YOU WILL HAVE A STACKSCRIPT WHICH YOU CAN CONFIGURE DIRECTLY AND REPEATEDLY FOR YOUR USES
----------------------  

**HARDCORE BUILD PROCESS**

1. On your laptop perform the following command:  

>     git clone https://github.com/wintersys-projects/adt-build-machine-scripts.git

We need several pieces of information from our cloud host and 3rd party services for a successful build to be possible:

I am going to use the example of joomla to build from and so this example will build a virgin installation of the latest version of joomla

This tutorial will deploy the latest version of Joomla using template 1 which you can read about here with the clone you have just made onto your laptop:  

>     ./adt-build-machine-scripts/templatedconfigurations/templates/linode/linode1.description and the hardcore method.

---------------------------------------

**Record and save the credentials you are about to create in a secure file on your laptop**

To find the latest version of Joomla, I go to this URL in my browser:

[Joomla Latest](https://downloads.joomla.org/)

And I note the latest version in a separate text file:

>     joomla_version="4.0.4"  

You can of course use a legacy version of joomla also by choosing a different version numnber. 

-------------------------------------

> I then need a personal access token for Linode, I go to the top right and select "API Keys" and generate a personal access token with 

> "Account,Domains, Images, IPs, Linodes, Object Storage, Stackscripts and Volumes" 

> scope enabled. This personal access token I shall call "AAAAA"

**IMPORTANT EDIT: To use the native firewalling system the linode-cli tool seems to only accept personal access tokens with full access rights, so, whilst that is the case, you will need to ignore the above scoping and just chose "Select All" with "Read and Write" access when you create your personal access token.** 

>     linode_personal_access_token="AAAAA"  where AAAAA is the actual values generated when I click "Create Token"

-------------------------

You now need to set up Object Storage and obtain Object Storage Keys. You can do this by Selecting Object Storage on the left hand side of your Linode console. 

You then click "Access Key" and then, "Create Access Key" and this will display an "Access Key" and a "Secret Key" which you need to make a note of and keep safe:

>     linode_S3_access_key="BBBBB"
>     linode_S3_secret_key="CCCCC"

-----------------------------------

You now need to make a note of the email address that you have registered with your linode account:

>     linode_email="testemail@testemail.com"

-----------------------------------

You then need the url that you want to use for your website. If you don't have a DNS URL for your website, you need to purchase one and set the nameservers to linode as described in ./adt-build-machine-scripts/blob/master/doco/AgileToolkitDeployment/Nameservers.md

>     linode_dns_name="www.testdeploy.com"

-------------------------------

You then need the username and owner of you git provider application repositories.  

To do this, if you don't have a git account sign up with one (in this case using github, but, you have the choice of bitbucket and gitlab as well) and record the username that you sign up with:

>     gitusername="yourgithubuser"

Then create a "personal access token" by following: 

[Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) making sure you give it all "repo" permissions as well as the "delete repository" permission

>     gitpersonalaccesstoken="KKKKK" where KKKKK represents your actual personal access token

--------------------------------

To keep this as simple as possible, I have missed out the SMTP credentials, but, you can find out more about them  

[Deploying SMTP Service](../../../doco/AgileToolkitDeployment/DeployingSMTPService.md)  

If you wish to include SMTP credentials you will need to have a service offering set up with either sendpulse, mailjet or AWS SES.

--------------------------

**NOTE:** 
**The CLOUDHOST_PASSWORD value must be set in your template for a linode based build to succeed.** 

--------------------------

So, that should be all the core credentials that I need to make a deployment. I can save my text file now (and keep it secure) because I might want to use these credentials again for other deployments or redeployments. 

--------------------------------------------
--------------------------------------------

So, to begin an hardcore build process, I need to:

>     vi ./adt-build-machine-scripts/templatedconfigurations/templates/linode/linode1.tmpl

This file looks like this (I have put a dashes before each line I wish to modify for this deployment which is for illustrative purposes only):


>     ###############################################################################################
>     # Refer to: ${BUILD_HOME}/templatedconfigurations/specification.md
>     ###############################################################################################
>     #This template is configured for virgin style builds
>     
>     #####MANDATORY - Bare minimum set of values that must be provided by you for a build to have any chance of succeeding
>     #####NOT REQUIRED - isn't used by the Linode
>     
>     #####Application Settings#########
>     ------ export APPLICATION="" #MANDATORY 
>     ------ export APPLICATION_IDENTIFIER="" #MANDATORY
>     ------ export JOOMLA_VERSION="" #MANDATORY (depending on the above settings - a joomla deployment)
>     export DRUPAL_VERSION=""  #MANDATORY (depending on the above settings - a drupal deployment)
>     ------ export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="" #MANDATORY
>     export BASELINE_DB_REPOSITORY="VIRGIN"
>     export APPLICATION_LANGUAGE="PHP" 
>     export PHP_VERSION="8.3" 
>     export BUILD_ARCHIVE_CHOICE="virgin"
>     export BUILD_CHOICE="0"
>     export APPLICATION_NAME="Demo Application"
>     
>     
>     #####S3 Datastore Settings#######
>     ----- export S3_ACCESS_KEY=""  #MANDATORY
>     ----- export S3_SECRET_KEY=""  #MANDATORY
>     export S3_HOST_BASE="eu-central-1.linodeobjects.com" 
>     export S3_LOCATION="US" #For linode, this always needs to be set to "US"
>     export DATASTORE_CHOICE="linode"
>     export DIRECTORIES_TO_MOUNT="" #This should always be unset for a virgin and baseline deployments
>     export PERSIST_ASSETS_TO_CLOUD="0" #This should always be set to 0 for a virgin and baseline deployment
>     
>     #####OS Settings#########
>     export DEFAULT_USER="root" # This must be "root" on Linode
>     export BUILDOS="debian" # One of ubuntu|debian
>     export BUILDOS_VERSION="12" # One of 20.04 22.04 24.04|10 11 12
>     
>     ######Cloudhost Provider Settings#######
>     ----- export TOKEN="" #MANDATORY
>     export ACCESS_KEY=""   #NOT REQUIRED
>     export SECRET_KEY=""   #NOT REQUIRED
>     ----- export CLOUDHOST_ACCOUNT_ID=""  #MANDATORY for Linode - this should be the account username that you login with
>     
>     ######DNS Settings##########
>     ----- export DNS_USERNAME=""  #MANDATORY
>     ----- export DNS_SECURITY_KEY=""   #MANDATORY
>     export DNS_CHOICE="linode" #you will need to set your DNS nameservers according to this choice
>     
>     #####Webserver Settings########
>     ----- export WEBSITE_DISPLAY_NAME="" #MANDATORY
>     ----- export WEBSITE_NAME="" #MANDATORY
>     ----- export WEBSITE_URL=""  #MANDATORY
>     export WEBSERVER_CHOICE="NGINX"
>     export NUMBER_WS="1"
>     
>     #####Git settings#####
>     export GIT_USER="Templated User" 
>     export GIT_EMAIL_ADDRESS="templateduser@dummyemailZ123.com"
>     
>     #####Infrastructure Repository Settings#######
>     export INFRASTRUCTURE_REPOSITORY_PROVIDER="github"
>     export INFRASTRUCTURE_REPOSITORY_OWNER="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_USERNAME="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_PASSWORD="none"
>     
>     ###### Application Repository Settings########
>     export APPLICATION_REPOSITORY_PROVIDER="github" 
>     ----- export APPLICATION_REPOSITORY_OWNER="" #MANDATORY
>     ----- export APPLICATION_REPOSITORY_USERNAME="" #MANDATORY
>     ----- export APPLICATION_REPOSITORY_PASSWORD="" #MANDATORY
>     ----- export APPLICATION_REPOSITORY_TOKEN="" #MANDATORY
>     
>     ##### System Email Settings#########
>     export SYSTEM_EMAIL_PROVIDER="" 
>     export SYSTEM_TOEMAIL_ADDRESS="" 
>     export SYSTEM_FROMEMAIL_ADDRESS="" 
>     export SYSTEM_EMAIL_USERNAME="" 
>     export SYSTEM_EMAIL_PASSWORD="" 
>     export EMAIL_NOTIFICATION_LEVEL="ERROR"
>     
>     ##### Database Settings######
>     export DB_PORT="2035"
>     export DATABASE_INSTALLATION_TYPE="Maria"
>     export DATABASE_DBaaS_INSTALLATION_TYPE=""
>     export BYPASS_DB_LAYER="0"
>     
>     #####Server Settings #######
>     export REGION="eu-central"
>     export DB_SIZE="g6-nanode-1"
>     export DB_SERVER_TYPE="g6-nanode-1"
>     export WS_SIZE="g6-nanode-1"
>     export WS_SERVER_TYPE="g6-nanode-1"
>     export AS_SIZE="g6-nanode-1"
>     export AS_SERVER_TYPE="g6-nanode-1"
>     export CLOUDHOST="linode"
>     export MACHINE_TYPE="LINODE"
>     export SSH_PORT="1035"
>     export SERVER_TIMEZONE_CONTINENT="Europe"
>     export SERVER_TIMEZONE_CITY="London"
>     export USER="root"
>     
>     #####Backup Setttings######
>     export SUPERSAFE_WEBROOT="1"
>     export SUPERSAFE_DB="1"
>     export GENERATE_STATIC="0"
>     
>     #####Build Settings######
>     export PRODUCTION="0"
>     export DEVELOPMENT="1"
>     ----- export BUILD_IDENTIFIER="" #MANDATORY
>     export NO_AUTOSCALERS="0"
>     
>     #####Security Settings#####
>     export ACTIVE_FIREWALLS="3"
>     export PUBLIC_KEY_NAME="AGILE_TOOLKIT_PUBLIC_KEY"
>     export SSL_GENERATION_METHOD="AUTOMATIC"
>     export SSL_GENERATION_SERVICE="LETSENCRYPT"
>     export SSL_LIVE_CERT="1"
>     export BUILD_MACHINE_VPC="1"
>     export ALGORITHM="rsa"
>     
>     #####Build Styles#####
>     export AUTOSCALE_FROM_SNAPSHOTS="0"
>     export GENERATE_SNAPSHOTS="0"
>     export SNAPSHOT_ID=""
>     export WEBSERVER_IMAGE_ID=""
>     export AUTOSCALER_IMAGE_ID=""
>     export DATABASE_IMAGE_ID=""
>     export AUTOSCALE_FROM_BACKUP="0"
>     export INPARALLEL="0"
>     
>     #####Monitoring######
>     export INSTALL_MONITORING_GEAR="0" 

So, editing  

>     vi ./adt-build-machine-scripts/templatedconfigurations/templates/linode/linode1.tmpl   

and using the values I recorded in my text file earlier, I modify the file as follows, the lines beginning with dashes have been modified

>     ###############################################################################################
>     # Refer to: ${BUILD_HOME}/templatedconfigurations/specification.md
>     ###############################################################################################
>     #This template is configured for virgin style builds
>     
>     #####MANDATORY - Bare minimum set of values that must be provided by you for a build to have any chance of succeeding
>     #####NOT REQUIRED - isn't used by the Linode
>     
>     #####Application Settings#########
>     ------ export APPLICATION="joomla" #MANDATORY 
>     ------ export APPLICATION_IDENTIFIER="1" #MANDATORY
>     ------ export JOOMLA_VERSION="4.0.4" #MANDATORY (depending on the above settings - a joomla deployment)
>     export DRUPAL_VERSION=""  #MANDATORY (depending on the above settings - a drupal deployment)
>     ------ export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="JOOMLA:4.0.4" #MANDATORY
>     export BASELINE_DB_REPOSITORY="VIRGIN"
>     export APPLICATION_LANGUAGE="PHP" 
>     export PHP_VERSION="8.3" 
>     export BUILD_ARCHIVE_CHOICE="virgin"
>     export BUILD_CHOICE="0"
>     export APPLICATION_NAME="Demo Application"
>     
>     #####S3 Datastore Settings#######
>     ----- export S3_ACCESS_KEY="BBBBB"  #MANDATORY
>     ----- export S3_SECRET_KEY="CCCCC"  #MANDATORY
>     export S3_HOST_BASE="eu-central-1.linodeobjects.com" 
>     export S3_LOCATION="US" #For linode, this always needs to be set to "US"
>     export DATASTORE_CHOICE="linode"
>     export DIRECTORIES_TO_MOUNT="" #This should always be unset for a virgin and baseline deployments
>     export PERSIST_ASSETS_TO_CLOUD="0" #This should always be set to 0 for a virgin and baseline deployment
>     
>     #####OS Settings#########
>     export DEFAULT_USER="root" # This must be "root" on Linode
>     export BUILDOS="debian" # One of ubuntu|debian
>     export BUILDOS_VERSION="12" # One of 20.04 22.04 24.04|10 11 12
>     
>     ######Cloudhost Provider Settings#######
>     ----- export TOKEN="AAAAA" #MANDATORY
>     export ACCESS_KEY=""   #NOT REQUIRED
>     export SECRET_KEY=""   #NOT REQUIRED
>     ----- export CLOUDHOST_ACCOUNT_ID="linodeusername"  #MANDATORY for Linode - this should be the account username that you login with
>     
>     ######DNS Settings##########
>     ----- export DNS_USERNAME="testemail@testemail.com"  #MANDATORY
>     ----- export DNS_SECURITY_KEY="AAAAA"   #MANDATORY
>     export DNS_CHOICE="linode" #you will need to set your DNS nameservers according to this choice
>     
>     #####Webserver Settings########
>     ----- export WEBSITE_DISPLAY_NAME="Test Deployment Application" #MANDATORY
>     ----- export WEBSITE_NAME="testdeploy" #MANDATORY
>     ----- export WEBSITE_URL="www.testdeploy.com"  #MANDATORY
>     export WEBSERVER_CHOICE="NGINX"
>     export NUMBER_WS="1"
>     
>     #####Git settings#####
>     export GIT_USER="Templated User" 
>     export GIT_EMAIL_ADDRESS="templateduser@dummyemailZ123.com"
>     
>     #####Infrastructure Repository Settings#######
>     export INFRASTRUCTURE_REPOSITORY_PROVIDER="github"
>     export INFRASTRUCTURE_REPOSITORY_OWNER="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_USERNAME="wintersys-projects"
>     export INFRASTRUCTURE_REPOSITORY_PASSWORD="none"
>     
>     ###### Application Repository Settings########
>     export APPLICATION_REPOSITORY_PROVIDER="github" 
>     ----- export APPLICATION_REPOSITORY_OWNER="yourgithubuser" #MANDATORY
>     ----- export APPLICATION_REPOSITORY_USERNAME="yourgithubuser" #MANDATORY
>     ----- export APPLICATION_REPOSITORY_PASSWORD="KKKKK" #MANDATORY
>     ----- export APPLICATION_REPOSITORY_TOKEN="KKKKK" #MANDATORY
>     
>     ##### System Email Settings#########
>     export SYSTEM_EMAIL_PROVIDER="" 
>     export SYSTEM_TOEMAIL_ADDRESS="" 
>     export SYSTEM_FROMEMAIL_ADDRESS="" 
>     export SYSTEM_EMAIL_USERNAME="" 
>     export SYSTEM_EMAIL_PASSWORD="" 
>     export EMAIL_NOTIFICATION_LEVEL="ERROR"
>     
>     ##### Database Settings######
>     export DB_PORT="2035"
>     export DATABASE_INSTALLATION_TYPE="Maria"
>     export DATABASE_DBaaS_INSTALLATION_TYPE=""
>     export BYPASS_DB_LAYER="0"
>     
>     #####Server Settings #######
>     export REGION="eu-central"
>     export DB_SIZE="g6-nanode-1"
>     export DB_SERVER_TYPE="g6-nanode-1"
>     export WS_SIZE="g6-nanode-1"
>     export WS_SERVER_TYPE="g6-nanode-1"
>     export AS_SIZE="g6-nanode-1"
>     export AS_SERVER_TYPE="g6-nanode-1"
>     export CLOUDHOST="linode"
>     export MACHINE_TYPE="LINODE"
>     export SSH_PORT="1035"
>     export SERVER_TIMEZONE_CONTINENT="Europe"
>     export SERVER_TIMEZONE_CITY="London"
>     export USER="root"
>     
>     #####Backup Setttings######
>     export SUPERSAFE_WEBROOT="1"
>     export SUPERSAFE_DB="1"
>     export GENERATE_STATIC="0"
>     
>     #####Build Settings######
>     export PRODUCTION="0"
>     export DEVELOPMENT="1"
>     ----- export BUILD_IDENTIFIER="testdeploy" #MANDATORY
>     export NO_AUTOSCALERS="0"
>     
>     #####Security Settings#####
>     export ACTIVE_FIREWALLS="3"
>     export PUBLIC_KEY_NAME="AGILE_TOOLKIT_PUBLIC_KEY"
>     export SSL_GENERATION_METHOD="AUTOMATIC"
>     export SSL_GENERATION_SERVICE="LETSENCRYPT"
>     export SSL_LIVE_CERT="1"
>     export BUILD_MACHINE_VPC="1"
>     export ALGORITHM="rsa"
>     
>     #####Build Styles#####
>     export AUTOSCALE_FROM_SNAPSHOTS="0"
>     export GENERATE_SNAPSHOTS="0"
>     export SNAPSHOT_ID=""
>     export WEBSERVER_IMAGE_ID=""
>     export AUTOSCALER_IMAGE_ID=""
>     export DATABASE_IMAGE_ID=""
>     export AUTOSCALE_FROM_BACKUP="0"
>     export INPARALLEL="0"
>     
>     #####Monitoring######
>     export INSTALL_MONITORING_GEAR="0"

If all the dashes I have added are removed, then this file (with live values and not symbolic ones) would be ready for deployment.  

You now need to copy your template as follows:  

>     /bin/mkdir ./adt-build-machine-scripts/overridescripts/
>     /bin/cp ./adt-build-machine-scripts/templatedconfigurations/templates/linode/linode1.tmpl ./adt-build-machine-scripts/overridescripts/linode1override.tmpl  

Then you need to run the script:

>     cd helperscripts

>     ./GenerateOverrideTemplate.sh  (make sure you review and set all **ALL** of the settings - reviewing them generates the stackscript)  

**ESSENTIAL NOTE: with the GenerateOverrideTemplate script above, you need to review every setting for the stack script to be generated**

With Linode you can either use a StackScript or userdata (limited regional and OS availability currently) to spin up your machines. In both cases you need to generate a different script. You can either generate a stack script to use or you can use the Metadata service (which is industry standard)

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

If you don't want to use a stackscript and want to use the metadata service instead, 

 **Metadata Service**

>     ./GenerateHardcoreUserDataScript.sh stack


This will leave you with a script:

>    ../userdatascripts/${userdatascript}   

where ${userdatascript} is the descriptive name you gave when prompted.  

You will need to enter values to suit your deployment into the userdatascript for:

>     export BUILDMACHINE_USER="agile-user"
>     export BUILDMACHINE_PASSWORD="Hjdhfb34hd£" #Make sure any password you choose is strong enough to pass any strength enforcement rules of your OS
>     export BUILDMACHINE_SSH_PORT="1035"
>     export LAPTOP_IP="111.111.111.111"

>     export SSH=\"\" #paste your public key here
>     export SELECTED_TEMPLATE="1"

This will give you a script which you can post into the userdata script of a linode - the linode that you are deploying as your new build machine. So basically configure a vanilla linode and paste the userdata script into the userdata or metadata service area of the linode to spin up your the build machine for your deployment.

At this point, you can deploy your build machine should be up and running in short order. Please then review 
  
[Tighten Build Machine](../../../doco/AgileToolkitDeployment/TightenBuildMachineAccess.md) 
 
At this point, your build machine will only accept connections from your laptop. If you need access from other ip addresses you need to use the technique described in "Tightening Build Machine Access" to grant access to additional IP addresses. This will be the case every time your laptop changes its IP address as you travel about, so, you might want to setup and configure an S3 client on your laptop to enable you to grant access to new IP addresses easily. 


