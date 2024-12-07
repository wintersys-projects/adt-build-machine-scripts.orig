


if ( [ "${CLOUDHOST}" = "linode" ] )
then
  status "Monitoring for your snapshots to have fully generated, might take a minute, please wait"
  prefixes="as- ws- db-"

  while ( [ "`/bin/echo ${prefixes} | /bin/sed 's/ //g'`" != "" ] )
  do
        for prefix in ${prefixes}
        do
                result="`/usr/local/bin/linode-cli images list --json | /usr/bin/jq -r '.[] | select ( .label | contains ("'${prefix}${REGION}-${BUILD_IDENTIFIER}-'")).status'`" 
                if ( [ "${result}" = "available" ] )
                then
                        prefixes="`/bin/echo ${prefixes} | /bin/sed "s/${prefix}//g"`"
                fi
        done
  done
  status "All snapshots generated"
fi
