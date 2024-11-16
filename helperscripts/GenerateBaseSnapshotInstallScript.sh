files=`find . -maxdepth 1 -not -name "InstallAll.sh" -and -name "Install*.sh" -print -type f`


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
