To use template overrides with you cloudhost you need to pick one method or the other.

## Method 1 - Manual Overriding

1. This involves taking a copy of the overide script : [Override Script](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/master/templatedconfigurations/templateoverrides/OverrideScript.sh)  and editing the copy directly.

2. Set values in your copy of the override script for:

#### BUILDMACHINE_USER  (a user name that will determine the user account on your build machine)
#### BUILDMACHINE_PASSWORD  (a strong password that will determine a password for your user account on your build machine)
#### BUILDMACHINE_SSH_PORT  (a port number that will determine the SSH port you will connect to)
#### LAPTOP_IP    (the ip address of your laptop so that the toolkit can allow your laptop's ip through the firewall)

and also:  

#### SSH  (a public key that matches a private key that you have on your laptop)
#### SELECTED_TEMPLATE  (the template number that you are overriding) 

3. You now need to override the environment variables you require for your build. You will need to review the template you have selected using **${SELECTED_TEMPLATE}** which you can review at: 

**${BUILD_HOME}/templatedconfigurations/templates/${cloudhost}/${cloudhost}${SELECTED_TEMPLATE}.tmpl**

Once you have decided with variables you want to override, override them in the copy of the Override Script that you made. pay attention to the template specification [Template Specification](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/master/templatedconfigurations/specification.md). You can place your overrides in the override script as export statements, around about line 50 where it says, "Additionl Overrides". An example if given of how to override the WS_SIZE variable. 

4. When you are very sure that you have completed all the overrides you require in your copy of the override script, paste the entire modified script into the "user data" part of a VPS system which you need to  spin up using your cloudhost's gui as your build machine on your cloudhost's infrastructure.

5. Allow you build machine to start and then SSH onto it from your laptop. Assuming you have the private key available that you set the public key to in the SSH variable in 2., you can ssh onto your build machine with a command similar to:

**ssh -p ${BUILDMACHINE_SSH_PORT} ${BUILDMACHINE_USER}@<ip address of your VPS machine - obtained from your cloudhosts gui when you started it up>**

5. Issue a command "sudo su" and enter your ${BUILDMACHINE_PASSWORD}
5. Go to adt-build-machine-scripts/logs and tail the logs to see how the build is progressing. 
6. After some minutes, your website should be online.
  
  -----------------------------------

## Method 2 - Automated Generation

1. On your laptop clone the build client scripts for example (or from your fork):

2. git clone https://github.com/wintersys-projects/adt-build-machine-scripts.git

3. cd adt-build-machine-scripts

4. /bin/sh ./helperscripts/GenerateOverrideTemplate.sh and answer the questions as it asks them

5. /bin/sh ./helperscripts/GenerateHardcoreUserDataScript.sh and answer the questions as it asks them

6 cd ${BUILD_HOME}/userdatascripts and find the script that you have just generated

7 Review the script and update the variables at the top of the script:

#### BUILDMACHINE_USER  (a user name that will determine the user account on your build machine)
#### BUILDMACHINE_PASSWORD  (a strong password that will determine a password for your user account on your build machine)
#### BUILDMACHINE_SSH_PORT  (a port number that will determine the SSH port you will connect to)
#### LAPTOP_IP    (the ip address of your laptop so that the toolkit can allow your laptop's ip through the firewall)

and also:  

#### SSH  (a public key that matches a private key that you have on your laptop)
#### SELECTED_TEMPLATE  (the template number that you are overriding) 

8. Once you are happy that all the variables are correct copy it in its entirety and paste it into the user-data of a new VPS machine with your cloud provider

9. ssh onto the build machine that you spun up in 8. and do as "sudo su" and give your BUILDMACHINE_PASSWORD
  
 **ssh -p ${BUILDMACHINE_SSH_PORT} ${BUILDMACHINE_USER}@<ip address of your VPS machine - obtained from your cloudhosts gui when you started it up>**


10. cd adt-build-machine-scripts/logs

11. tail -f build*out* to get the build progress
