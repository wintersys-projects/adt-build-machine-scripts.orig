### SSH

This variable should be set to your public key for your laptop. This will enable you to access the build machine from a private key that you have generated and stored on your laptop

-----

### BUILDOS

This is the BUILDOS you wish to use for your servers, it can be one of "ubutnu" or "debian"

-----

### BUILDOS_VERSION

This is the BUILDOS_VERSION you are deploying for this can be "20.04" or "22.04" or "24.04" and later LTS releases if BUILDOS is "ubuntu". 

"10" "11" or "12" and later releases if BUILDOS is "debian"

-----


### BUILD_IDENTIFIER

This is a unique string to describe your build. If you have multiple builds that you want to give similar names you should call them, for example, "1-testbuild" or "2-testbuild" or "3-testbuild"

-----

### DEFAULT_USER  

The default user should be set as follows:  

digitalocean : **root** in all cases  
exoscale : **ubuntu** when deploying ubuntu and **debian** when deploying debian  
linode : **root** in all cases  
vultr : **root** in all cases  
aws : **ubuntu** when deploying ubuntu and **admin** when deploying debian  

-----

### APPLICATION

This can be set to one of "joomla", "wordpress", "drupal", "moodle"

---- 

### JOOMLA_VERSION

If you are deploying a virgin joomla installation, you must give the version number of joomla that you are deploying here. In such a template, you will likely want to update this version number to be the latest available.

---- 

### DRUPAL_VERSION

If you are deploying a virgin drupal installation, you must give the version number of drupal that you are deploying here. In such a template, you will likely want to update this version number to be the latest available.

---- 

### APPLICATION_BASELINE_SOURCECODE_REPOSITORY

If you are deploying a virgin application, you can set this to "JOOMLA:{latest_version}", "WORDPRESS", "DRUPAL:{latest_version}" or "MOODLE"

-----

### APPLICATION_IDENTIFIER

Currently this is 0 for no action, 1 for Joomla, 2 for Wordpress, 3 for Drupal and 4 for Moodle

The basic thing you need to understand is that if you want your baselines and backups to be able to be used from different URLS, then, you need to set the APPLICATION_IDENTIFIER appropriate for your application. If you want your baseline to be able to be deployed by different people to different URLs, then, you need to set the APPLICATION_IDENTIFER to 1,2,3 or 4 depending on your application. If you set it to 0, that's fine, but, the baseline will only be able to deploy to the precise same URL. So, if you were developing a joomla application and your domain was dev.testdomain.com and you had an APPLICATION_IDENTIFIER of 0, then, you wouldn't be able to deploy to live.testdomain.com. If you set your APPLICATION_IDENTIFIER to 1, because you are running a joomla application, then you can deploy your baseline to dev.testdomain.com and live.testdomain.com or even live.livedomain.org similarly with your time based backups. 

-----

### S3_ACCESS_KEY 
### S3_SECRET_KEY

These grant you access to manipulate an object store. Under the principle of least privileges, you should grant as few privileges to these keys when you create them as possible. The DATASTORE_CHOICE setting (see below) will determine which Object Storage you are using and you will need to generate access keys appropriate to that setting. 

You can get your S3_ACCESS_KEY and S3_SECRET KEY as follows:

##### digital ocean - Login to your digital ocean account and go to the API submenu (on the left bottom) and generate "Digital Ocean Spaces Keys". This will give you an access key which you can paste into your template. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY

##### exoscale - Login to your exoscale account and go to the IAM menu (on the right) and generate a pair of API keys which have access to object storage capabilities. The first key is the S3_ACCESS_KEY and the second key is the S3_SECRET_KEY which you can post into your template.

##### linode - Login to your Linode account and go to the Object Storage menu on the right then select the Access Key menu and select "Create an Access Key" and that will generate an access key and a secret key which you can copy into your template as S3_ACCESS_KEY and S3_SECRET_KEY.

##### vultr - You need to subscribe to S3 Object Storage and this will grant you a pair of S3 access keys which you can copy and paste into your template. 

-----

### S3_HOST_BASE 

This parameter is the S3 endpoint for your deployment. It should be located as near as possible to where (in the world) you plan to run your VPS systems.

##### digital ocean - Available endpoints to choose from (2020) - nyc3.digitaloceanspaces.com, ams3.digitaloceanspaces.com, sfo2.digitaloceanspaces.com, sgp1.digitaloceanspaces.com, fra1.digitaloceanspaces.com

##### exoscale - Available endpoints to choose from (2024) - sos-ch-gva-2.exo.io, sos-ch-dk-2.exo.io, sos-de-fra-1.exo.io, sos-de-muc-1.exo.io, sos-at-vie-1.exo.io, sos-bg-sof-1

##### linode - Available endpoints to choose from (2024) - nl-ams-1.linodeobjects.com us-southeast-1.linodeobjects.com in-maa-1.linodeobjects.com us-ord-1.linodeobjects.com eu-central-1.linodeobjects.com id-cgk-1.linodeobjects.com us-lax-1.linodeobjects.com us-mia-1.linodeobjects.com it-mil-1.linodeobjects.com us-east-1.linodeobjects.com jp-osa-1.linodeobjects.com fr-par-1.linodeobjects.com br-gru-1.linodeobjects.com us-sea-1.linodeobjects.com ap-south-1.linodeobjects.com se-sto-1.linodeobjects.com us-iad-1.linodeobjects.com  

