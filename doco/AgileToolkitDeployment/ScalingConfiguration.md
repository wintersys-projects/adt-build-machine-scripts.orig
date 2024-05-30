This toolkit isn't really designed for usecases with sudden spikes in traffic its intended for use cases with much more predictable traffic patterns
So that you can setup a scaling pattern such as preemptively add a few machines at dawn in anticipation of the day's traffic and remove a few machines at night
in anticipation of lighter usage at night and so on. The scaling mechanism is static meaning that you have to tell the system how many machines you want to have
provisioned. I call it autoscaling because you can set up cron tasks to increase and decrease the number of provisioned machines on a temporal basis and if you 
look into the crontasks on an autoscaler machine you will easily see how this is so. You could set up as many cron tasks as you want to scale up and scale down
you could add 2 machines per hour if you wanted to by having a scale up cron task for each hour and similarly with scaling down. So there is a lot of flexibility
there but this solution doesn't scale based on load. There's a couple of ways that it could be modified to scale on load and that would be to find some reliable way to
measure how loaded the webserver machines are and alter the scaling metrics based on the (average) load that is found across them ( you might want to modify the scripts
to have a max machines limit so that if you get some ddos attack or something you don't scale to the high heavens). As things stand there's hard limits to the number
of machines that can be active, so, scaling to infinity is not currently a conceivable possibility. The other way is with providers like AWS they provide load based autoscaling
and that could be integrated into this solution with a bit of work and so that would give you an option to use what you might call "true autoscaling" with a provider like 
AWS by utilising their systems autoscaling capabilities and methods. You will notice that in the file I am about to describe "profile.cnf" there is the word "static" at the
top the idea is that if you wanted to use something like an AWS autoscaling system to proivision new machines with autoscalingn groups and so on you could indicate to the
system that you want to do that rather than use the default static scaling that I provide by putting the word "dynamic" in "profile.cnf".

You can configure the number of webservers that are running in the file  

>      s3://${configbucket}/scalingprofile/profile.cnf  

In most circumstances you will want to ssh onto your build machine and run the script: 

>      ${BUILD_HOME}/helperscripts/AdjustScaling.sh

to adjust the scaling criteria in real time. 

You can also configure the scaling process to intiate at set times in the day. For example, you might want to scale up from 3 to 8 webservers at 7:30AM each day and scaled down from 8 to 3 again at 5:30 pm. You can use these scripts by going onto your autoscaler machine and doing a crontab -e to edit them and (possibly) alter the perioidicity at which they activate. 

>     ${HOME}/providerscripts/utilities/DailyScaledown.sh  

>     ${HOME}/providerscripts/utilities/DailyScaleup.sh

from within cron to set how and when to scale up and scale down on a daily basis. If you want to set more scaling options automatically, you could, for example, make a copy of the **DailyScaleUp.sh** script and call it "MiddayScaleup.sh" and set a scaling event in cron such that there would be a daily scale up as well as your DailyScaledown and DailyScaleup
 
