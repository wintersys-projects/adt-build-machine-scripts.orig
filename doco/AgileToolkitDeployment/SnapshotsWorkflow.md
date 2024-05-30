
### SNAPSHOTS WORKFLOW

### ExpeditedAgileDeploymentToolkit.sh method

Under this method, you have to manually edit the template and for each method, you need to set the environment varibles as follows. So, as well as all the other settings that you need to set for your template using the expedited method, you need to specifically pay attention to the following:

1. **Generate Snapshots** Under this method, you need to set 

>      GENERATE_SNAPSHOT="1"

This will prompt the build process to take a snapshot of your machines at build time as it did for the AgileDeploymentToolkit.sh method. 

2. **Build using snapshots**  To use this method, you need to set the following values in your template:

>     AUTOSCALE_FROM_SNAPSHOTS="1" 
>     GENERATE_SNAPSHOTS=""
>     SNAPSHOT_ID="XXXX"
>     WEBSERVER_IMAGE_ID="XXXXXXXX"
>     AUTOSCALER_IMAGE_ID="XXXXXXXX" 
>     DATABASE_IMAGE_ID="XXXXXXXX" 

If you have snapshots generated and ready and you set these values, assuming that the rest of your template is set up correctly, you will be able to build from snapshots. If you use an "hourly", "daily" etc backup, then, the build will sync to the latest repository.



