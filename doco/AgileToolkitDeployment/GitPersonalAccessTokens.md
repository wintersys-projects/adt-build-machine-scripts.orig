The prefered way to access github and gitlab repositories is to use a personal access token instead of a password. 
You can generate personal access tokens through their respective GUI systems, for example, [PAT](https://www.github.com/settings/tokens).
You can then use this token in place of a password when using these providers by setting the environment variable:  

**APPLICATION_REPOSITORY_TOKEN**

and you can leave 

**APPLICATION_REPOSITORY_PASSWORD**  

unset  

**MAKE SURE THE TOKEN IS GIVEN THE RIGHTS TO DELETE REPOSITORIES, OTHERWISE THERE WILL BE FAILURES RELATING TO BACKUPS AND SO ON AND ALSO, MAKE SURE THE TOKEN HAS NO EXPIRATION TIME OR YOU WILL HAVE TO GENERATE NEW ACCESS TOKENS WHEN IT EXPIRES AND UPDATE YOUR INFRASTRCTURE ACCORDINGLY**
