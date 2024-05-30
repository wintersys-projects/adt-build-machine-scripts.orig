To enable FTP access for a 3rd party, put your system into maintenance mode and then once only one webserver is running:

>     useradd ftp_46732
>     usermod -a -G www-data ftp_46732  
>     passwd ftp_46732  
>     /bin/mkdir /home/ftp_46732  
>     /bin/chown ftp_46732:www-data /home/ftp_46732  

>     apt-get install vsftpd

>     vi /etc/vsftpd.conf

enter the values:

>     write_enable=YES
>     pasv_min_port=40000
>     pasv_max_port=60000

get the ip address of the client that wants to connect to your ftp server

>     ufw allow 20/tcp  
>     ufw allow 21/tcp  
>     ufw allow from any to any port 40000:60000 proto tcp

Punch a hole in your native firewalling system as well using your cloudhosting provider's gui system

>     systemctl restart vsftpd

>     mkdir -p /etc/vsftpd/user_config_dir

>     vi /etc/vsftpd/user_config_dir/ftp_46732

add the string  

>     local_root=/var/www/html   

>     vi /etc/vsftpd.conf

add the strings

>     user_config_dir=/etc/vsftpd/user_config_dir 

and

>     allow_writeable_chroot=YES

make sure to set to:  

>     chroot_local_user=YES
>     systemctl restart vsftpd

>     /usr/bin/find /var/www/html/ -type d -print -exec chmod 775 {} \\;  
>     /usr/bin/find /var/www/html/ -type f -print -exec chmod 664 {} \\;  


on the client machine that you have allowed access for in your firwalls

ftp <ip_address of your webserver with ftp enabled>  
enter your username and password that you set previously  
then enter   
ftp> pass (for passive mode)  
ftp>ls should then list /var/www/html  
ftp> put file  
ftp> ls /var/www/html/file  

when the updates to the webroot have been made:  

>     usermod -L ftp_46732

>     ufw status numbered
>     ufw delete <rule_no> 

and remove the rule which allowed access to a paricular ip address from your native firwall. 

>     /usr/bin/find /var/www/html -type d -print -exec chown www-data:www-data {} \;  
>     /usr/bin/find /var/www/html -type d -print -exec chmod 755 {} \; 
>     /usr/bin/find /var/www/html -type f -print -exec chmod 644 {} \;


next time you want to allow ftp access you will need to 

>     usermod -U ftp_46732
