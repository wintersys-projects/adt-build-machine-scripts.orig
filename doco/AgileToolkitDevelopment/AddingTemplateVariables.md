If you wanted to add a new variable to the templates in service to a new feature you have built then you can add the variable in the following way:  

On the build machine repository, add the new variable to 

>      ${BUILD_HOME}/builddescriptors/envdump.dat
  
To make the new variable available to the autoscaler,on the build machine repository, add the new variable to 

>      ${BUILD_HOME}/builddescriptors/autoscalerscp.dat

To make the new variable available to the webserver on the build machine repository, add the new variable to 

>      ${BUILD_HOME}/builddescriptors/webserverscp.dat
  
To make the new variable available to the database on the build machine repository, add the new variable to 

>      ${BUILD_HOME}/builddescriptors/databasescp.dat  

NOTE: there needs to be an empty line at the end of each file so that all of the lines are read by the script

It is then a development task as to how to access the values of these variables which are stored in

>      ${HOME}/.ssh/autoscaler_configuration_settings.dat on the autoscaler 
>      ${HOME}/.ssh/webserver_configuration_settings.dat on the autoscaler   

>      ${HOME}/.ssh/webserver_configuration_settings.dat on the webserver  

>      ${HOME}/.ssh/database_configuration_settings.dat on the database  
