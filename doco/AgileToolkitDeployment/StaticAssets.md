What I have done to facilitate sufficient capacity for dynamic asset content is to centralise asset storage for each application in their S3 compatible object storage service using s3fs (or if you are using AWS, the EFS service), so, for example, for Digital Ocean this would be the Digital Ocean Spaces service. What this means is that for n webservers as soon as a new asset is uploaded by a user of an application (for example, a new profile picture), the asset is written to the centralied S3 compatible storage service. This means that all webservers "see" the same files as soon as they are created or uploaded. So, webservers 1 to n are all writing to the same bucket in S3. Now, what we don't want to do for every read of that image file to have to go to the origin server and retreive the asset from object storage and then return it to the client, so, what we want to do is at an application level set up a CDN which uses the bucket we are uploading our assets to using s3fs from the webservers as an origin. So, for your application, for example, Joomla, Wordpress, Drupal or Moodle if you install a CDN system plugin using the S3 bucket that your webservers are writing to, then, the CDN will read the assets from the bucket and serve them directly to the client, caching them where possible. This is much more efficient and reduces the load on the origin webservers.

Most modern applications generate static assets during usage. In a horizontally scaled architecture, these assets need to be shared immediately amongst all the webservers and not just the webserver that they were generated through or uploaded to. I have adopted a flexible approach to how to make this so and you can choose which technique you would like to use.

Here are your available options:  

1. Use an application level plugin to offload your assets automatically to an S3 compatible object storage system. These plugins are available for Wordpress, Joomla and so on. If you install one of these plugins into your application, then, all of your assets can be offloaded into the cloud (S3 compatible storage) and automatically shared between all of your webservers instantly. The limit to how many assets you can store is the limit of the S3 bucket, and obviously how deep your pockets are also.   

Here is how you can offload your wordpress static assets to S3 and use a CDN:  https://www.codeinwp.com/blog/wordpress-s3-guide/  
Here is an extension you can use to offload your assets for joomla to S3 https://extensions.joomla.org/extension/ja-amazon-s3/  

2. At a systems level, you can set things up such that services such as Elastic File System (available on AWS) or an S3 bucket mounted as a file system using S3FS. The EFS solution is a very good solution because you can have (up to) petabytes of data and it is fast. Using S3FS should be an option of last resort, because, as someone said, S3 is not really for filesystems. S3FS will work, to an extent, but, option 1 is the preferable option even though it means more complexity in the application. If you are using S3FS, when applications are requested by a user interacting with your application it means that the sytem has to read through S3FS to get the assets which is slow. If you use an application level plugin, then, the application will read the assets direct from the bucket which can be cached at the edge through some systems.  

**CONFIGURING FOR YOUR APPLICATION** 
------------------------

Each application has different directories which receive user uploads, for example, for Joomla it is the /var/www/html/images directory for Wordpress it is /var/www/html/wp-content/uploads  

To define which directories you want the system to use for your assets uploads, you need to go either set the value at buid time if you are using a full build or to your template override script and set the following override parameters:  

So, for joomla, for example you would set something like:  

**export PERSIST_ASSETS_TO_CLOUD="1"  
export DIRECTORIES_TO_MOUNT="images"**  

For drupal you might set:

**export PERSIST_ASSETS_TO_CLOUD="1"  
export DIRECTORIES_TO_MOUNT="sites.default.files.pictures:sites.default.files.styles:sites.default.files.inline-images"**  

And for wordpress you might set:

**export PERSIST_ASSETS_TO_CLOUD="1"  
export DIRECTORIES_TO_MOUNT="wp-content.uploads"**  

The **DIRECTORIES_TO_MOUNT** environment variable is set to sensible defaults for each application but you can override it.
