There is a file in the webroot of baselined applications which tell you which database it was built with.  

This file is /var/www/html/dbe.dat  

and it will tell you  whether the application was baselined with MariaDB, MySQL or Postgres  
You should only deploy using the same database as is written to this file in other words, MariaDB and MySQL are not considered interchangeable  
