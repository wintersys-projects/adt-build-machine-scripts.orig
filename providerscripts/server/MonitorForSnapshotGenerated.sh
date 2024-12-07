

linode-cli images list --json | /usr/bin/jq -r '.[] | select ( .label | contains ("as-'${REGION}-${BUILD_IDENTIFIER}-${RND}'")).status
