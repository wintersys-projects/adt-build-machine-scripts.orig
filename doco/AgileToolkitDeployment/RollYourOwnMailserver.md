There are a few solutions to providing email services for your users:

1. Allow any domain email addresses in your application, like gmail, yahoo and so on.
2. If you want your users to have their own custom domain, you might have to pay for a custom domain email service, free ones seemed a bit thin on the ground to me
3. If you want to run your own email server, you can run one using "iRedmail" or "Mail in a box" or "Modoba". Please be aware it is not a trivial undertaking to run your own mail server. 

**NOTE** Cloudflare are providing an email routing service which you can setup to route people's emails through your domain to their own email address on gmail or hotmail or whatever. This requires that your domain is setup with Cloudflare, however and it remains to be seen if email addresses routing through Cloudflare can be setup programmatically through their API (in which case it would be great to have people register with their gmail address, detect it, and swap it out for a domain specific address which reroutes to their gmail address using cloudflare emial routing) or whether you would have to have an admin manually add people to the service.

Of course, if you want to use this solution for your pre-existing organisation and your peeps already have a custom email addresses, you can use the mail solution you already use or have.

The advantage that there sometimes is of self hosted domain specific email addresses is that you can require people to have one of your email addresses before you let them join your community. This is good from a couple of points of view. It means that you have control over who is joining and also, it enables the user to keep their business pertinent to your community separated from their other business. 

**If you do run your own mailserver, take it seriously or at least give a warning that people shouldn't use it for stuff that is vital to them in case you have an issue with it because email servers are complex to get right and are quite specialist**
