From time to time new versions of the ubuntu and debian operating systems are released. To integrate a new version (for example ubuntu 26.04 or debian 13)  
the following files have to be updasted to support these new versions:

adt-autoscaler-scripts/providerscripts/cloudhost/GetOperatingSystemVersion.sh  
adt-autoscaler-scripts/providerscripts/server/CreateServer.sh 
adt-build-machine-scripts/providerscripts/cloudhost/GetOperatingSystemVersion.sh  
adt-build-machine-scripts/providerscripts/server/CreateServer.sh  
adt-webserver-scripts/installscripts/InstallPHPBase.sh  

You can look at the examples of other versions of each OS to see how the updates need to be made. 
