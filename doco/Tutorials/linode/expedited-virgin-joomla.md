**PREBUILD NECESSITIES**

If you don't already have a build machine running in the Linode cloud, follow these steps to get ready for the main build)

1. Begin by following this: [Build Machine Setup](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/doco/Tutorials/linode/build-machine.md) 

2. At this point, your build machine should be up and running. Please review [Tightening Build Machine Firewall](../../../doco/AgileToolkitDeployment/TightenBuildMachineAccess.md). At this point, your build machine will only accept connections from your laptop. If you need access from other ip addresses you need to use the technique described in "Tightening Build Machine Firewall" to grant access to additional IP addresses. This will be the case every time your laptop changes its IP address as you travel about, so, you might want to setup and configure an S3 client on your laptop to enable you to grant access to new IP addresses easily. 

-----------------------------

**EXPEDITED BUILD PROCESS**

This will deploy the latest version of Joomla using template 1 which you can read about here: [template 1](../../../templatedconfigurations/templates/linode/linode1.description) and the expedited method.

If you have followed these steps your build machine is online and secured and you have an SSH session open to it from your laptop through which to initiate your build processes.

We need several pieces of information from our cloud host and 3rd party services for a successful build to be possible:

I am going to use the example of joomla to build from and so this example will build a virgin installation of the latest version of joomla

---------------------------------------

To find the latest version of Joomla, I go to this URL in my browser:

[Joomla Latest](https://downloads.joomla.org/)

And I note the latest version in a separate text file:

>     joomla_version="4.0.4"  

You can of course use a legacy version of joomla also by choosing a different version numnber. 

-------------------------------------

I then need a set of compute access keys so, I go to the IAM option on my linode dashboard and generate an Peronal Access token with all access granted. In my separate text file, I record:

>     linode_token"XXXXX"  where XXXXX is the PAT

I then need a set of Object Storage (S3) access keys so, I go to the IAM option on my linode dashboard and generate an access keys with S3 Object Storage access. In my separate text file, I record:

>     linode_access_key_s3="AAAAA"  where AAAAA and BBBBB are the actual values generated when I click "Add Key"
>     linode_secret_key_s3="BBBBB"


I then need a set of DNS access keys so, I go to the IAM option on my linode dashboard and generate an Personal Access token with DNS access. In my separate text file, I record:

>     linode_token_dns="CCCCC"  where CCCCC is the actual values generated when I click "Add Key"

-----------------------------------

You then need the url that you want to use for your website. If you don't have a DNS URL for your website, you need to purchase one and set the nameservers to linode as described [here](../../../doco/AgileToolkitDeployment/Nameservers.md)

>     linode_dns_name="www.testdeploy.com"

-------------------------------

You then need the username and owner of you git provider application repositories.
To do this, if you don't have a git account sign up with one (in this case using github, but, you have the choice of bitbucket and gitlab as well) and record the username that you sign up with:

>     gitusername="yourgithubuser"

Then create a "personal access token" by following: 

[Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) making sure you give it all "repo" permissions as well as the "delete repository" permission

>     gitpersonalaccesstoken="KKKKK" where KKKKK represents your actual personal access token

--------------------------------

To keep this as simple as possible, I have missed out the SMTP credentials, but, you can find out more about them [here](../../../doco/AgileToolkitDeployment/DeployingSMTPService.md). If you wish to include SMTP credentials you will need to have a service offering set up with either sendpulse, mailjet or AWS SES.

So, that should be all the core credentials that I need to make a deployment. I can save my text file now (and keep it secure) because I might want to use these credentials again for other deployments or redeployments. 

--------------------------------------------
--------------------------------------------

So, at the command line of my build machine that we spun up earlier:

My chosen username is "wintersys-projects"

So, to begin an expedited build process, I need to:

>     cd /home/wintersys-projects/adt-build-machine-scripts/templatedconfigurations/templates/linode

Then we can open up the 

>     vi linode1.tmpl

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


So, editing /home/wintersys-projects/adt-build-machine-scripts/templatedconfigurations/templates/linode/linode1.tmpl and using the values I recorded in my text file earlier, I modify the file as follows, the lines beginning with dashes have been modified

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

>     ${BUILD_HOME}/ExpeditedAgileDeploymentTookkit.sh

------------------

#### For Wordpress:

>     export APPLICATION="wordpress"
>     export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="WORDPRESS" #MANDATORY 
>     export APPLICATION_IDENTIFIER="2"

#### For Drupal:

>     export APPLICATION="drupal"
>     export DRUPAL_VERSION="9.2.6" 
>     export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="DRUPAL:9.2.6" #MANDATORY 
>     export APPLICATION_IDENTIFIER="3"

#### For Moodle:

>     export APPLICATION="moodle"
>     export APPLICATION_BASELINE_SOURCECODE_REPOSITORY="MOODLE" #MANDATORY 
>     export APPLICATION_IDENTIFIER="4"

So, you have a template now that you can use over and over again for deploying different installations of these CMS systems. You can study the spec and learn how to modify the template in order to change machine sizes, regions, PHP settings and so on. 
