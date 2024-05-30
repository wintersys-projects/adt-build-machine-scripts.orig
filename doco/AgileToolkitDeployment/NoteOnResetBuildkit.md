**If** you were to want to create a new repository out of the build client repository that you have on your build machine for some reason, it is essential that you don't push any sensitive credentials stored on the file system into your new repository if you make it public, people do trawl for such things and you may get a breach if you do. 

So, before pushing your (updated) repository to your git provider, you need to reset the buildkit which you can do by running

>     ${BUILD_HOME}/helperscripts/ResetBuildKit.sh

That said it doesn't clear out any settings you have in your templates, so, be sure to clear those out manually as well from the:  

>     ${BUILD_HOME}/templatedconfigurations/templates/${CLOUDHOST}/*.tmpl 

files.
