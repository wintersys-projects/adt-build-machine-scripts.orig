AUTHORISATION SERVER

I decided to roll my own solution for implementing zero trust. The way I intend to do it is as follows:

1. Provide people that want to use your main website with email addresses for your domain. For example, if your domain is nuocial.org.uk you can give out an email address jane@nuocial.org.uk. People have to be given an email address for your domain to be able to register your authorisation server. 

2. Your authorisation server consists of a CMS application deployed using the ADT which (once logged in) asks the user to provide the ip address of the machine that they want to use the website from. Each time the ip address changes the user will need to re authenticate to the authorisation server and enter the ip address of the new machine that they are connecting from. The IP address they enter is stored in the database. 

3. A processs running with the ADT on the authorisation server connects to the database and extracts a list of ip addresses for all the users and writes all of the ip addresses to a well known bucket in S3 shared with the main application server. The ADT for the main application will look for a file named allauthorisationips.dat in the top level of the config bucket that is used for configuration purposes throughout this toolkit. You will need to write a script on the application server which looks in the application server's database and writes the ip addresses to the mentioned S3 bucket. There is an example of how to do that [here](https://github.com/wintersys-projects/adt-database-scripts/blob/master/providerscripts/utilities/ListAuthorisationIPs.sh). 

4. The main application is deployed using the ADT as you normally would. The ports for the webserver 443 and 80 are initially completely firewalled off. The user has to visit the authorisation server which is secured but open to the intenet to register the ip address that they want to connect to the main application with or using. 

5. The main application will poll the well known S3 bucket for new ip addresses that have been written there by the (otherwise completely separate) registration server. For the ip addresses that it finds it punches a whole in the firewall of each webserver so that that particular ip address can connect to the application

That's the basic way I implement zero trust which is to firewall off entirely by default and only grant access to ip addresses that have proved validity according to the authorisation server. 

N.B. If the user goes directly to the main application site because they are unaware that their ip address has changed for some reason, they will get a timeout. They will need to be informed that if they get a timeout at any point its because the ip address they have connected from is not recognised by the system and they need to visit the authorisation server. 

The first law of secure systems is "the more secure you make them, the more difficult to use they will be" and I think whilst this is a bit more difficult for the user to use its not really much more difficult than other zero trust solutions out there. 

Basically, in the presence of an aoplication server timeout, 

Login to authorisation server (you will need to build an authorisation website in, for example, joomla, to collect user's ip addresses and then you are responsible for supplying a line by line list to the allauthorisationips.dat file in the shared config bucket)
enter your currrent ip address
wait 30 seconds for new ip address to be granted access in the webservers of the main application. 
go to main application from your now allowed ip address 
login and go about your business
