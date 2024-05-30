**NOTE: THE SMTP CREDENTIALS THAT YOU SET AT BUILD TIME FOR YOUR APPLICATION ARE AVAILABLE AS FOLLOWS POST DEPLOYMENT:**  

**For wordpress: /var/www/wordpresssmtp**  
**For moodle: /var/www/moodlesmtp**  
**For Drupal: /var/www/drupalsmtp**  
**For Joomla: /var/www/html/configuration.php**  

The SMTP service is used to send emails from the deployed applications and also system messages from the deployment infrastructure itself. 
At the time of writing, I have added 3 SMTP services for a deployer to choose from when making a build. One is www.sendpulse.com and the other mailjet (mailjet.com) and the 3rd one is Amazon SES

To send SMTP mail, the first thing you will need to do is set yourself up an account with your provider of choice. With sendpulse, you have to use an existing email address that you already own. Similarly you will have to sign up for mailjet to use it as your relay. 

