# README #

**DO NOT DEPLOY THIS ON YOUR DAY TO DAY LINUX LAPTOP AS IT WILL MAKE CHANGES TO THE MACHINE'S CONFIGURATION**

>     NOTE: The scripts in this repository will control the build process of your the different classes of server machines (autoscaling/webserving/database). You could run this on a dedicated linux (ubuntu/debian) laptop or on a dedicated linux system that you boot off a flash drive (with persistent storage enabled). I generally describe how to use this toolkit from a VPS linux machine running in the cloud

**If you are interested in self managed server systems this tool could make your life easier; it's a custom solution for server deployment management**

##### DISCUSSION COMMUNITY: [DISCUSSION COMMUNITY](https://form.jotform.com/242746291971364)
##### EXPLANATORY WIKI: [WIKI](https://github.com/wintersys-projects/adt-build-machine-scripts/wiki)
##### DETAILED USAGE TUTORIALS: [TUTORIALS](https://github.com/wintersys-projects/adt-build-machine-scripts/wiki/Tutorials)
##### DETAILED DOCUMENTATION FOR DEPLOYERS: [DEPLOYMENT DOCO](./doco/AgileToolkitDeployment)
##### DETAILED DOCUMENTATION FOR DEVELOPERS: [DEVELOPMENT DOCO](./doco/AgileToolkitDevelopment)
##### OPERATIONS DOCUMENTATION FOR DEPLOYERS: [OPERATIONS DOCO](./doco/AgileToolkitOperations)
##### THE SPECIFICATION: [SPECIFICATION](./templatedconfigurations/specification.md)
##### QUICK SPECIFICATION: [QUICK SPECIFICATION](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/templatedconfigurations/quick_specification.dat)

<!---
##### REGISTER FOR LIVE DEMO WEBSITE: [WINTERSYS DEMO](https://form.jotform.com/241855049555363)
-->

##### QUICK START DEMOS: [QUICK DEMOS](https://github.com/wintersys-projects/adt-build-machine-scripts/wiki/Quick-Start-Demos)  (deployed by you)

-----------------------------------

There are four repositories associated with this toolkit, this one, and the one's listed below. 

##### [Agile Infrastructure Autoscaler Scripts](https://github.com/wintersys-projects/adt-autoscaler-scripts)  
##### [Agile Infrastructure Webserver Scripts](https://github.com/wintersys-projects/adt-webserver-scripts)
##### [Agile Infrastructure Database Scripts](https://github.com/wintersys-projects/adt-database-scripts) 


-----------------------------------

#### CONCISE SUMMARY

Automatically install LEMP LAMP LLMP LEPP LAPP or LLPP using parameters only.

----------------------------------

#### WHAT IS A DMS (Deployment Management System)

A DMS, like this one, is a powertool for helping with deploying servers using well tested and secured processes. Its power is that it can be extended easily and is very similar to a CMS system but for deployment rather than content. The ultimate objective is to make it possible to have our own application directories. For example, in Joomla, something like a JAD (Joomla Applications Directory), in Wordpress something like a WAD (Wordpress Applications Directory) and in Drupal something like a DAD (Drupal Applications Directory). Application directories are envisioned to be whole applications that have been built (by expert application developers) to meet a particular business need and then the whole application is installed  ready for use "off the shelf" by a customer using this toolkit. For example, if you bought a solution like Hivebrite it would be a complete application already and you wouldn't need to do anything to build the application. VERY simple (built in minutes) examples of this are shown in the [Quick Start Demos](https://github.com/wintersys-projects/adt-build-machine-scripts/wiki/Quick-Start-Demos). Ultimately I realised that the model, as it is, with solutions like Hivebrite is that a company or organisation builds a generic solution and then the customer most likely has to "fit in" with that solution. What I am proposing here is that if there is an "Applications Directory" solution that fits your needs as a customer you can use that, but, you are also free to have a reusable application crafted to your specific needs as well and if you needs tally with someone else's needs then as a community service on your part they can reuse an application that was bespoke developed for your business need- do you see?  
A DMS like this one does require learning just like a CMS does but would you want to go back to coding in basic HTML once you have discovered CMS systems, probably not. Application developers using this toolkit should be able to produce high quality COTS (Commerical Off The Shelf) web applications using their CMS of choice and have the applications they have deveoped reused pre-configured by many customers making strides in all round productivity in the process. Think about the current model. If I want to build a "Community Builder" social network using Joomla I have to start from scratch if I can instead use a preconfigured application solution complete with online quality reviews from an applications directory and so on then to get my community going I just "install the application" and if it only meets 80% of my needs I can customise 20% of it rather than being a "non expert" trying to build 100% of it and that is where the productivity gain that I could see is and the core reason I thought about building this solution. 

