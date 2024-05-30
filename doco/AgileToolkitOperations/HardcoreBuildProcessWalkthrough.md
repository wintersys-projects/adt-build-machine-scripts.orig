1. On your latop clone the main repository:  

>     /usr/bin/git clone https://github.com/wintersys-projects/adt-build-machine-scripts.git

2. Setup the approrpiate template with live values for the build that you want:

>     ${BUILD_HOME{/templstedconfigurations/templates/\<provider\>

3.
>     cd ./adt-build-machine-scripts/helperscripts

4. run the script GenerateOverrideScript.sh

>     /bin/sh ./GenerateOverrideScript.sh

5. When you run the script answer the initial questions which would look like this if you were deploying a temporal build template for linode:

>      root@localhost:/home/agile-deployer/adt-build-machine-scripts/helperscripts# sh GenerateOverride.sh
>      ############################################################################################################
>      WARNING: THERE IS NO SANITY CHECKING IF YOU USE THIS SCRIPT WHICH MEANS THAT IF YOU ENTER ANYTHING INCORRECT
>      YOU WON'T FIND OUT ABOUT IT UNTIL YOU CONFIGURE A BUILD USING THE OUTPUT FROM THIS SCRIPT AND THE BUILD FAILS
>      AT THE END, THIS SCRIPT WILL OUTPUT ITS CONFIGURATION AND YOU CAN TAKE A COPY OF THE OUTPUT AND STORE IT ON YOUR LAPTOP OR DESKTOP
>      FOR USE IN CURRENT AND FUTURE DEPLOYMENTS
>      BE AWARE THAT THE OUTPUT GENERATED WILL CONTAIN SENSITIVE INFORMATION WHICH YOU NEED TO KEEP SECURE
>      ############################################################################################################
>      Press <enter> to continue
>
>      Which Cloudhost are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr. Please Enter the number for your cloudhost  
>      3
>      Please tell us which template you wish to override
>      1.                   VIRGIN DEVELOPMENT MODE INSTALLATION OF JOOMLA, WORDPRESS, DRUPAL or MOODLE
>      2.                   BASELINED DEVELOPMENT MODE DEPLOY OF A BASELINED JOOMLA WORDPRESS DRUPAL OR MOODLE APPLICATION
>      3.                   TEMPORAL PRODUCTION MODE DEPLOY OF A BACKED UP JOOMLA WORDPRESS DRUPAL OR MOODLE APPLICATION  
>      Please input a number between 1 and 3 to select a template to override
>      3
>      ###############################################################################
>       YOU NEED TO SET ALL OF THESE VARIABLES TO SANE VALUES FOR THE BUILD TO FUNCTION
>       ###############################################################################
>       Press <enter to begin>

When you are ready press \<enter\> to review the values that you have set for your build process.

6. Answer all the questions taking the time to review the values that the script is saying are set for your selected template and that they are correct. The second half of the process will give you an option to skip the interactive review process if you are confident that the values set in your selected template are correct and this will make this process faster if you are.

7. Once this script has finished running, you will need to run a second script

>     cd ${BUILD_HOME}/helperscripts
>     /bin/sh GenerateHardcoreUserdata.sh

   This will generate a script of a name that you choose in for example ${BUILD_HOME}/userdata/testuserdatascript

   You can reiiew this script.

8. What you will then need to do is follow the exact same steps as for the Expedited Build Process described [here](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/doco/AgileToolkitOperations/ExpeditedBuildProcessWalkthrough.md) except for step 1 you paste the script that you generated in step7 
 
>     ${BUILD_HOME}/userdata/testuserdatascript)

into the cloud-init of the build-machine rather than the override script that those instructions suggest. What this will do will automatically run the full build without any interaction. You can follow the build on the build-machine by looking in  

>     ${BUILD_HOME}/logs

**NOTE1:** I called this the "hardcore" method (or really the 'confidence in your template method') because its a pain in the arse to use this method if you find there is some sort of misconfiguration in your template because you have to go start the whole process of spinning up the build machine again. With the expedited method you can run multiple builds on the same machine. You could use the expedited method to build up your confidence that a particular template is correctly configured without any errors and then switch over to hardcore if you want to.  

**NOTE2:** It is expected that you will have a set of templates for different deployment situations on your laptop. For example you might have templates configured for deploying virgin joomla, virgin wordpress, a baseline of a particular application with both small machines and large machines and a whole bunch of other configurations that you might want for your server(s). Having a library of templates means you are ready to go with for a whole bunch of different deployment scenarios and you could even have a library of scripts like the one generated in step 7 above for different deployment configurations such that, for example, getting a "virgin joomla" configuration up and running might be as simple (provided that all your DNS systems are setup) as selecting the correct template from your library, perhaps updating it to the latest version of joomla 5.0.3 rather than 5.0.1 for example, maybe changing the PHP version from 8.3 to 8.4 and so on and pasting it into the cloud-init of the build machine you are spinning up.  

**NOTE3:** My point is that this is a powertool and if you invest the effort into learning it it is my hope that you will reap the rewards.   
