On each of the servers is a file which contains all the live configuration settings for the toolkit. It is accessed very often by the scripts.

On the autoscaler it is called **${HOME}/.ssh/autoscaler_configuration_settings.dat**  
On the webserver it is called **${HOME}/.ssh/webserver_configuration_settings.dat**  
On the database it is called **${HOME}/.ssh/database_configuration_settings.dat** 

The values of the variables in these files was set when you made the deployment. If you wanted to change one of these settings, say you wanted to switch on super safe backups when you deployed it with it switched off or you wanted to make a backup to a different git repository, you can alter the settings here and the scripts will pick them up.
You have to know what you are doing, but, I am just showing you here that it is possible to change the operation after deployment. You need to reference the [spec](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/master/templatedconfigurations/specification.md) to find out what each variable in these files is for. 