-----------------------------------

#### SUPPORT NEEDED

**This toolkit has a lot of combined configurations and if for example one of the CMS systems changed how the sourcecode for it is downloaded or downloadable, that would break the installation of that CMS. For this reason its important to get feedback from people using the toolkit to discover if there are any breaks in how it is functioning. Its impossible as a single developer to monitor all configuration interplays and so the greatest help that a user of this software can be is if they report back if and when they find any breaks that have been introduced by 3rd party process changes that it depends on.** 


------------------------

#### THE CORE:

With the core of the Agile Deployment Toolkit, it will make use of a set of services and providers. I elected to use Digital Ocean, Exoscale, Linode and Vultr to deploy on or as deployment options, but, the toolkit is designed to be forked and extended to support other providers. The system is fully configurable by you and if you wish to change default configurations that are provided for, for example, Apache, NGINX or MariaDB, then you will need to fork the respoitories, alter your copy of the scripts and have them deploy according to your configuration requirements. A useful thing to be aware of if you are changing these scripts is you can check them syntactically with using <br><br>      "**/bin/sh -n <script.sh>**" <br><br> before you redeploy only to find you had a syntax error during deployment. 

The full set of services that are supported by the core of the toolkit and which you can extend in your forks is:

1. For VPS services, one of - Digital Ocean, Linode, Exoscale or Vultr
2. For Email services, one of - Amazon SES, Mailjet or Sendpulse
3. For Git based services, one of - Bitbucket, Github or Gitlab
4. For DNS services, one of - Cloudflare, Digital Ocean, Exoscale, Linode, Vultr (note, It is probably best practice to use Cloudflare even if there is some extra hassle to set it up which you can find out about here: [Cloudflare DNS](https://developers.cloudflare.com/learning-paths/get-started/). if you use one of the naked DNS solutions, you need to use a WAF or web application firewall to protect your application. If you Google WAF you can select your prefered solution from your search results.

5. For object store services, one of - Digital Ocean Spaces, Exoscale Object Store, Linode Object Store, Vultr Object Store
  
6. I chose these VPS providers to deploy with because they have (had in the case of Linode currently - 2024) managed database offerings, if you wish to make a production ready deployment with this toolkit it is recommended that you make your deloyment using their managed database offerings. For development deployments, you can use the default "apt" database install that this toolkit provides. 

--------------------------------

#### BUILD METHODS OVERVIEW

There are two types of build method you can employ to get a functioning application. These is the hardcore build (only use once you are more experienced with this tool), and the expedited build method. 

In both cases you need to have a thorough understanding of the specification which you can reference [here](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/templatedconfigurations/specification.md) of course. 

For an overview of the steps involoved in an expedited or hardocore build, please look [here](https://github.com/wintersys-projects/adt-build-machine-scripts/blob/main/doco/AgileToolkitDeployment/BuildStrategiesOverview.md))

-----

#### THE CONCLUSION

A DMS system such as this one can certainly speed your server deployments. It does require skill, and therefore learning to use. I have to leave this up to divine providence either other developers will want to take this forward and extend it, or, its operational footprint will stay as it is. My hope of course, is that there's interest from other developers in extending what has been done so far. As I was developing this timewise I would say that 30% of the effort was on developing it and 70% of the effort was on testing its function. That's why this toolkit will stand or fall on how earnestly it is used because with earnest use it can remain well maintained as issues are reported as they arise.   


