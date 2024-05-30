There's two types of SSL certificates that can be issued. There's full certificates and there's staging certificates.

The staging certificates will give you a browser warning when you visit your site, something like, "This is not secure".

The advantage of staging certificates is that you can issue as many of them as you want for a particular domain. 
So, if you are in development mode and you are rebuilding several times using hardcore builds, if you use the full certificates (not staging certificates), you will run out of issuing credits for that domain and won't be able to issue new ones for a set time. By default, therefore, when in development mode, this toolkit uses staging certificates with the associated error message.
If you want to change this so that you get full certificates for the development builds as well as the production builds, you can modify your template with

SSL_LIVE_CERT="1"

rather than

SSL_LIVE_CERT="0"
