BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which cloudhost do you want to view logs for DigitalOcean (do), Exoscale (exo), Linode (lin) or Vultr (vul)"
/bin/echo "Please type one of do, exo, lin, vul"
read response

if ( [ "${response}" = "do" ] )
then
  CLOUDHOST="digitalocean"
elif ( [ "${CLOUDHOST}" = "exo" ] )
then
  CLOUDHOST="exoscale"
elif ( [ "${CLOUDHOST}" = "lin" ] )
then
  CLOUDHOST="linode" 
elif ( [ "${CLOUDHOST}" = "vul" ] )
then
  CLOUDHOST="vultr"
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "tail (t) or cat (c)"
read response

/bin/echo "Do you want out (1) or err (2)"
read response1

if ( [ "${response1}" = "1" ] )
then
  if ( [ "${response}" = "t" ] )
  then
    /bin/tail -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*log*
  elif ( [ "${response}" = "c" ] )
  then
      /bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*log*
  fi
elif ( [ "${respose1}" = "2" ] )
then
  if ( [ "${reponse}" = "r" ] )
  then
    /bin/tail -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*err*
  elif ( [ "${response}" = "c" ] )
  then
      /bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*err*
  fi
fi

