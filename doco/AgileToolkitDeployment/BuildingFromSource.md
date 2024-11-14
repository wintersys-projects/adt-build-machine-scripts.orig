You have the choice to build certain aspects of this toolkit from source or from the regular repositories.   

The advantage of building from source is that it gives you more control and you can use the very latest versions of software that the repos haven't caught up with yet which can be more secure. The disadvantage is that it is more complex and there is more that might go wrong and also the machines can take longer to build and deploy. 

In order to configure how you want each eligible component to be built you need to edit the file  

**${BUILD_HOME}/buiddescriptors/buildstyles.dat**  

in your fork.

The settings work as follows:

#### The set of possible configurations you could have are as follows:
-----
##### If you are building for NGINX you can select one of:
-----
##### NGINX:source:\<module1\>:\<module2\>:\<modulen\>
##### NGINX:source
##### NGINX:repo
-----
##### If you are building for APACHE you can select one of:
-----
##### APACHE:source:\<module1\>:\<module2\>:\<modulen\>
##### APACHE:source
##### APACHE:repo
-----
##### If you are building for lighttpd you can select one of:
-----
##### LIGHTTPD:source:\<module1\>:\<module2\>:\<modulen\>
##### LIGHTTPD:source
##### LIGHTTPD:repo
-----
##### If you are deploying PGOP then you can deploy it as:
-----
##### PHP:\<module1\>:\<module2\>:\<modulen\>
-----
##### If you are using S3FS for your assets you can select one of:
-----
##### DATASTOREMOUNTTOOL:s3fs:source
##### DATASTOREMOUNTTOOL:s3fs:repo
-----
##### If you are using GOOFYS for your assets you can select one of:
-----
##### DATASTOREMOUNTTOOL:goof:binary
##### DATASTOREMOUNTTOOL:goof:source
-----

Note: If you have multiple applications you are deploying then you can have different configurations for each application. 
To use different PHP configurations for 2 different applications and have the wordpress one as active you could store it then as:

##### #APPLICATION 1 (joomla)
##### #PHP:\<module1\>:\<module2\>:\<modulen\>
##### APPLICATION 2 (wordpress)
##### PHP:\<module1\>:\<module2\>:\<modulen\>

