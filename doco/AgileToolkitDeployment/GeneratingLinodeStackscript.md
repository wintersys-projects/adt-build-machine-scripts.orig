The way to go about generating a userdata script for use in the "hardcore" build process or a stack script if you are on linode is as follows:  

1. Perform an expedited build using the parameters you require for your deployment. This will mean that you have a pre-populated template which deploys succcessfully which can be used that basis for generating the userdata or stack script.  

2. On the same machine that you performed (and tested) the expedited build run the script:  

>     ${BUILD_HOME}/helperscripts/GenerateOverrideScript.sh  
    
You should select the provider and template number (1, 2 or 3) that you wish to generate from  
    
Once the script has completed successsfully it will be available in  
    
>     ${BUILD_HOME}/overridescripts  
    
3. Run the script for AWS, Digital Ocean, Exoscale or Vultr  

>     ${BUILD_HOME}/helperscripts/GenerateHardcoreUserDataScript.sh  
    
and on Linode:  
    
>     ${BUILD_HOME}/helperscripts/GenerateHardcoreUserDataScript.sh stack  
    
This will write the User Data / Stack Script to   
    
>     ${BUILD_HOME}/userdatascripts/<name you give>  
    
 4. The script ${BUILD_HOME}/userdatascripts/<name you give> can then be used a a User Data script on every provider accept Linode where it will be used as a stack script.  
