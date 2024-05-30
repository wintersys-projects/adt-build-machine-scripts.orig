The deployment process is designed as a build chain.  

What I mean by this is you can chain together different combinations of "nodes" in the build chain.  

The "standard" buildchain is "autoscaler, webserver, database" and it is expected that most applications will build out that combination of "nodes".  

Using the file 

>      ${BUILD_HOME}/builddescriptors/buildstylescp.dat  

You can define what buildchain you want to deploy.  

By defining a build chain of "webserver" you can build only a webserver which you might want to do if you were developing a static site which doesn't use a database  

By defining a build chain of "database" you can build only a database if you wanted some easy way to deploy a database for remote usage. You would have to punch holes in the firewalls (native and os) to be able to access your database from a remote machine(s).  

Further more you as a developer you can define different node types. The current node types are "BuildAutoscaler". "BuildWebsever". "BuildDatabase" but you could also define one, for example, "BuildCaching" and write a script to build out a caching system which you application can use such as by installing redis or memcached on a VPS machine.  
