1. From the hosting provider where your website is currently hosted make a tar backup of the webroot of your website and call it something like webroot.tar.gz

2. Similarly from the host where your website is currently hosted take a database dump using a tool like mysqldump for mysql or pg_dump for postgres and call it "database_archive.sql" look into the sql file and take a note from it of the database prefix that is in use and write it down or store it in a text file

3. Copy both files to the directory

>      ${BUILD_HOME}/migrations/

on the build machine that you are deploying your servers (running the agile deployment toolkit build process) from.

4. Deploy a Virgin install of whichever CMS type your application is using the ADT. Don't go the whole way, you shouldn't be doing anything with the GUI system at all unless its just to check that the website is responsive. No GUI based installation steps should be followed. If its a Joomla website deploy a virgin joomla installation similarly you need a virgin installation of wordpress, drupal or moodle if your website with your original host has one of those as its CMS type. 

5. Once the machines are up and running use the helper scripts "CopyToWebserver.sh" and "CopyToDatabase.sh" to copy the files from 3 to your webserver's ${HOME}/migration directory and your database server's ${HOME}/migration directory respectively

6. On the webserver untar into the migrations directory (&#0036;{HOME}/migrations)the archive of your original site's webroot once that is done. The DNS name that you use for your new website must be the same as the DNS name was for your old website. You can't be migrating to a different DNS name just yet. That will come later so you might need to swap your DNS name to a different provider if your DNS provider is not the same now (cloudflare for example) as it was before. 

7. Now you should have an extracted webroot in a subdirectory of &#0036;HOME/migration on your webserver. With your new webroot on you can make it a live webroot as follows:

Delete the configuration file from your new webroot it might be something like  &#0036;HOME/migration/extraction/configuration.php that came with your migration, for example, configuration.php for joomla or config.php for wordpress. These files will contain old database information and so on which you don't want any more. 

>      /bin/mv /var/www/html /var/www/html.old 
>      /bin/mkdir /var/www/html

and from the root directory of your newly extracted webroot somewhere in &#0036;HOME/migration you can 

>      /bin/mv * /var/www/html

You then need to issue the command:  

>      run ${HOME}/providerscripts/utilities/EnforcePermissions.sh

Get the IP address of your database server by 

8. Lets turn our attention to the database machine now. From step 5 you have the database sql file in your &#0036;HOME/migration directory. With this new database dump you can use whichever script is relevant below:

>     run ${HOME}/utilties/ConnectToMySQLDB.sh (for mysql) or
>     run ${HOME}/utilities/ConnecToPostgresDB.sh (for postgres)

   and then, you need to provide the database dump to the script so full commands would be something like:

>     run ${HOME}/utilties/ConnectToMySQLDB.sh < &#0036;HOME/migrations/database_archive.sql

   If it all runs successfully your database from your original hosting provider is now imported into your database and we can go back to the webserver to take some final steps to bring our new application online

   One final thing to do on the database server is to get its IP address and making a note of it which you can so by issuing the command:

>     ${HOME}/providerscripts/utilities/GetIP.sh

   and you also need to make a note of what port your database machine is running on which you can do by looking for the value DBPORT in 
   
>     ${HOME}/.ssh/database_configuration_settings.dat

9. On your webserver change the value of BUILDARCHIVECHOICE in file

>      ${HOME}/.ssh/webserver_configuration_settings.dat from "BUILDARCHIVECHOICE:virgin" to "BUILDARCHIVECHOICE:baseline"

10. Go to &#0036;{HOME}/runtime and select the correspoding configuration file joomla's is "joomla_configuration.php" and find and change the database prefix (is probably set to jos_ for joomla) to be ther value of the database prefix that you saved in step 2. You also need to change the ip address of the database and if necessary the port that the database is running on (you made a note of them both at the end of step 8.

     Once you have done that, run the script /usr/bin/config and wait a couple of minutes and then go to step 12

11. Check that your new website is online and make a baselines of the webroot and database by following [how to baseline](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/master/doco/AgileToolkitDeployment/BaselinesAndBackups.md)
    
12. Once you have made baselines you can deploy them with different DNS settings and in 12 steps or so you have migrated to us from your old provider. 
