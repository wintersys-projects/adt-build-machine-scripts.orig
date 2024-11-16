
if ( [ ! -f /home/buildhome.dat ] )
then
        /bin/echo "Don't know what build home is"
        exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"

/bin/echo "Please give me a name for the snapshot userdata script you want genenerated"
read snapshot_userdata

if ( [ "${snapshot_userdata}" = "" ] )
then
        /bin/echo "You have to give some sort of name"
        exit
fi

if ( [ ! -d ${BUILD_HOME}/userdatascripts ] )
then
        /bin/mkdir ${BUILD_HOME}/userdatascripts
fi

snapshot_userdata="${BUILD_HOME}/userdatascripts/${snapshot_userdata}"

/bin/echo "Please input which OS you are building a snapshot userdata script for 1) Ubuntu 2)Debian"
read os_choice

if ( [ "${os_choice}" -eq "1" ] )
then
        os_choice="UBUNTU"
elif ( [ "${os_choice}" -eq "2" ] )
then
        os_choice="DEBIAN"
else
        /bin/echo "Not a recognised option"
        exit
fi

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

variables=""

for file in ${files}
do
        variables="${variables} "`/bin/grep ".*##.*${os_choice}.*##" ${file} | /bin/grep -v 'SKIP' | /bin/grep -oP '{\K.*?(?=})'`
done

variables="`/bin/echo ${variables} | /usr/bin/xargs -n1 | /usr/bin/sort -u | /usr/bin/xargs`"

/bin/echo "You need to set the following variables when you run this userdata script" > ${snapshot_userdata}
/bin/echo "You can refer to the file buildstyles.dat that is active for your deployments to match the values you set here with the values you intend to deploy with" >> ${snapshot_userdata}

for variable in ${variables}
do
        /bin/echo "export ${variable}=''" >> ${snapshot_userdata}
done

/bin/echo "" >> ${snapshot_userdata}
/bin/echo "##########################################################################" >> ${snapshot_userdata}
/bin/echo "" >> ${snapshot_userdata}

for file in ${files}
do
        token="`/bin/grep -o '##.*SOURCE.*##' ${file}`" 

        if ( [ "${token}" != "" ] )
        then
                /bin/echo "I have found installation candidate `/bin/echo ${token} | /usr/bin/awk -F'-' '{print $2}'` do you want to include it? (Y|N)"
                read response

                if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
                then
                        /bin/echo "`/bin/echo ${token} | /usr/bin/awk -F'-' '{print $2}'` can be build from source or repo/binaries do you want to build from source (Y|N)"
                        read response
                        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
                        then
                                /bin/grep "##*${os_choice}.*SOURCE.*##" ${file} | /bin/grep -v SKIP  | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//' >> ${snapshot_userdata}
                        else
                                /bin/grep "##.*${os_choice}.*REPO.*##" ${file} | /bin/grep -v SKIP | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//' >> ${snapshot_userdata}
                        fi
                fi
        else
                /bin/grep "##.*${os_choice}.*REPO.*##" ${file} | /bin/grep -v SKIP | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//' >> ${snapshot_userdata}
        fi
done