##### vultr - Available endpints to choose from (2024) - ewr1.vultrobjects.com, ams1.vultrobjects.com, sjc1.vultrobjects.com, sgp1.vultrobjects.com

You can set your ${S3_HOST_BASE} parameter in your template to one of these listed endpoints depending on who your object storage is hosted with (which will likely be the ssame provider as your VPS systems). 

-----

### S3_LOCATION

##### digital ocean - the location should always be set to one of nyc1 sfo1 nyc2 ams2 sgp1 lon1 nyc3 ams3 fra1 tor1 sfo2 blr1 sfo3  

##### exoscale - the location should always be set to one of ch-gva-2 ch-dk-2 at-vie-1 de-fra-1 bg-sof-1 de-muc-1  

##### linode - the location should always be set to one of ap-west ca-central ap-southeast us-iad us-ord fr-par us-sea br-gru nl-ams se-sto in-maa jp-osa it-mil us-mia id-cgk us-lax us-central us-west us-southeast us-east eu-west ap-south eu-central ap-northeast   

##### vultr - the location should always be set to one of ams atl cdg dfw ewr fra icn lax lhr mex mia nrt ord sea sgp sjc sto syd yto  


-----

### TOKEN

Some providers use personal access tokens rather than access keys and secret keys. In such a case, the personal access token can be stored in this variable. If the provider uses a personal access token, you can store it here, basically, othewise presume that an access key and a secret key are utilised.

##### digital ocean - Login to your digital ocean account and go to the API submenu (on the left bottom) and generate a "Digital Ocean Personal Access Token". This will give you a personal access token which you can paste into your template as the value of the TOKEN variable.

##### exoscale - exoscale does not need this see ACCESS_KEY and SECRET_KEY

##### linode - Login to your Linode account, go to your Profile (top right) and select "API Tokens" and from there you can generate a "personal access token" to use as your TOKEN

##### Vultr - Login to your vultr account and go to your account on the top right. Then enable your personal access token and you can set it here.


-----

### ACCESS_KEY
### SECRET_KEY

Some providers use an access key and a secret key to control access to their compute resources. You need to generate an access and secret key for your provider and use them here as ACCESS_KEY and SECRET_KEY respectively

##### digital ocean - Does not use access keys and secret keys, see TOKEN

##### exoscale - You can generate access keys and secret keys to control access to your compute resources. Note, this is distinct from the object storage access keys

##### linode - Does not use access keys and secret keys, see TOKEN

##### Vultr - Does not use access keys and secret keys, see TOKEN


-----

### EMAIL_NOTIFICATION_LEVEL

This will set the email notification level for system status emails and it can be set to either "INFO" or "ERROR" or "MANDATORY".

If you set it to INFO you will get status emails such as "A database backup has completed successfully" every time a backup is made
If you set it to ERROR you will only get error message emails if, for example, "A database backup has failed to complete". 
If you set it to MANDATORY it means its not an error but it must be sent

NOTE: INFO will report INFO and ERROR messages, ERROR will only report ERROR messages

Clearly if you set it to ERROR, you will only get emails if there is a problem if you set it to INFO you will get emails reporting back on how the system is running under normal function. 

------

### DNS_USERNAME

This will be the username for your nameserver provider

##### cloudflare - the emal address of username of your cloudflare account

##### digitalocean - your digital ocean account email address

##### exoscale - your exoscale account email address

##### linode - your linode account email address

##### vultr - your vultr account email address

-----

### DNS_SECURITY_KEY 

This is the security key which will enable us to manipulate records as needed with your nameserver provider. You can find this key as follows for each provider:

##### cloudflare - Ths is the Global API key for your cloudflare account which you can find by clicking on your profile at the top right of the screen

##### digital ocean - The access token for your digital ocean account, (can be the same as TOKEN)

##### exoscale  - The access key and secret key for your exoscale account. You need to enter this as ${ACCESS_KEY}:${SECRET_KEY}. You can use the same access key and secret key as your main account or you can create separate ones with only DNS manipulation rights. 

##### linode - A personal access token with DNS manipulation rights (can be the same value as TOKEN)

##### Vultr - A personal access token with DNS manipulation rights (can be the same as TOKEN)

------

### DNS_REGION

#### cloudflare - not needed

#### digitalocean - not needed

#### exoscale - not needed

#### linode - not needed

#### vultr - not needed

-----

### DNS_CHOICE  

This can be set to one of these values 

##### "cloudflare" 
##### "digitalocean" 
##### "exoscale"
##### "linode"
##### "vultr"

It defines which of the (supported) DNS service you would like to use with your deployment.

---------------

### WEBSITE_DISPLAY_NAME

This is simply the display name of your application, for example, "My Social Network", or "My Blog" and so on. It should be descriptive of your website and likely will be similar to the core part of the WEBSITE_URL described below

