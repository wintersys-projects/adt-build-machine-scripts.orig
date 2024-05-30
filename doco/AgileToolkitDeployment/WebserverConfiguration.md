I have designed the way that webserver configuration files are set up in way that they can be easily customised on a webserver by webserver basis and an application by application basis. 

Your live config files are used by the relevant scripts:

>     ${HOME}/providerscripts/webserver/configuration/Install<webserver>ConfigurationFromRepo.sh
>     ${HOME}/providerscripts/webserver/configuration/Install<webserver>ConfigurationFromSource.sh


>     ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/${WEBSERVER}/online/repo/liveconfigfiles
>     ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/${WEBSERVER}/online/source/liveconfigfiles

Sets of alternative config scripts can be kept in the offline directory such as:


>     ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/${WEBSERVER}/offline/configfilesset1/configfiles
>     ${HOME}/providerscripts/webserver/configuration/${APPLICATION}/${WEBSERVER}/offline/configfilesset2/configfiles

To make a set of offline scripts live simply move the currently online scripts to an offline directory and move the offline scripts that you want to make online to the online directory. 

This is how you can have plug and play configurations for different deployments. To be as extensible as possible, I don't know what applications anyone might want to configure to deploy with this toolkit in the furture, maybe humhub or nextcloud and so on and by separating configuration files out on an application by application basis any customisations you want to apply for any future application you can bake right in to the config fileset for that application. 
