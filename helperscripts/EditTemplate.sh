BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which cloudhost do you want to view logs for (1)DigitalOcean, (2)Exoscale, (3)Linode or (4)Vultr"
read response

if ( [ "${response}" = "1" ] )
then
        CLOUDHOST="digitalocean"
fi
if ( [ "${response}" = "2" ] )
then
        CLOUDHOST="exoscale"
fi
if ( [ "${response}" = "3" ] )
then
        CLOUDHOST="linode"
fi
if ( [ "${response}" = "4" ] )
then
        CLOUDHOST="vultr"
fi

/bin/echo "The following templates are available, which one do you want?"
/bin/ls ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/*tmpl | /usr/bin/awk -F'/' '{print $NF}'

/bin/echo "Type the name of the template you want from the list above"
read template

/usr/bin/vi ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/${template} 