-----

### WEBSITE_NAME

This HAS to be exactly the same of the core part of the URL name of your website. So, if your website is called www.nuocial.org.uk, then, this value MUST be "nuocial"

-----

### WEBSITE_URL

This is the URL of your website. It can be any valid URL

-----
### APPLICATION_REPOSITORY_PROVIDER

This is the git service provider where your application repositories are hosted. It has to be one of "github", "bitbucket" or "gitlab". If you fill this variable with one of those three exact strings, then, that will tell us who your application code is hosted with. It may or may not be hosted with the same provider as the infrastructure code for the agile deployment toolkit

-----

### APPLICATION_REPOSITORY_OWNER

This is the username of the user who owns (or created) your application repositories with your chosen git service provider

-----

### APPLICATION_REPOSITORY_USERNAME

This is the username of the user that you are currently using to access the application repositories. For example, the repositories might be owned by userA and are kept private but, userB is granted access. In this case the APPLICATION_REPOSITORY_OWNER would be userA and the APPLICATION_REPOSITORY_USERNAME would be userB. If you are the application repository owner, then this username and the owner name above will be the same.

-----

### APPLICATION_REPOSITORY_PASSWORD  

This is the password for the APPLICATION_REPOSITORY_USERNAME or the application repository user. This is the password for your user account with your git provider. If the application repositories are public (be careful not to expose sensitive credentials if you make your application repos public), then a password is not needed in which case this value must be precisely written or set to **"none"**

-----

### APPLICATION_REPOSITORY_TOKEN

Github and Gitlab prefer personal access tokens to passwords, so, if you wish to, you can generate personal access tokens at:

Github: www.github.com/settings/tokens  
Gitlab: www.gitlab.com/profile/personal_access_tokens

Make sure these tokens have the rights to create and destroy repositories as well as to read and write from them. Most likely, you want to have a separate git provider account for your associated deployments. This will override APPLICATION_REPOSITORY_PASSWORD

------

### BUILD_MACHINE_VPC

"0" Means that your build machine isn't in the same VPC as your deployed machines (your build machine might be a dedicated laptop or even running on a different cloudhost VPS). Becuase of this public IP addresses will have to be used for all communications between the build machine and the deployed machines

"1" means that your build machine is in the same VPC as your deployment machines and so private networking (private ip addresses in other words) can be used to commincate from the build machine to the deployment machines. This is the more secure option. 

------

### VPC_IP_RANGE

You need to put the address range of your VPC in here. This is mandatory because without it the firewalling won't function correctly and your website will likely timeoout. An example value of this might be 10.116.0.0/24 for a VPC in digital ocean's lon1 datacentre. This value will be different for each region where your VPC is and the you must have a VPC (or private network if you are on exoscale) called "adt-vpc"

-------

### SYSTEM_EMAIL_PROVIDER

At the moment, there are three SMTP email service providers. Enter the number value, "1", "2" or "3" to select which provider you want to use for your SMTP service. If you leave these variables blank, you simply won't receive any system emails to give status updated on build progression, server intialisations and so on. You are free to leave these variables blank, as you choose.

Enter "1" - Sendpulse (www.sendpulse.com). 

Enter "2" - Mailjet. 

Enter "3" - AWS SES. 


-----

### SYSTEM_TOEMAIL_ADDRESS 

The email address that system emails will be sent to this can be any email address that you have access to. MAYBE, the emails get marked as spam depending on your provider. If you take them out of the spam folder, then, the system should learn they are not spam. Most likely you will want to have a dedicated email address for your system emails for your deployed application as they will likely fill up your inbox otherwise.

-----

### SYSTEM_FROMEMAIL_ADDRESS

The email address that system emails will be sent from. This should be an email address that the system emails are sent from. In your SYSTEM_TOEMAIL_ADDRESS inbox, this will be the email address that the system messages are seen to be sent from or to have originated from.

-----

### SYSTEM_EMAIL_USERNAME

This is the username of your SMTP user. For Amazon SES, for example, this will be the username generated when you enable the SES service. This is the SMTP username. 

-----

### SYSTEM_EMAIL_PASSWORD

This is the password of your SMTP user. For Amazon SES, for example, this will be the password generated when you enable the SES service. This is the SMTP password. 

----

### DIRECTORIES_TO_MOUNT

Each CMS system is likely to have directories where assets are generated from application usage and so on. Assets and media that are generated at runtime need to be immediately shared between all webservers and the way I do this is as a general solution, I mount the assets directories specific to the CMS type from a shared S3 bucket to each webserver. There is a specific solution for AWS which is the EFS system which is also supported. EFS can have up to petabytes of information and assuming you have very deep pockets, you can have petabytes of storage for you dyanmic application assets which is often a limiting factor for large scale social networks and so on, where often, asset generation is quite high with members uploading videos and images and the like.  

