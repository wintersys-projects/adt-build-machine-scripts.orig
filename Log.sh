BUILD_HOME="`/bin/cat /home/buildhome.dat`"
${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh

#You can set yourself up with oneliners to access particular log or error streams this will provide you with rapid access to your build streams
#You should comment out the interactive call above and comment in a command like the ones shown below which are appropriate for you
#${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh vultr crew c 2 #cat the error stream for vultr with build identifer "crew"
#${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh linode crew t 1 #tail the output stream for linode with build identifier "crew"
#${BUILD_HOME}/helperscripts/DisplayLoggingStreams.sh digitalocean crew v 1 #edit the output stream for digitalocean with identifier "crew"
