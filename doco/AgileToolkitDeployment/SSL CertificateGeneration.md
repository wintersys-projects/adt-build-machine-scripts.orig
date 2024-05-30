
When you run the build process one of the last tasks that are completed before the main build begins is a call to the script:

>      ${BUILD_HOME}/initscripts/InitialiseNewSSLCertificate.sh

This call will check if an SSL certificate exists on the build machine or not and whether it is valid. If an SSL certificate either doesn't exist or it is out of date then a new certificate is generated.
The SSL certificate (reused or newly generated) is then copied to the datastore for webservers to make use of.

When a webserver builds it expects to be able to get an SSL certificate from the datastore, generated as described above,that it can use so it looks for it, downloads it and installs it.

On a daily basis the webservers nominate an authoritative webserver and the authoritative webserver checks if the SSL certificate it is using is valid. If it finds that its not valid (is about to expire because the webservers have been online for a while), then, it generates a new certificate and replaces the certificate that was in the datastore with the one that it has newly generated. Each of the other webservers then download this new certificate and install it and restart the webserver itself to ensure it is active. 

That's a simple as I could think of for SSL certificate management. 