Joomla - export DIRECTORIES_TO_MOUNT="images" - When the CMS is joomla, this will mount /var/www/html/images  
WordPress - export DIRECTORIES_TO_MOUNT="wp-content.uploads" - When the CMS is WordPress, this will mount /var/www/html/wp-content/uploads  
Drupal - export DIRECTORIES_TO_MOUNT="sites.default.files" - When the CMS is WordPress, this will mount /var/www/html/sites/default/files 
Opensocial - export DIRECTORIES_TO_MOUNT="sites.default.files:/var/www/private" - When the CMS is WordPress, this will mount /var/www/html/sites/default/files  amd /var/www/private
Moodle - export DIRECTORIES_TO_MOUNT="moodledata.filedir" - When the CMS is WordPress, this will mount /var/www/html/moodledata/filedir

----- 

### PRODUCTION 
### DEVELOPMENT

These settings are twinned. It only makes sense for them to be in one of two configurations:

Production mode : PRODUCTION="1", DEVELOPMENT="0"
Development mode : PRODUCTION="0", DEVELOPMENT="1"

These settings must be altered as a pair. When in production, an autoscaler or autoscalers are deployed and you can set NUMBER_WS. On the autoscaler machine you can modify ${HOME}/config/scalingprofile/profile.cfg to set the number of webservers to deploy and also, in the crontab, you can set ScaleUp and ScaleDown script parameters to enable a time up and time down scaling. For example, you might scale up to 5 webservers at 7:30 AM each morning using the crontab in expectation of daily usage and scale back down to (not less than 2) for resilence at 11:30 in anticipation of a quiet night. 

-----

### NUMBER_WS

This will set the number of webservers to deploy by default. If you set this to 3, for example, then 3 webservers will be spun up by default

-----

### SUPERSAFE_WEBROOT

Ordinarily, backups are made to the git repository provider that your application sourcecode is hosted with. These can be HOURLY, DAILY, WEEKLY, MONTHLY, BIMONTHLY.

This can have 3 settings:

0: Make a backup of the webroot to the application git repository only  (NOT RECOMMENDED)   
1: Make a backup of the webroot to the application git repository and the S3 datastore (this is the supersafe and recommended option)    
2: Make a backup of the webroot to the S3 datastore only (this is recommended if you have a very large codebase - there is a size limit on a git repository)  

You can have a 3 way backup strategy if you are very paranoid. You can use the native backup service of your VPS provider and you can chose option 1 here and have two backups one in your git repository and one in your S3 datastore. When your application is being built at deployment time the git repo takes precidence over the S3 datastore. If no application webroot is found in the git repo then the S3 datastore is checked. 

You can also setup backup procedures native to your cloud hosting provider's platform which will give you backup, backup and backup again security

-----
### SUPERSAFE_DB

This is the same as SUPERSAFE_WEBROOT, but, for your application database files. SUPERSAFE_DB AND SUPERSAFE_WEBROOT should be set together to either 1, 2 or 3 otherwise it might get confusing. 

This can have 3 settings:

