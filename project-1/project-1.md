# PROJECT-1 [WEB STACK IMPLEMENTATION (LAMP STACK)]

## *STEP 0

-Create an AWS account
 ![AWS-account](./images/AWS-account.PNG)

-connect EC2
![connect-ec2.PNG](./images/connect-ec2.PNG)
 ## *STEP 1

-INSTALLING APACHE AND UPDATING THE FIREWALL

-update a list of packages in package manager

`sudo apt update`

![sudo-apt-update](./images/sudo-apt-update.PNG)


-run apache2 package installation

`sudo apt install apache2`

![install-apache2](./images/install-apache2.PNG)


-verify that apache2 is running as a Service in our OS

`sudo systemctl status apache2`

![systematic-status](./images/systematic-status.PNG)


-access port 80 locally

`curl http://localhost:80`

![access-port80-locally1](./images/access-port80-locally1.PNG)

![access-port80-locally2](./images/access-port80-locally2.PNG)


-Open a web browser of your choice and try to access following url
`http://<Public-IP-Address>:80`

![access-url](./images/access-url.PNG)



-retrieving ip address in command prompt

`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`

![accessing-url-in-terminal](./images/accessing-url-in-terminal.PNG)


## *STEP 2

-INSTALLING MYSQL

-install mysql through terminal

`sudo apt install mysql-server`

![install-mysql-server1](./images/install-mysql-server1.PNG)

![install-mysql-server2](./images/install-mysql-server2.PNG)


-testing mysql

`sudo mysql_secure_installation`

![testing-mysql](./images/testing-mysql.PNG)


-login mysql

`sudo mysql`

![login-mysql](./images/login-mysql.PNG)

-exit mysql

`exit`

![exit-mysql](./images/exit-mysql.PNG)





## *STEP 3

-INSTALLING PHP

-installing PHP

`sudo apt install php libapache2-mod-php php-mysql`

`php -v`

![php-install](./images/php-install.PNG)


## *STEP 4 

—CREATING A VIRTUAL HOST FOR YOUR WEBSITE USING 
 APACHE

`sudo mkdir /var/www/projectlamp`

`sudo chown -R $USER:$USER /var/www/projectlamp`

`sudo vi /etc/apache2/sites-available/projectlamp.conf`

<VirtualHost *:80>

    ServerName projectlamp
    ServerAlias www.projectlamp 
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/projectlamp
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>

`sudo ls /etc/apache2/sites-available`

`sudo a2ensite projectlamp`

`sudo a2dissite 000-default`

`sudo apache2ctl configtest`

`sudo systemctl reload apache2`

![projectlamp-comp](./images/projectlamp-comp.PNG)

-Create an index.html file in that location so that we can test that the virtual host works as expected

![new-website](./images/new-website.PNG)



## *STEP 5 

—ENABLE PHP ON THE WEBSITE

-http://13.52.235.5:80

![website-check](./images/website-check.PNG)

-remove the file you created

`sudo rm /var/www/projectlamp/index.php`


![file-remove](./images/file-remove.PNG)

# *END OF PROJECT-1*


