1. All the DNS A records are deleted as part of the initial build process. If you use Cloudflare, if a 3rd party (script maybe) or yourself navigates to your live URL whilst all A records are deleted they/you will be served an NXRecord which basically means that there is no record for that domain.
THE NXRecord seems to be cached and it may cause an issue with SSL certificate issuance. In this case, you will see an error message with NXRecord in the message body and the build process will terminate. The solution is to wait for the caching to clear so that the NXRecord is no longer being served and restart the build process. Under normal operation, this should not happen.  

2. To shutdown your infrastructure it is important not to simply shutdown the machines using a provider's GUI system or the cli tools. There's a script in the **helperscripts** directory called **ShutdownInfrastructure.sh** which you must run each time you want to shut your system down. This gives the machines a chance to clean up, make backups and so on which means that your data will be consistent. If your application is online and you need to shutdown your servers for some reason, then, if your most recent backup was 1 hour ago then if you don't make a "shutdown" backup then there's the potential for an hour's worth of data to be lost, worse still if you only make daily backups. This is why it is ESSENTIAL that you shutdown using the helperscripts. 

3. If you are using Cloudflare as your DNS Service provider, you need to, at a minimum, switch on 'Full SSL' and also, you need to create a page rule which directs all calls to http://www.website.com to https://www.website.com. This way, you can be sure that all your requests are being issued securly. Also, when you are in development mode, letsencrypt will issue a "testing" certificate which Cloudflare will not accept in "strict mode". If you drop it back down to "full" during development and up to "strict" once you are ready for production (which doesn't using the staging SSL certificates that strict mode doesn't like), this should allow you to make most efficient use of the certificate issuing process. 

4. Remember if you change from deploying to one DNS service and choose another, you will have to change the nameservers with the service you bought your domain names. This is called a "Nameserver update" and has a propagation delay of up to 48 hrs before your webproperty will be accessible through the new nameservers. 

5. Advised best practice is to rotate your ssh keys. The simplest way to do that with this toolkit is simply to set aside a maintenance window, take your deployment down and redeploy. 

6. If you want to customise the configuration of your webserver, you can easily do it by altering the scripts in

**Agile-Infrastructure-Webserver-Scripts/providerscripts/webserver/configuration/**

7. To alter your test database configuration, you can modify the file:

**Agile-Infrastructure-Database-Scripts/providerscripts/database/singledb/mariadb/InitialiseMariaDB.sh** for Maria DB
 
 and the file
 
**Agile-Infrastructure-Database-Scripts/providerscripts/database/singledb/postgres/InitialisePostgresDB.sh** for Postgres
 
8. If you want to monitor your application uptime, I recommend uptime robot www.uptimerobot.com

9. If you are using s3fs for your shared storage, then, if you delete the buckets using the Cloudhost provider's gui system (digital ocean at least has a period when a deleted bucket cannot be recreated) or the s3cmd tool there tends to be a period of time with some providers when buckets of the same name cannot be created again. If you run the scripts during this period and they require the same bucket name as a bucket that you have recently deleted using the GUI, you will get unpredictable behaviour. If you wait till the grace period expires, then, you will be able to complete the execution of the scripts successfully or, better yet, don't delete the buckets using the gui unless you are finished with them entirely.  

10. If you make multiple builds and have, for example, "testbuild-1", "testbuild-2" and so on, you need to name them (<identifier>-BUILD_IDENTIFIER), "1-testbuild", "2-testbuild" rather than "testbuild-1" and "testbuild-2", this is because in some places the "BUILD_IDENTIFIER" might get truncated and you would lose the distinction.    

11. When you are setting credentials for your application db during the **DBaaS** deployment process, make sure that the names/values you choose do not appear within you applications sourcecode. For example, a DB username like "admin" will likely appear in your application's sourcecode and when we do our credential switch for you during application redeployment, you will likely get unexpected substitutions going on within you application. This only applies to DBaaS installations when it is up to you to define credentials in most cases. For regular DB installs, we generate DB credentials for you, as you know. During regular database deployments the credentials are automatically generated and so, I have control of that and can make them distinct or random, but, with a DBaaS deployment it is up to you to make the credentials you use unique or non-existent strings with the source code. 

12. The Agile Deployment Toolkit supports the following application database:

##### Joomla 4 using MySQL, MariaDB is supported  
##### Wordpress using MySQL or MariaDB is supported (Postgres needs some faff with wordpress,but you are welcome to modify the toolkit)   
##### Drupal using MySQL, MariaDB or Postgres is supported  
##### Moodle using MySQL, MariaDB or Postgres is supported
 
NOTE: This toolkit supports Postgres database installs for some CMS systems. I just did some testing with joomla extensions and it seems like Postgres support is not as common as mysql support is (which is the default). Therefore it is recommended for maximum compatibility to use mysql rather than postgres (with the Joomla CMS at least).

13. These builds depend on external services, if a service is down, the build may well not complete.

14. If you get problems with SSL certificate issuance during a build, it is most likely because of "rate limiting". This is most likely to occur if you are using the "hardcore" build method because the other build methods reuse previously issued certificates. 

15. Be aware of firewall rules limits which are different by provider. If you had a great number of servers for some providers, the number of firewall rules might be a limiter. 

16. If you are building a deployment from snapshots, you should only deploy in the same region that the snapshots were taken in or from. In other words, if you need to deploy the snapshots to a different region you will have to regenerate them.

17. When you deploy using snapshots you will need to deploy using the same build machine configuration that the snapshot was built with. You can do this either by always deploying from the same build machine or by using a backup of the build machine that the snapshot was generated from by following: [Backup Build Machine](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/master/doco/AgileToolkitDeployment/RetrievingBuildMachineBackup.md). In other words, if you shutdown your build machine if you want to build from a previous snapshot you will have to restore from one of the backups. 

18. This toolkit is intended to by used in such a way that managed DBs are only used when making PRODUCTION deployments. When you are in development mode it is expected that you will use the database that these scripts install on your VPS servers.  
 
 19. When in production mode (multiple webservers) if you change the permissions of a file or files using chmod or chown then that file or those files will be considered to have been updated because chmod and chown refresh the creation time of a file and the system detects newly created files and assumes them to be new and therefore needed as part of the webroot syncing process. CHMOD or CHOWN on any files in /var/www/html will render them eligible as part of the webroot syncing process. This could break your setup if you did a "chown -R www.data-www.data /var/www/html as all the files in the webroot would then be eligible for the webroot syncing process.
 
 20. Remove termination protection as follows on exoscale:
 
 exo dbaas update <db-name - eg: testdb1> -z <region: eg. ch-gva-2> --termination-protection=false

 