0: Make a backup of the database to the application git repository only  (NOT RECOMMENDED BECAUSE OF REPOSITORY SIZE LIMITS - the size a file can be is limited to perhaps 50MB so if your database is bigger than that, this option won't work)  
1: Make a backup of the database to the application git repository and the S3 datastore (this is the supersafe and recommended option)    
2: Make a backup of the database to the S3 datastore only    (this is recommended if you have a very large database - there is a size limit on a git repository)   

You can have a 3 way backup strategy if you are very paranoid. You can use the native backup service of your VPS provider and you can chose option 1 here and have two backups one in your git repository and one in your S3 datastore. When your application is being built at deployment time the git repo takes precidence over the S3 datastore. If no application webroot is found in the git repo then the S3 datastore is checked. You might want to use option 2 if your application database is getting very large, if, for example, you are running a social network and its getting a lot of activity the database will get rather large. The git solution uses GitLFS to deal with large files, but, S3 services are specifically designed for large files and so are a better fit. You sacrfice supersafety for better function and in this case you definitely want your native VPS service to be making backups as well for you. 

You can also setup backup procedures native to your cloud hosting provider's platform which will give you backup, backup and backup again security

-----

### WEBSERVER_CHOICE

You have a choice of webserver that you want to deploy to. You can set this to "NGINX, "APACHE" or "LIGHTTPD". What you set this to will determine which webserver gets installed and used. 

-----

### DATABASE_INSTALLATION_TYPE

If you are installing a database on a VPS system, you have three types of database you can choose from by default. Obviously, your choice here has to be supported by your CMS system. The choices are: "Maria", "MySQL", and "Postgres" and if you are installing a managed darabase you will want to set this to DBaaS

-----

### SERVER_TIMEZONE_CONTINENT

This is the continent where your servers are located. You can get a list of continents is as follows:


```
    continents="Africa America Antarctica Arctic Asia Atlantic Australia Europe Indian Pacific"

e.g. continent="Europe"

```


-----

### SERVER_TIMEZONE_CITY

This is the city where your servers are located. You can get a list of cities by issuing the following commands where continent is from above:

```

    cities="`cd /usr/share/zoneinfo/${continent} && /usr/bin/find * -type f -or -type l | /usr/bin/sort`"

eg city="London"


```

-----

### DB_PORT

This is the port that your Database will be listening on. BE SURE that if you are using a managed database that you set this value to be the same as the port that you set when you setup the managed DB. If it is different, obviously, the scripts will not collect and things will go south. 

-----

### SSH_PORT

This is the port that the SSH daemon will be listening on for connections. You can set this as you would normally set a port. Obviously, the port you set has to be free on your server. The firewall will work with whatever setting you set and allow connections to that port. 

-----

### PERSIST_ASSETS_TO_CLOUD 

There are three settings you can use:

"0" means just use the webservers actual directories for asset storage (this will likely only be the case if you have very few assets to store). The literal webroot is used for asset storage you can't deploy multiple webservers if you use this setting because the asset files will not be shared between the webservers. If someone can think of a good way of automatically (and easily) synchronising  the asset folder of n webservers, that would be cool.  

"1" means use S3FS (or another supported solution, for example goofys) to mount assets buckets into your webserver's filesystem assets are then written directly to these services when your application stores an asset. This is suitable for production mode.   

-----

### BUILD_CHOICE

If set to "0", this means that you are installing a virgin CMS system, for example, Joomla, Wordpress, Moodle or Drupal
If set to "1", this means that you are deploying a baseline of an application you have customised (see BASELINE_DB_REPOSITORY and APPLICATION_BASELINE_SOURCECODE_REPOSITORY ) also, BUILD_ARCHIVE_CHOICE needs to be set to "baseline
If set to "2"  this means that you are deploying from an hourly backup of an application (availability dependent on DISABLE_HOURLY)
if set to "3", this means that you are deploying from a daily backup of an application
If set to "4"  this means that you are deploying from a weekly backup of an application
If set to "5"  this means that you are deploying from a monthly backup of an application
If set to "6"  this means that you are deploying from a bimonthly backup of an application

As long as you have backups in place, you can use this setting to roll back to a backup from up to two months previously, if you had some need to. 

----- 

### BASELINE_DB_REPOSITORY

When you baseline your application database, you will need to create a repository <unique_identifier>-db-baseline. From here your baseline will be pulled during installation. 
If for example, your unique identifier is "wordydemo", then, the repository would be "wordydemo-db-baseline" and 

BASELINE_DB_REPOSITORY would be set to "wordydemo-db-baseline"

-----

### APPLICATION_BASELINE_SOURCECODE_REPOSITORY

When you baseline your application sourcecode, you will need to create a repository <unique_identifier>-webroot-sourcecode-baseline. From here your baseline will be pulled during installation. 

If for example, your unique identifier is "wordydemo", then, APPLICATION_BASELINE_SOURCECODE_REPOSITORY would be "wordydemo-webroot-sourcecode-baseline" 

-----

### BUILD_ARCHIVE_CHOICE

You need to set BUILD_ARCHIVE_CHOICE based on where you are deploying from. The settings can be as follows for each option:  

 BUILD_ARCHIVE_CHOICE="baseline"  
 BUILD_ARCHIVE_CHOICE="hourly"  
 BUILD_ARCHIVE_CHOICE="daily"  
 BUILD_ARCHIVE_CHOICE="weekly"  
 BUILD_ARCHIVE_CHOICE="monthly"  
 BUILD_ARCHIVE_CHOICE="bimonthly"

-----

### APPLICATION_LANGUAGE

You can set this to "HTML" or "PHP" based on the language you are deploying for.

------

### PHP_VERSION

If you are deploying PHP, then you can set which version of PHP you are deploying here. Ordinarily, it should be the latest available version (currently 7.4).
So, to use 7.4 you would set PHP_VERSION="7.4"

-------------

### REGION

This is the region id where you wish to deploy the servers to.

Available region ids to choose from for each provider are:

Digital Ocean: Available region IDs you can set for digital ocean are: "nyc1","sfo1","nyc2","ams2","sgp1","lon1","nyc3","ams3","fra1","tor1","sfo2","blr1","sfo3"  

Exoscale: Available region IDs you can set for exoscale are:  "ch-gva-2", "ch-dk-2", "at-vie-1", "de-fra-1", "bg-sof-1", "de-muc-1"   

Linode: Available regions you can set for linode are: "ap-west", "ca-central", "ap-southeast", "us-iad", "us-ord", "fr-par", "us-sea", "br-gru", "nl-ams", "se-sto", "es-mad", "in-maa", "jp-osa", "it-mil", "us-mia", "id-cgk", "us-lax", "gb-lon", "au-mel", "us-central", "us-west", "us-southeast", "us-east", "eu-west", "ap-south", "eu-central", "ap-northeast" 

Vultr: Available regions you can set for vultr are:  "ams","atl","cdg","dfw","ewr","fra","icn","lax","lhr","mex","mia","nrt","ord","sea","sgp","sjc","sto","syd","yto"  


----------

### DB_SIZE 
### AS_SIZE 
### WS_SIZE

For the Database, the autoscaler and the webserver, you can set their individual sizes using these parameters.

Available sizes to choose from are:

Digital Ocean: s-1vcpu-512mb-10gb s-1vcpu-1gb s-1vcpu-1gb-amd s-1vcpu-1gb-intel s-1vcpu-1gb-35gb-intel s-1vcpu-2gb s-1vcpu-2gb-amd s-1vcpu-2gb-intel s-1vcpu-2gb-70gb-intel s-2vcpu-2gb s-2vcpu-2gb-amd s-2vcpu-2gb-intel s-2vcpu-2gb-90gb-intel s-2vcpu-4gb s-2vcpu-4gb-amd s-2vcpu-4gb-intel s-2vcpu-4gb-120gb-intel s-2vcpu-8gb-amd c-2 c2-2vcpu-4gb s-2vcpu-8gb-160gb-intel s-4vcpu-8gb s-4vcpu-8gb-amd s-4vcpu-8gb-intel g-2vcpu-8gb s-4vcpu-8gb-240gb-intel gd-2vcpu-8gb g-2vcpu-8gb-intel gd-2vcpu-8gb-intel s-4vcpu-16gb-amd m-2vcpu-16gb c-4 c2-4vcpu-8gb s-4vcpu-16gb-320gb-intel s-8vcpu-16gb m3-2vcpu-16gb c-4-intel s-8vcpu-16gb-amd s-8vcpu-16gb-intel c2-4vcpu-8gb-intel g-4vcpu-16gb s-8vcpu-16gb-480gb-intel so-2vcpu-16gb m6-2vcpu-16gb gd-4vcpu-16gb g-4vcpu-16gb-intel gd-4vcpu-16gb-intel so1_5-2vcpu-16gb s-8vcpu-32gb-amd m-4vcpu-32gb c-8 c2-8vcpu-16gb s-8vcpu-32gb-640gb-intel m3-4vcpu-32gb c-8-intel c2-8vcpu-16gb-intel g-8vcpu-32gb so-4vcpu-32gb m6-4vcpu-32gb gd-8vcpu-32gb g-8vcpu-32gb-intel gd-8vcpu-32gb-intel so1_5-4vcpu-32gb m-8vcpu-64gb c-16 c2-16vcpu-32gb m3-8vcpu-64gb c-16-intel c2-16vcpu-32gb-intel g-16vcpu-64gb so-8vcpu-64gb m6-8vcpu-64gb gd-16vcpu-64gb g-16vcpu-64gb-intel gd-16vcpu-64gb-intel so1_5-8vcpu-64gb m-16vcpu-128gb c-32 c2-32vcpu-64gb m3-16vcpu-128gb c-32-intel c2-32vcpu-64gb-intel c-48 m-24vcpu-192gb g-32vcpu-128gb so-16vcpu-128gb m6-16vcpu-128gb gd-32vcpu-128gb c2-48vcpu-96gb g-32vcpu-128gb-intel m3-24vcpu-192gb g-40vcpu-160gb gd-32vcpu-128gb-intel so1_5-16vcpu-128gb c-48-intel m-32vcpu-256gb gd-40vcpu-160gb c2-48vcpu-96gb-intel so-24vcpu-192gb m6-24vcpu-192gb m3-32vcpu-256gb g-48vcpu-192gb-intel gd-48vcpu-192gb-intel so1_5-24vcpu-192gb so-32vcpu-256gb m6-32vcpu-256gb so1_5-32vcpu-256gb

Exoscale: micro,tiny,small,medium,large,extra-large,huge,mega,titan,jumbo,colossus

Linode: g6-nanode-1,g6-standard-1,g6-standard-2,g6-standard-4,g6-standard-6,g6-standard-8,g6-standard-16,g6-standard-20,g6-standard-24,g6-standard-32

Vultr: Available sizes you can set for your machines on vultr are: vc2-1c-1gb, vc2-1c-2gb, vc2-2c-4gb, vc2-4c-8gb, vc2-6c-16gb, vc2-8c-32gb



-------

### DB_SERVER_TYPE 
### AS_SERVER_TYPE 
### WS_SERVER_TYPE

For each machine size SIZE it needs to have the appropriate machine type set. The following machine types correspond to the appropriate _SIZE parameter directly above

DigitalOcean: s-1vcpu-512mb-10gb s-1vcpu-1gb s-1vcpu-1gb-amd s-1vcpu-1gb-intel s-1vcpu-1gb-35gb-intel s-1vcpu-2gb s-1vcpu-2gb-amd s-1vcpu-2gb-intel s-1vcpu-2gb-70gb-intel s-2vcpu-2gb s-2vcpu-2gb-amd s-2vcpu-2gb-intel s-2vcpu-2gb-90gb-intel s-2vcpu-4gb s-2vcpu-4gb-amd s-2vcpu-4gb-intel s-2vcpu-4gb-120gb-intel s-2vcpu-8gb-amd c-2 c2-2vcpu-4gb s-2vcpu-8gb-160gb-intel s-4vcpu-8gb s-4vcpu-8gb-amd s-4vcpu-8gb-intel g-2vcpu-8gb s-4vcpu-8gb-240gb-intel gd-2vcpu-8gb g-2vcpu-8gb-intel gd-2vcpu-8gb-intel s-4vcpu-16gb-amd m-2vcpu-16gb c-4 c2-4vcpu-8gb s-4vcpu-16gb-320gb-intel s-8vcpu-16gb m3-2vcpu-16gb c-4-intel s-8vcpu-16gb-amd s-8vcpu-16gb-intel c2-4vcpu-8gb-intel g-4vcpu-16gb s-8vcpu-16gb-480gb-intel so-2vcpu-16gb m6-2vcpu-16gb gd-4vcpu-16gb g-4vcpu-16gb-intel gd-4vcpu-16gb-intel so1_5-2vcpu-16gb s-8vcpu-32gb-amd m-4vcpu-32gb c-8 c2-8vcpu-16gb s-8vcpu-32gb-640gb-intel m3-4vcpu-32gb c-8-intel c2-8vcpu-16gb-intel g-8vcpu-32gb so-4vcpu-32gb m6-4vcpu-32gb gd-8vcpu-32gb g-8vcpu-32gb-intel gd-8vcpu-32gb-intel so1_5-4vcpu-32gb m-8vcpu-64gb c-16 c2-16vcpu-32gb m3-8vcpu-64gb c-16-intel c2-16vcpu-32gb-intel g-16vcpu-64gb so-8vcpu-64gb m6-8vcpu-64gb gd-16vcpu-64gb g-16vcpu-64gb-intel gd-16vcpu-64gb-intel so1_5-8vcpu-64gb m-16vcpu-128gb c-32 c2-32vcpu-64gb m3-16vcpu-128gb c-32-intel c2-32vcpu-64gb-intel c-48 m-24vcpu-192gb g-32vcpu-128gb so-16vcpu-128gb m6-16vcpu-128gb gd-32vcpu-128gb c2-48vcpu-96gb g-32vcpu-128gb-intel m3-24vcpu-192gb g-40vcpu-160gb gd-32vcpu-128gb-intel so1_5-16vcpu-128gb c-48-intel m-32vcpu-256gb gd-40vcpu-160gb c2-48vcpu-96gb-intel so-24vcpu-192gb m6-24vcpu-192gb m3-32vcpu-256gb g-48vcpu-192gb-intel gd-48vcpu-192gb-intel so1_5-24vcpu-192gb so-32vcpu-256gb m6-32vcpu-256gb so1_5-32vcpu-256gb 

Exoscale: micro,tiny,small,medium,large,extra-large,huge,mega,titan,jumbo,colossus

Linode: g6-nanode-1,g6-standard-1,g6-standard-2,g6-standard-4,g6-standard-6,g6-standard-8,g6-standard-16,g6-standard-20,g6-standard-24,g6-standard-32

Vultr: vc2-1c-1gb, vc2-1c-2gb, vc2-2c-4gb, vc2-4c-8gb, vc2-6c-16gb, vc2-8c-32gb

---------

### CLOUDHOST

This is the cloudhost you are deploying to. The current choices are:

"digitalocean", "exoscale", "linode", "vultr", "aws"

You can set the cloudhost to Digital Ocean, for example by setting the CLOUDHOST variable as CLOUDHOST="digitalocean"

---------

### MACHINE_TYPE

This is just an identifier which we can check for on our servers. It can be set to

"DROPLET", "EXOSCALE", "LINODE", "VULTR"

------------

### ALGORITHM

This is the algorithm that the ssh uses to form connections it can be set to "rsa", or, "ecdsa"

------

### USER

This is the user that the scripts is running as. It can be set, as, USER="root" and so on

--------

### ACTIVE_FIREWALLS

This will set which (if any) firewalls are active on your machines
 0 - No active firewalls (not recommended
 1 - UFW firewall only active on all machines
 2 - Native firewall only active on all machines 
 3 - UFW and Native Firewall active on all machines (recommended) 

 NOTE: the UFW firewalls are always active on your build machine regardless of this setting for security reasons

 ------

### CLOUDHOST_USERNAME

This is the username of the for the cloudhost, it can be set - CLOUDHOST_USERNAME="root", for example
**THIS MUST BE SET FOR ALL LINODE DEPLOYMENTS. THE BUILD WILL FAIL FOR LINODE IF A CLOUDHOST_USERNAME IS NOT SET**

-------- 

### CLOUDHOST_PASSWORD

This is the password of the for the cloudhost, it can be set - CLOUDHOST_PASSWORD="password", for example
**THIS MUST BE SET FOR ALL LINODE DEPLOYMENTS. THE BUILD WILL FAIL FOR LINODE IF A CLOUDHOST_PASSWORD IS NOT SET**
**THIS MUST NOT BE SET FOR ALL AWS, DIGITALOCEAN, EXOSCALE AND VULTR DEPLOYMENTS**

----------

### CLOUDHOST_ACCOUNT_ID

This is whatever attribute you use to login to the cloudprovider portal it can be a username or an email address
This is mandatory for linode and exoscale because it is how the configuration file for the CLI tool is setup and configured. 

digitalocean - not needed  
exoscale - The email address that you use to login to the exoscale portal at www.exoscale.com  
linode - The username that you use to login to the linode portal at www.linode.com  
vultr - not needed

------

### GIT_USER 
### GIT_EMAIL_ADDRESS

These are the values for the git user that your commits are made by. Obviously, I don't know what those will be, so they are set to some placeholder values in the templates I have provided, but, you can change them to your own values, of course. These values correspong to **git config --global user.name "Template User"** and  **git config --global user.email "templateuser@dummyemailX1.com"** 

-----

### APPLICATION_REPOSITORY_TOKEN

This is a gitlab and github specific token. When you have a private application repository with gitlab or github, you need to generate a private auithorisation token.
For github, you can do this by logging into your account and going to: https://github.com/settings/tokens and then generate one
    gitlab, you can do this by logging into your account with them and clicking on Profile Settings -> Access Tokens and then generating one"
The token that you generate can be placed here in your template instead of a password (for your application repositories)

-----

### INFRASTRUCTURE_REPOSITORY_PROVIDER
### INFRASTRUCTURE_REPOSITORY_OWNER
### INFRASTRUCTURE_REPOSITORY_USERNAME
### INFRASTRUCTURE_REPOSITORY_PASSWORD

By default these values are set as shown below, if you are building from your own forks you will need to set these according to your fork's criteria 

INFRASTRUCTURE_REPOSITORY_PROVIDER="github"  

INFRASTRUCTURE_REPOSITORY_OWNER="wintersys-projects"  

INFRASTRUCTURE_REPOSITORY_USERNAME="wintersys-projects"  

INFRASTRUCTURE_REPOSITORY_PASSWORD="none"  


-----

### DATASTORE_CHOICE

This value determines who your object store provider will be (very likely the same as your compute services provider, but, doesn't have to be)
DATASTORE_CHOICE should be set to one of the following values:
  
 For DigitalOcean spaces: "digitalocean"  
 
 For Exoscale Object Store: "exoscale"  
 
 For Linode Object Store: "linode"  
 
 For Vultr Object Store: "vultr"  
 

------

### DATABASE_DBaaS_INSTALLATION_TYPE

Please review [this](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/master/doco/AgileToolkitDeployment/DeployingDBaaS.md) for how to set the shortcut values for your DBaaS provider.
Otherwise, set this value to one of "MySQL", "Maria" or "Postgres" when you have set DATABASE_INSTALLATION_TYPE to "DBaaS"

-----

### BYPASS_DB_LAYER

0 : install application as normal

1 : Don't install the application because you have already got a DBaaS running with the application installed in it from a previous build and so, use that.

-----

### APPLICATION_NAME

The APPLICATION_NAME corresponds to the APPLICATION IDENTIFIER

APPLICATION IDENTIFIER       |     APPLICATION NAME  

        1                    |    JOOMLA APPLICATION  
        
        2                    |    WORDPRESS APPLICATION  
        
        3                    |    DRUPAL APPLICATION  
        
        4                    |    MOODLE APPLICATION  
        
        
-----

### SSL_GENERATION_METHOD

This can be set to "AUTOMATIC" or "MANUAL". If it is set to automatic, then an attempt to provision an SSL certificate from an automated authority will be made. If it is set to manual, you will have to manually obtain and present your own certificate. 

-----

### SSL_GENERATION_SERVICE="LETSENCRYPT"

When SSL_GENERATION_METHOD="AUTOMATIC", this should be set to "LETSENCRYPT" otherwise it should be left blank

------

### SSL_LIVE_CERT

This will tell the toolkit whether to use live cerificates (which are subject to issuance limits) or staging certificates (which are subject to browser warnings). Live certificates should always be used in production.

if SSL_LIV£_CERT="1" then this says "generate a live (production ready) certificate
if SSL_LIVE_CERT="0" then this says "generate a staging (development mode) certificate

The templating system is set up to use live certificates by default in all cases

------

### WEBSERVER_IMAGE_ID
### AUTOSCALER_IMAGE_ID
### DATABASE_IMAGE_ID

These are the full IDs of the images that your servers will be built off if you build using snapshots you have generated.


-------

### SELECTED_TEMPLATE

When you are making a "hardcore" build, you need to supply the number of the template you are generating a script for, for example, "1", "2", "3"

-----------

### INSTALL_MONITORING_GEAR  

You can set the value to 0 or 1 to install monitoring gear and indicate which of the supported monitoring software you want to install. Currenlty supported are "glances", "nmon", "atop" and "native". "native" is only currently available on digitalocean but you are welcome to update the scripts.

You can find learn about [glances](https://github.com/nicolargo/glances).

Your available settings then are:

0 (do not install monitoring gear) and

1 (install monitoring gear)

1|glances (install glances)
1|native (install native - digital ocean only)
1|nmon
1|atop

-------------
### INPARALLEL

Whether to build the machines you are deploying in paralel or not on the build machine. If you build them in parallel they will build quicker but it might not be so easy to see what is going on.

0 Do not build in parallel
1 Build in parallel

-------------
### NO_AUTOSCALERS

How many autoscalers to deploy. An Interger value between 0 and 5
