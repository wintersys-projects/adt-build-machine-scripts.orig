As far as I know Joomla currently only allows the usage of port 5432 when using postgres as your database.
This means that if you are using a managed DB service you will need to change the default port that the managed database supplies you with
to be 5432 when you are deploying joomla to a postgres database otherwise you will get a timeout because only port 5432 is allowed by Joomla.

Correct me if I am wrong and any updated info would be cool to know. 
