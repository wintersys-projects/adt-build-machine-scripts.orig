cloudhost="${1}"
machine_type="${2}"
default_user="${3}"


BUILD_HOME="`/bin/cat /home/buildhome.dat`"
BUILD_IDENTIFIER="`/bin/cat ${BUILD_HOME}/runtimedata/ACTIVE_BUILD_IDENTIFIER`"

if ( [ "${cloudhost}" = "digitalocean" ] )
then
        machine_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh ${machine_type} ${cloudhost}`"  
        machine_name="`/usr/local/bin/doctl compute droplet list -o json | /usr/bin/jq -r '.[] | select (.name | contains ("'${machine_type}'")).name'`"
        /usr/local/bin/doctl compute droplet-action snapshot --snapshot-name "${machine_name}" "${machine_id}"
fi

if ( [ "${cloudhost}" = "exoscale" ] )
then
  REGION_ID="`/bin/cat ${BUILD_HOME}/runtimedata/${cloudhost}/${BUILD_IDENTIFIER}/CURRENTREGION`"
  machine_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh ${machine_type} ${cloudhost}`"  
  /usr/bin/exo compute instance snapshot create -z ${REGION_ID} ${machine_id}
  snapshot_id="`/usr/bin/exo -O json  compute instance snapshot list  | /usr/bin/jq -r '.[] | select (.instance | contains ( "'${machine_type}'")) | select (.zone == "'${REGION_ID}'").id'`"
  /usr/bin/exo compute instance-template register --boot-mode legacy --disable-password --from-snapshot ${snapshot_id} --zone ${REGION_ID} --username ${default_user} ${machine_type}
fi

if ( [ "${CLOUDHOST}" = "linode" ] )
then
        machine_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh ${machine_type} ${cloudhost}`"  
        machine_name="`/usr/local/bin/linode-cli --json linodes list | /usr/bin/jq -r '.[] | select (.label | contains ("'${machine_type}'")).label'`"
        disk_id="`/usr/local/bin/linode-cli --json linodes disks-list ${machine_id} | /usr/bin/jq -r '.[] | select (.filesystem=="ext4").id'`"
        /usr/local/bin/linode-cli images create --disk_id ${disk_id} --label ${machine_name}
fi

if ( [ "${CLOUDHOST}" = "vultr" ] )
then
        machine_id="`${BUILD_HOME}/providerscripts/server/ListServerIDs.sh ${machine_type} ${cloudhost}`"  
        machine_name="`/usr/bin/vultr -o json instance list | /usr/bin/jq -r '.instances[] | select (.label | contains ("'ws-'")).label'`"
        /usr/bin/vultr snapshot create -i ${machine_id} -d "${machine_name}"
fi
