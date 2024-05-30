### THE GUARDIAN GATEWAY

I'm not sure anyone will use this in earnest but you might want to use it to protect the administrator area of your CMS application, for example, so that anyone who wants to access the administrator area of, say, joomla, has to pass the basicauth requirements that you have set up using this mechanism. Its possible that that may make your CMS application that little bit more secure. 

The guardian gateway part of the toolkit enables you to configure your deployment so that sensitive directories of your application are protected using the "basic auth" mechanism built into your browser.

What this means is that to access protected directories a user will need a username and a password before they can even get to the CMS application itself. 

The way I have set this up is I use the same username for the gateway guardian as the user has for the CMS application they are trying to access. So, for example, if your username is, "Ethel123" for, say, Joomla, Wordpress, Drupal or Moodle that you are trying to access, then, your username for "basic auth" will be "Ethel123" also. The way the system works is it is set up to generate a random password for you when you first register with the site you are trying to access and it sends you your password by email. It doesn't have to be massively secure, it is only the first line of defence and it should cause at least some problems for bad actors.

----------------------

#### IMPORTANT NOTE FOR DEVELOPERS:

I generate the gateway guardian credentials from the application database and the problem with this is that some applications have empty user tables by default. To get round this, I create a "bootstrap_user" which you can use to get past the "gateway guardian" when you are installing the CMS. To find out the username and password of the cases where its needed during a fresh installation, you can ssh onto your build machine and issue the following command

##### /usr/bin/s3cmd get s3://gatewayguardian-${BUILD_IDENTIFIER}/htpasswd_plaintext_history

this will create a file **./htpasswd_plaintext_history** which you can look for the  bootstrap_user in. The format will be something like:

**LIVE:   bootstrap_user:ek+60uLrksm2Aw==:bootstrap@dummyemail.com**

In this case, the username you want to put into the guardian gateway dialogue is: **bootstrap_user** and the password is: **ek+60uLrksm2Aw==**

---------------------------------

Ordinarily, then, when you are prompted with a "basic auth" dialog as a regular user, you would use your application username and the password which has been sent to you by email. Getting past basic auth would grant you access to the CMS system.

As the technical person using this toolkit you will find a commented out option in the crontab of your database server with a @weekly periodicity to run the GatewayGuardian.sh shell script. 

You can uncoment this and vary the periodicity if you want to and what this will do is generate new passwords for the basic auth mechanism (and email them to the email your users have registered to the CMS with) and the next time they come to your site they will need to check their email and enter their new username and password to get past the basic auth mechanism. This requires that the users understand that they need to do this. You don't have to have this switched on you can set the user's password when they first registered and make it everlasting but if you want to be as secure as possible about it setting new passwords periodically is the advisory from security specialists. As you know increased security is stalked by decreased usability in almost all cases. 

-------------------------------

You can find the "live" passwords for the users of the Gateway Guardian mechanism in two places:

1. On your database server you can find your live passwords in the following file:

##### ${HOME}/runtime/credentials/htpasswd_plaintext_history

2. In your datastore in a bucket called:

#####  s3://gatewayguardian-${BUILD_IDENTIFIER}

----------------------------------

By default, when you enable "Gateway Guardian", it protects the administation directories so, for joomla that would be, "/administrator" and for wordpress that would be "/wp-admin" and so anyone wanting to access those directories will need to pass basic auth.

The whole point of this, though is to set up basic auth so that users can't access your application at all without getting past basic auth by configuring it to use the protect the webroot directory "/var/www/html".

You can do this by altering the directories that the basic auth is active for in these files in your fork of the build kit:

-----------
### For APACHE:  

##### ${HOME}/providerscripts/webserver/configuration/joomla/apache/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/joomla/apache/online/source/gatewayguardian.conf

and for **Joomla**, alter:

**/bin/echo "    <Directory /var/www/html/administrator>**

to 

**/bin/echo "    <Directory /var/www/html/>**

and for **Wordpress**, alter:

##### ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/wordpress/apache/online/source/gatewayguardian.conf

**/bin/echo "    <Directory /var/www/html/wp-admin>**

to 

**/bin/echo "    <Directory /var/www/html/>**

and for **Moodle**, alter:

##### ${HOME}/providerscripts/webserver/configuration/moodle/apache/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/moodle/apache/online/source/gatewayguardian.conf

**/bin/echo "    <Directory /var/www/html/moodle/admin>**

to 

**/bin/echo "    <Directory /var/www/html/moodle/>**

and for **Drupal**, alter:

##### ${HOME}/providerscripts/webserver/configuration/drupal/apache/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/drupal/apache/online/source/gatewayguardian.conf

**/bin/echo "    <Directory /var/www/html/>**

to 

**/bin/echo "    <Directory /var/www/html>**

NOTE: Because of the way drupal works I couldn't get this mechanism to work satisfactorily with drupal admin. The only solution is to gateway the whole of drupal but it means your users won't be able to register at all. This is fine if its an administrative task to register users for your site rather than a user task but it won't work if you are wanting used to be free to register with your application. 

----------------
### For NGINX:  

##### ${HOME}/providerscripts/webserver/configuration/joomla/nginx/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/joomla/nginx/online/source/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/wordpress/nginx/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/wordpress/nginx/online/source/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/moodle/nginx/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/moodle/nginx/online/source/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/drupal/nginx/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/drupal/nginx/online/source/gatewayguardian.conf

and follow a similar process as described above for apache

-----------------

### For LIGHTTPD:

##### ${HOME}/providerscripts/webserver/configuration/joomla/lighttpd/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/joomla/lighttpd/online/source/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/wordpress/lighttpd/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/wordpress/lighttpd/online/source/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/moodle/lighttpd/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/moodle/lighttpd/online/source/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/drupal/lighttpd/online/repo/gatewayguardian.conf
##### ${HOME}/providerscripts/webserver/configuration/drupal/lighttpd/online/source/gatewayguardian.conf

and follow a similar process as described above for apache


