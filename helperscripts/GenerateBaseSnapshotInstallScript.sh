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
#set -x

if ( [ ! -f /home/buildhome.dat ] )
then
        /bin/echo "Don't know what build home is"
        exit
fi

BUILD_HOME="`/bin/cat /home/buildhome.dat`"
HOME="`/usr/bin/pwd`/tmp"

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

if ( [ -f ${BUILD_HOME}/userdatascripts/${snapshot_userdata} ] )
then
        /bin/rm ${BUILD_HOME}/userdatascripts/${snapshot_userdata}
fi

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

/bin/echo "Please input the owner name of your infrastructure repositories (default is wintersys-projects)"
read repo_owner

if ( [ "${repo_owner}" = "" ] )
then
        repo_owner="wintersys-projects"
fi

if ( [ -d ./tmp ] )
then
        /bin/rm -r ./tmp/*
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

files=`find ${install_scripts_dir} -maxdepth 1 -not -name "InstallAll.sh" -and -name "InstallNGINX*.sh" -print -type f`

variables=""

for file in ${files}
do
        variables="${variables} "`/bin/grep ".*##.*${os_choice}.*##" ${file} | /bin/grep -v 'SKIP' | /bin/grep -oP '{\K.*?(?=})'`
done

variables="`/bin/echo ${variables} | /usr/bin/xargs -n1 | /usr/bin/sort -u | /usr/bin/xargs`"

/bin/echo "#You need to set the following variables when you run this userdata script" > ${snapshot_userdata}
/bin/echo "#Examples of how you may set these variables are:" >> ${snapshot_userdata}
/bin/echo "#export apt='/usr/bin/apt-get'  export HOME="/root" export buildos='debian' export PHP_VERSION='8.3' export modules='fpm cli gmp xmlrpc soap dev mysqli'" >> ${snapshot_userdata}
/bin/echo "#You can refer to the file buildstyles.dat that is active for your deployments to match the values you set here with the values you intend to deploy with" >> ${snapshot_userdata}
/bin/echo "###########################################################################" >> ${snapshot_userdata}

for variable in ${variables}
do
        /bin/echo "export ${variable}=''" >> ${snapshot_userdata}
done

if ( [ "${os_choice}" = "UBUNTU" ] )
then
        /bin/echo "export BUILDOS='ubuntu'" >> ${snapshot_userdata}
elif ( [ "${os_choice}" = "DEBIAN" ] )
then
        /bin/echo "export BUILDOS='debian'" >> ${snapshot_userdata}
fi

/bin/echo "###########################################################################" >> ${snapshot_userdata}
/bin/echo "#I found the following  additional variables that you may or may not need to set in the script. Please review them and decide what they need to be before running the script" >> ${snapshot_userdata}
/bin/echo "#XXXXADDITIONAL_VARIABLESXXXX" >> ${snapshot_userdata}

/bin/echo "" >> ${snapshot_userdata}
/bin/echo "##########################################################################" >> ${snapshot_userdata}
/bin/echo "" >> ${snapshot_userdata}

BUILD_HOME="/root"

/bin/echo '#if ( [ ! -d ${BUILD_HOME}/logs ] )' >> ${snapshot_userdata}
/bin/echo '#then' >>${snapshot_userdata}
/bin/echo '#        /bin/mkdir ${BUILD_HOME}/logs' >> ${snapshot_userdata}
/bin/echo '#fi' >> ${snapshot_userdata}

/bin/echo '#OUT_FILE="install-out.log.$$"' >> ${snapshot_userdata}
/bin/echo '#exec 1>>${BUILD_HOME}/logs/${OUT_FILE}' >> ${snapshot_userdata}
/bin/echo '#ERR_FILE="install-err.log.$$"' >> ${snapshot_userdata}
/bin/echo '#exec 2>>${BUILD_HOME}/logs/${ERR_FILE}' >> ${snapshot_userdata}

additional_variables=""

for file in ${files}
do
        methods="REPO BINARY SOURCE"
        processed="0"
        for method in ${methods}
        do
                if ( [ "${processed}" = "0" ] )
                then
                        tokens="`/bin/grep -o "##.*${os_choice}.*${method}.*##" ${file} | /bin/grep -v "DEBIAN_FRONTEND"`" 
                        tokens1="`/bin/echo ${tokens} | /bin/sed 's/\-SKIP//g' | /bin/sed 's/#//g' | /usr/bin/tr ' ' '\n' | /usr/bin/uniq`"

                        if ( [ "${tokens1}" != "" ] )
                        then
                                inline_processed="0"
                                token_holder=""
                                for token in ${tokens1}
                                do
                                        if ( [ "${inline_processed}" = "0" ] )
                                        then
                                                if ( [ "${token_holder}" = "" ] || [ "`/bin/echo ${token} | /bin/grep "${token_holder}"`" = "" ] )
                                                then
                                                        /bin/echo "I have found installation candidate `/bin/echo ${token} | /usr/bin/awk -F'-' '{print $2}'` using  method ${method} do you want to include it in your snapshot install script? (Y|N)"
                                                        read response 
                                                        if ( [ "${response}" = "Y" ] || [ "${response}" = "y" ] )
                                                        then
                                                                if ( [ "${method}" = "SOURCE" ] && [ "`/bin/grep "##*${os_choice}.*SOURCE.*INLINE.*##" ${file}  | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//'`" != "" ] )
                                                                then
                                                                        source_file="`/bin/grep "##*${os_choice}.*SOURCE.*INLINE.*##" ${file}  | /bin/sed -e 's/##.*##//g' -e 's/^[ \t]*//'`" >> ${snapshot_userdata}
                                                                        source_file="${install_scripts_dir}/`/bin/echo ${source_file} | /usr/bin/awk '{print  $1}' | /usr/bin/awk -F'/' '{print $(NF-1),"/",$NF}' | /bin/sed 's/ //g'`"
                                                                        echo "XXXXXXXXXX"
                                                                        additional_variables="`/bin/grep '#####SOURCE_BUILD_VAR#####' ${source_file} | /usr/bin/awk -F'=' '{print $1}' | /bin/tr '\n' ' '`"
                                                                        echo "XXXXXXXXXX"
                                                                        /bin/sed  -e '/ExtractBuildStyleValues/s/^/#/' -e '/ExtractConfigValue/s/^/#/' -e '/^#/d' ${source_file} | /usr/bin/tee -a  ${snapshot_userdata}
                                                                        inline_processed="1"
                                                                else
                                                                        /bin/grep "##.*${os_choice}.*${method}.*##" ${file} | /bin/grep ${token} | /bin/sed 's/##.*##//g' | /bin/sed -e 's/^[ \t]*//' >> ${snapshot_userdata}
                                                                fi
                                                                processed="1"
                                                        else
                                                                token_holder="`/bin/echo ${token} | /usr/bin/awk -F'-' '{print $2}'`"
                                                        fi
                                                fi
                                        fi
                                done
                        fi
                fi
        done
done

for variable in "`/bin/echo ${additional_variables} | /bin/sed 's/#//g'`"
do
        /bin/sed -i "/XXXXADDITIONAL_VARIABLESXXXX/a #export ${variable}=''" ${snapshot_userdata}
done

/bin/sed -i "s/XXXXADDITIONAL_VARIABLESXXXX//g" ${snapshot_userdata}
