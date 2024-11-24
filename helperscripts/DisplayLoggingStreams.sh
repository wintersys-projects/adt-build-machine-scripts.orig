#set -x

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which cloudhost do you want to view logs for DigitalOcean (do), Exoscale (exo), Linode (lin) or Vultr (vul)"
/bin/echo "Please type one of do, exo, lin, vul"
read response

if ( [ "${response}" = "do" ] )
then
  CLOUDHOST="digitalocean"
elif ( [ "${response}" = "exo" ] )
then
  CLOUDHOST="exoscale"
elif ( [ "${response}" = "lin" ] )
then
  CLOUDHOST="linode" 
elif ( [ "${response}" = "vul" ] )
then
  CLOUDHOST="vultr"
fi

/bin/echo "What is the build identifier you want to connect to?"
/bin/echo "You have these builds to choose from: "

/bin/ls ${BUILD_HOME}/runtimedata/${CLOUDHOST}

/bin/echo "Please enter the name of the build of the server you wish to connect with"
read BUILD_IDENTIFIER

/bin/echo "tail (t) or cat (c) or vim (v)"
read response

/bin/echo "Do you want out (1) or err (2)"
read response1

if ( [ "${response1}" = "1" ] )
then
  if ( [ "${response}" = "t" ] )
  then
    /bin/tail -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*out*
  elif ( [ "${response}" = "c" ] )
  then
      /bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*out*
  elif ( [ "${response}" = "v" ] )
  then
      /usr/bin/vi ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*out*
  fi
elif ( [ "${response1}" = "2" ] )
then
  if ( [ "${response}" = "r" ] )
  then
    /bin/tail -f ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*err*
  elif ( [ "${response}" = "c" ] )
  then
      /bin/cat ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*err*
  elif ( [ "${response}" = "v" ] )
  then
      /usr/bin/vi ${BUILD_HOME}/runtimedata/${CLOUDHOST}/${BUILD_IDENTIFIER}/logs/*err*
  fi
fi

