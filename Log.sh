BUILD_HOME="`/bin/cat /home/buildhome.dat`"

#You can set yourself up with oneliners to access particular log or error streams this will provide you with rapid access to your build streams
#You should comment out the interactive call above and comment in a command like the ones shown below which are appropriate for you
#For example, if you ran this script ${BUILD_HOME}/Log.sh c 2 you would "cat" the error stream for "vultr" with build_identifier "crew"
#For example, if you ran this script ${BUILD_HOME}/Log.sh v 1 you would "edit" the output stream for "vultr" with build_identifier "crew"
#For example, if you ran this script ${BUILD_HOME}/Log.sh t 1 you would "tail" the output stream for "vultr" with build_identifier "crew"
#If you are running for linode (for example you would need to change this script up front according to the subsequent examples
#The actual log files are stored at ${BUILD_HOME}/runtimedata/<cloudhost>/<build_identifier>/logs

#${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh vultr crew ${1} ${2} 

${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh linode crew ${1} ${2} 
#${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh digitalocean crew2 ${1} ${2}

#Defaults to interactive
if ( [ "$?" != "0" ] )
then
        ${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh
fi
