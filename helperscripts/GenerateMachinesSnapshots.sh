if ( [ ! -f  ./GenerateMachinesSnapshots.sh ] )
then
	/bin/echo "Sorry, this script has to be run from the helperscripts subdirectory"
	exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Which cloudhost service are you using? 1) Digital Ocean 2) Exoscale 3) Linode 4) Vultr. Please Enter the number for your cloudhost"
read response
if ( [ "${response}" = "1" ] )
then
	CLOUDHOST="digitalocean"
elif ( [ "${response}" = "2" ] )
then
	CLOUDHOST="exoscale"
elif ( [ "${response}" = "3" ] )
then
	CLOUDHOST="linode"
elif ( [ "${response}" = "4" ] )
then
	CLOUDHOST="vultr"
else
	/bin/echo "Unrecognised  cloudhost. Exiting ...."
	exit
fi

/bin/echo "Generating snapshot of autoscaler"
. ${BUILD_HOME}/providerscripts/server/SnapshotAutoscaler.sh 2>/dev/null
/bin/echo "Generating snapshot of webserver"
. ${BUILD_HOME}/providerscripts/server/SnapshotWebserver.sh 2>/dev/null
/bin/echo "Generating snapshot of database"
. ${BUILD_HOME}/providerscripts/server/SnapshotDatabase.sh 2>/dev/ull
 
. ${BUILD_HOME}/providerscripts/cloudhost/GetSnapshotIDs.sh
