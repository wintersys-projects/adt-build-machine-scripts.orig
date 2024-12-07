


if ( [ "${CLOUDHOST}" = "linode" ] )
then
  status "Monitoring for your snapshots to have fully, might take a minute, please wait"
  prefixes="as- ws- db-"

  while ( "`/bin/echo ${prefixes} | /bin/sed 's/ //g'`" != "" )
  do
    for prefix in ${prefixes}
    do
      result="`linode-cli images list --json | /usr/bin/jq -r '.[] | select ( .label | contains ("'${REGION}-${BUILD_IDENTIFIER}-${RND}'")).status`" = "available")
      if ( [ "${result}" = "available" ] )
      then
        prefixes="`/bin/echo ${prefixes} | /bin/sed "s/${prefix}//g"`"
      fi
    do
  done
fi
status "All napshots generated"
