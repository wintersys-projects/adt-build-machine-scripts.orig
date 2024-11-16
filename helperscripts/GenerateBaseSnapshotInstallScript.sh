
/bin/echo "Please input the owner name of your infrstructure repositories (default is wintersys-projects)"
read repo_owner

/bin/mkdir ./tmp
cd ./tmp
/usr/bin/git clone https://github.com/${repo_owner}/adt-build-machine-scripts.git
/usr/bin/git clone https://github.com/${repo_owner}/adt-autoscaler-scripts.git
/usr/bin/git clone https://github.com/${repo_owner}/adt-webserver-scripts.git
/usr/bin/git clone https://github.com/${repo_owner}/adt-database-scripts.git
cd ..
/bin/echo "Do you wish to generate a snapshot init script for an autoscaler, a webserver or a database"
/bin/echo "Enter 1 for autoscaler, 2 for webserver, 3 for database"
read machine_choice

if ( [ "${machine_choice}" = "1" ] )
then
        install_scripts_dir="./tmp/adt-autoscaler-scripts/installscripts"
elif ( [ "${machine_choice}" = "2" ] )
then
        install_scripts_dir="./tmp/adt-webserver-scripts/installscripts"
elif ( [ "${machine_choice}" = "3" ] )
then
        install_scripts_dir="./tmp/adt-database-scripts/installscripts"
fi


files=`find ${install_scripts_dir} -maxdepth 1 -not -name "InstallAll.sh" -and -name "Install*.sh" -print -type f`

/bin/echo "I believe the variables you need to set for this script to run are:"
/bin/echo "`/bin/grep '.*####.*DEBIAN.*' ${install_scripts_dir}/Install*.sh | /bin/grep -v 'SKIP' | /bin/grep -oP '{\K.*?(?=})' | /usr/bin/sort | /usr/bin/uniq`"
/bin/echo "You should set these variables as directed at the top of the generated script before you make a deployment"
/bin/echo "You can refer to the file buildstyles.dat that is active for your deployments to match the values you set here with the values you intend to deploy with"

for file in ${files}
do
        if ( [ "`/bin/grep '####.*SOURCE.*####' ${file}`" != "" ] )
        then
                /bin/echo "${file} can be build from source or repo/binaries do you want to build from source (Y|N)"
                read response
                if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
                then
                        grep "##*UBUNTU.*SOURCE.*##" ${file} | grep -v SKIP  | /bin/sed 's/####.*####//g' | sed -e 's/^[ \t]*//' >> out
                fi
        else
                grep "##.*UBUNTU.*REPO.*##" ${file} | grep -v SKIP | /bin/sed 's/####.*####//g' | sed -e 's/^[ \t]*//' >> out
        fi
done
