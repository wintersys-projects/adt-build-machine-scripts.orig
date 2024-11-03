To add a new DNS provider you will need to review and add to the following files for your new DNS provider. It would be cool to have other providers supported that provide services similar to cloudflare to provide deployers with other options

>     adt-webserver-scripts/security/SetupFirewall.sh
>     adt-webserver-scripts/security/ObtainSSLCertificate.sh
>     adt-webserver-scripts/providerscripts/webserver/configuration/
>     adt-webserver-scripts/providerscripts/dns

>     adt-build-machine-scripts/providerscripts/server/ObtainSSLCertificate.sh
>     adt-build-machine-scripts/providerscripts/security/firewall/SetupNativeFirewall.sh
>     adt-build-machine-scripts/providerscripts/security/firewall/GetProxyDNSIPs.sh
>     adt-build-machine-scripts/providerscripts/dns
