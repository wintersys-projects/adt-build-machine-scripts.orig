#### NATIVE FIREWALLING

Following these steps will activate/confgure the UFW firewall on your build machine. It is recommended that you use your cloud provider (currently one of Digital Ocean, Linode, Exoscale or Vultr) to create a native firewall named "adt-buildmachine" attach your build machine to it and allow the most restrictive set of client (laptop) ip addresses through it to your build machine that you can. This native firewall should most likely only allow the SSH port that you have configured for use when you connect to your build machine and in this way your build machine which will have all your security credential goodies is "double firewalled" with both UFW and your cloudhosts native firewall. If there's a problem with one, the other should still be there. Any time you want to allow a new laptop IP address, if for example, you connect from your office machine rathet than your home machine for the first time, then you will need to remember to manually reconfigure your native firewall as well as following the steps below to have your build machine's firewall allow an additional laptop to connect through to the build machine. Having double firealling like this is as secure as I can make it with my level of expertise.

-------------------------

#### HOW TO TIGHTEN BUILD MACHINE ACCESS  

Quick method (you will need to already have access to your build machine to be able to use this method in order to add secondary allowed ip addresses)

You can use the helperscript:  

**${BUILD_HOME}/helperscripts/AdjustBuildMachineFirewall.sh**

to adjust access to your build machine or you can use the manual process described below, if you need to.

Now manually review the native firewall for your provider called "adt-build-machine" with your cloudhost, make sure your build machines is has this native firewall active and allow the additional IP address through the GUI also. 

-----------------------------------

Long method

This is what you have to do if you don't have access to your build machine or you could use the "console" of your cloudhost provider to go onto your build machine and then use the "quick method" above. 

1. Install S3CMD on your laptop/desktop and configure it so it can access your S3 compatible object store for your cloudhost.  
  
2. If it doesn't exist, create a bucket on your datastore called  

##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  s3://authip-adt-allowed 

where the build identifier is the build identifier that you gave to the particular build you want to access (you will need to create a bucket for each build you want to protect if you have multiple builds on the same machine).  

3. Edit a file (authorised-ips.dat) on your laptop and on separate lines put the ip addresses of each machine you want to grant access rights to your build machine to taking special care to include your own laptop's IP address. So, if your laptop ip address is 111.111.111.111 and your colleagues laptop ip address is 222.222.222.222 then your file authorised-ips.dat will look like:  
   
  ##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   111.111.111.111  
  ##### &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;   222.222.222.222  
   
4. Upload this file to your s3 

   ##### &nbsp;&nbsp;&nbsp; /usr/bin/s3cmd put authorised-ips.dat s3://authip-adt-allowed/authorised-ips.dat. 
   
The file must be named that precisely for the build machine to pick it up and reconfigure or tighten the firewall. You can grant and revoke access to different ip adresses by reuploading or uploading a different authorised-ips.dat file to the correct S3 bucket. This means your build machine can't be accessed from any ip address except for the ones that you authorise. A bit of a process, but, once its done you are all set. 

When you deploy using using a user data script you will see that you are required to enter your laptop ip address so that it can be granted access to the build machine. This works well enough, but, you might want to either deploy without using our example override scripts in which case firewall tightening isn't initially built in or, your laptop IP address might change, if you use it from a different network, for example, and this would leave you potentially locked out from your build machine. So, this whole palaver is what means that you can update your bucket in your S3 datastore directly with a new ip address and the build machine will pick up that a new ip address needs to be granted access. This way you will never be locked out of your build machine by IP address. Also, as I have shown adding multiple ip addresses to your authorised-ips.dat file in your datastore you could have a team of people all in different locations who you are effectively granting access to your build machine to. You can use any S3 client from your laptop to add a new ip address to  

**s3://authip-adt-allowed/authorised-ips.dat**  

if you are ever locked out from your build machine. The build machine is then completely firewalled off accept for the specific ip addresses and ports you have granted access to. Make sure your team know this or have access to add ip addresses because if their IP changes, they will be locked out. To action the update you also need to create a file  

**s3://authip-adt-allowed/FIREWALL-EVENT**

Now review the native firewall called "adt-build-machine" with your cloudhost and allow the additional IP address through the GUI also. 



