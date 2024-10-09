#### BUILD STRATEGIES (ABRIDGED SUMMARY)

What will happen during a **Expedited build** is that:

1. You will provision a vanilla VPS system by populating the 5 or 6 necessary variables only in the [Build Machine](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/templatedconfigurations/templateoverrides/OverrideScript.sh) script and pasting it into the user data of a VPS machine that you are provisioning with your cloudhost.

2. You will then ssh onto the machine (using your private key that matches the public key you set in 1. and as well as the ssh port and username).

3. You will do a "sudo su" on your build machine using the password from 1. 

4. You will cd into the **${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}** and pupulate your template

5. You will then run ${BUILD_HOME}/ExpeditedAgileDeploymentToolkit.sh You will answer all the questions (correctly) and the build will run

6. At the end of the build the environment that was used will be stored in a file:  

**${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}**  

Which you can use next time to build from without answering all the questions or you can take a separate copy of and replace  

**${BUILD_HOME}/buildconfiguration/${CLOUDHOST}/${BUILD_IDENTIFIER}**  

with any time you want to do the same build again. 

----------------------------

During a **hardcore build**, you need to

1. On your laptop clone the build client scripts for example (or from your fork):  

2. **git clone https://github.com/wintersys-projects/adt-build-machine-scripts.git**  and set up your template  **${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}**  

3. **cd adt-build-machine-scripts**  

4. **/bin/sh ./helperscripts/GenerateOverrideTemplate.sh** and answer the questions as it asks them  

5. **/bin/sh ./helperscripts/GenerateHardcoreUserDataScript.sh** and answer the questions as it asks them  

6. **cd ${BUILD_HOME}/userdatascripts** and copy the script that has been generated and post it into the user-data of a new VPS machine.   
