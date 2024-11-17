#!/bin/sh
########################################################################################################
# Author: Peter Winter
# Date  : 13/01/2022
# Description : You can use this script to generate a userdata/init script configured to install the base
# software that your deployment needs onto a vanilla VPS machine with no other alterations to its configuration
# other than the installation of the softeware packages that you choose here. What you can then do is make
# an image or a snapshot of the machine that you run the script you  generate here on and use that image 
# to deploy a server machine  (autoscaler, webserver, or database) by  configuring your deployment template
# to use the image you have generated here as a snapshot to build off. This will speed up the deployment
# time of your server machines (important during autoscaling) because you are building off an image that
# already has the bulk of the necessary software installed. PHP, for example can take several minutes to
# install from scratch which all adds to your deployment time. So, if you put the effort in to generate
# snapshot images for each type of machine you have (autoscaler, webserver and database) then you have
# the bulk of your software ready and primed. Just run this script and make your choices and the 
# userdata script it produces can be used as an init script against a vanilla VPS machine. 
########################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
set -x
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

if ( [ -f ./tmp ] )
then
        /bin/rm -r ./tmp
else
        /bin/mkdir ./tmp
fi
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
/bin/echo "Examples of how you may set these variables are:" >> ${snapshot_userdata}
/bin/echo "export buildos='debian'     export PHP_VERSION='8.3' export modules='fpm:cli:gmp:xmlrpc:soap:dev:mysqli'" >> ${snapshot_userdata}
/bin/echo "You can refer to the file buildstyles.dat that is active for your deployments to match the values you set here with the values you intend to deploy with" >> ${snapshot_userdata}
/bin/echo "##########################################################################" >> ${snapshot_userdata}

for variable in ${variables}
do
        /bin/echo "export ${variable}=''" >> ${snapshot_userdata}
done

/bin/echo "" >> ${snapshot_userdata}
/bin/echo "##########################################################################" >> ${snapshot_userdata}
/bin/echo "" >> ${snapshot_userdata}

if ( [ ! -d ${BUILD_HOME}/logs ] )
then
        /bin/mkdir ${BUILD_HOME}/logs
fi

OUT_FILE="install-out.log.$$"
exec 1>>${BUILD_HOME}/logs/${OUT_FILE}
ERR_FILE="intall-err.log.$$"
exec 2>>${BUILD_HOME}/logs/${ERR_FILE}

for file in ${files}
do
        token="`/bin/grep -o '##.*SOURCE.*##' ${file}`" 

        if ( [ "${token}" != "" ] )
        then
                /bin/echo "I have found installation candidate `/bin/echo ${token} | /usr/bin/awk -F'-' '{print $2}'` do you want to include it in your snapshot install script? (Y|N)"
                read response

                if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
                then
                        /bin/echo "`/bin/echo ${token} | /usr/bin/awk -F'-' '{print $2}'` can be build from source or repo/binaries do you want to build from source (Y|N)"
                        read response
                        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
                        then
                                /bin/grep "##*${os_choice}.*SOURCE.*##" ${file}  | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//' >> ${snapshot_userdata}
                        else
                                /bin/grep "##.*${os_choice}.*REPO.*##" ${file} | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//' >> ${snapshot_userdata}
                        fi
                fi
        else
                token="`/bin/grep -o '##.*REPO.*##' ${file}`" 

                if ( [ "${token}" != "" ] )
                then
                        /bin/echo "I have found installation candidate `/bin/echo ${token} | /usr/bin/awk -F'-' '{print $2}'` do you want to include it in your snapshot install script? (Y|N)"
                        read response 
                        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
                        then
                                /bin/grep "##.*${os_choice}.*REPO.*##" ${file} | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//' >> ${snapshot_userdata}
                        fi
                fi
        fi
done
