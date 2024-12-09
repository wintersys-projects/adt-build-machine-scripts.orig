Some ideas for how this work could be enhanced/extended

1. I am not an expert in configuring apache,nginx, and in particular lighttpd. If you are an expert in any of these technologies I would be happy for you to review what I have done to configure these softwares by default which work but it might be possible to have them work better in the hands of an expert.
The relevant files are: [Apache](https://github.com/wintersys-projects/adt-webserver-scripts/blob/master/providerscripts/webserver/configuration/InstallApache.sh) [Nginx](https://github.com/wintersys-projects/adt-webserver-scripts/blob/master/providerscripts/webserver/configuration/InstallNginx.sh) [Lighttpd](https://github.com/wintersys-projects/adt-webserver-scripts/blob/master/providerscripts/webserver/configuration/InstallLighttpd.sh)

3. The toolkit can be forked and extended to support additional PHP applications such as Nextcloud or hubzilla or Elgg or other PHP frameworks. There's many many PHP applications out there which would be cool to support and possibly quite fun to integrate into the tookit.
4. The toolkit can be forked and extended to suport other hosting providers such as upcloud, AWS, or google cloud
5. It would be nice to fork and extend the toolkit to support openlitespeed as a webserver
6. This toolkit is not tied to only supporting PHP. As it stands the base language is PHP but by changing the APPLICATION_LANGUAGE which is installed to be. for example, Java or NodeJS then the toolkit could be expanded beyond PHP to support, for example, tomcat or strapi CMS or ruby on rails
7. General additional provider support such as integrating new SMTP mail service providers or a currently unsupported DNS system like route53. 
8. Add support for dynamic scaling in addition to the static scaling which is provided by default. Something like: 
/usr/bin/sar 1 1 | /usr/bin/tail -n -1 | /usr/bin/awk '{print $NF}' | /usr/bin/xargs printf "%.*f\n" "$p"  can be used to get the load on the webservers and make a decision whether to spawn new ones or not based on load matrics. 
9. The core toolkit supports 3 server types, the Autoscaler class of machine, the webserver class of machine and the database class of machine. The toolkit is structured such that it is easy to integrate other types of machines or servers if you wanted to, for example you could develop an email server if you wanted to roll your own email server solution and put that into the deployment chain if you chose to or you could have an application server (such as Tomcat if you wanted to take this toolkit beyond just PHP support) and so on. The toolkit is designed not to be limited to just 3 classes of machines and you are free to extend it in such a way if you chose to and then writing a new build chain to define the build sequence of your machine types.
10. Provide an option to install phpmyadmin for managing the database and database tables.
11. Originally the core supported AWS but I found I had to make various AWS specific customisations so I stripped AWS out of the core to keep the core as simple and consistent as possible. If you want to put the work in to add support for AWS, then, you might get some clues from my archived repositories which you can find below:

[build-machine-with-aws](https://github.com/wintersys-projects/adt-build-machine-scripts-withaws)  
[autoscaler-with-aws](https://github.com/wintersys-projects/adt-autoscaler-scripts-withaws)  
[webserver-with-aws](https://github.com/wintersys-projects/adt-webserver-scripts-withaws)  
[database-with-aws](https://github.com/wintersys-projects/adt-database-scripts-withaws)  

12. All of the providers support VPC usage but for Linode I had a problem where I couldn't obtain the private ip address of the machines being added to the VPC so I just fell back to their traditional public and private ip address solution or "private networking" solution. This has the proviso that the 192.168 private ip addresses are accessible (can be pinged) to all customer machines in that region. It would be cool if someone with more knowledge of the linode VPC system could work out how to get the ip addresses as required by this toolkit of machines that have joined a particular VPC. 


