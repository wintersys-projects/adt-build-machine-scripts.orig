To use this toolkit productively its necessary to understand the intended workflows. Here is an overview of how I would expect the workflows to operate in common scenarios.

#### Building and deploying your own custom application

1. The deployment in development mode of a virgin application such as joomla by configuring template 1 and running a build either using the expedited or the hardcore method
2. The customisation of the the virgin application (installing modules/components and plugins) that you have deployed in 1 until it meets your business need
3. Making a baseline of your completed application to a (private) repository by running on the build machine the

>     for the website baseline: ${BUILD_HOME}/helperscripts/PerformWebsiteBaseline.sh

>     for the website baseline: ${BUILD_HOME}/helperscripts/PerformDatabaseBaseline.sh

 4. Once you have a baselined application (once you make very sure that the database/webroot) do not contain any sensitive information you can either share that baseline with 3rd parties who have a similar business need or you can use it yourself. It is essential that you are very sure that your baselined application repositories do not contain any sensitive information before you make them public of you share them. If you aren't sure about this I would advise you not to share them.

5. If your intention is to use your new application in a production scenario for yourself then you will need to generate temporal backups of your application to preferably to both git repositories and your datastore as well. The way you generate your temporal backups is to run the following scripts on your build machine:

>     for the website temporal backup:  ${BUILD_HOME}/helperscripts/PerformWebsiteBackup.sh
>     for the database temporal backup: ${BUILD_HOME}/helperscripts/PerformDatabaseBackup.sh

6. You can then take your development servers offline and deploy in production mode by customising a template 3 to your needs complete with autoscaler provisioning and so on.

#### Deploying from a pre installed sofware baseline

You can create a preinstalled software snapshot that matches the configuration of the machine you intend to deploy. Using this technique of building a webserver from a snapshot, I got times of 8 minutes instead of 15 minutes for a webserver to build so it can be worth looking into using snasphots with core software already installed rather than having the software installed on the fly for each new build. In other words, if you build of snapshots and you build 8 webservers the software will only have been installed once (for the snapshot to be generated) where as without snapshots the software will be installed 8 times once for each webserver

>     run the script ${BUILD_HOME}/helperscripts/GenerateBaseSnapshotInstallScript.sh
>     get the generated output script from ${BUILD_HOME}/userdatascripts and set any variables that are needed according to your requirements
>     spin up a vanilla VPS machine for your chosen cloud provider of the same OS type (debian or ubuntu) that you intend to ultimately deploy to
>     Logon to your new machine and copy the userdatascript that you generated to it
>     Run the script to install your software base
>     Once all the software you need is installed, take a snapshot of it (which will be different for each provider)
>     Once you have an snapshot image ID terminate the machine that you just took a snapshot of
>     Get the snapshot image id and paste it into your template for the type of machine that you are building for (e.g. WEBSERVER_IMAGE_ID)

If you do all that then the (in this case) webserver machines will build off snapshots and that includes the any machines started and provisioned due to scaling events once your infrastructure is up and running



   
