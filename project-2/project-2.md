# PROJECT-2 [WEB STACK IMPLEMENTATION (LEMP STACK)]
## *Step 0 

–Preparing prerequisites

-AWS accound and EC2 instance ready

-GitBash downloaded and installed

`ssh -i <Your-private-key.pem> ubuntu@<EC2-Public-IP-address>`

![gitbash-ec2-connect](./Images/gitbash-ec2-connect.PNG)

## *STEP 1 
 
–INSTALLING THE NGINX WEB SERVER

-install Nginx

`sudo apt update`

![update](./Images/update.PNG)

`sudo apt install nginx`

![install-nginx](./Images/install-nginx.PNG)

`sudo systemctl status nginx`

![nginx-status](./Images/nginx-status.PNG)

`curl http://localhost:80`

![check-access](./Images/check-access.PNG)
- open http://<Public-IP-Address>:80 through any browser

![nginx-browse](./Images/nginx-browse.PNG)
`curl -s http://169.254.169.254/latest/meta-data/public-ipv4`

![curl](./Images/curl.PNG)


## STEP 2 

—INSTALLING MYSQL
`sudo apt install mysql-server`

![install-mysql](./Images/install-mysql.PNG)

`sudo mysql_secure_installation`

![secure-install1](./Images/secure-install1.PNG)
![secure-install2](./Images/secure-install2.PNG)

`sudo mysql`

`exit`

![mysql-test](./Images/mysql-test.PNG)

## STEP 3 

–INSTALLING PHP

`sudo apt install php-fpm php-mysql`

![install-phpfpm](./Images/install-phpfpm.PNG)

## STEP 4 

—CONFIGURING NGINX TO USE PHP PROCESSOR

`sudo mkdir /var/www/projectLEMP`

`sudo chown -R $USER:$USER /var/www/projectLEMP`

`sudo nano /etc/nginx/sites-available/projectLEMP`

-included the file below

/etc/nginx/sites-available/projectLEMP

server {
    listen 80;
    server_name projectLEMP www.projectLEMP;
    root /var/www/projectLEMP;

    index index.html index.htm index.php;

    location / {
        try_files $uri $uri/ =404;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
     }

    location ~ /\.ht {
        deny all;
    }
}
`sudo ln -s /etc/nginx/sites-available/projectLEMP /etc/nginx/sites-enabled/`

![projectlemp](./Images/projectlemp.PNG)

`sudo nginx -t`

`sudo unlink /etc/nginx/sites-enabled/default`

`sudo systemctl reload nginx`

`sudo echo 'Hello LEMP from hostname' $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) 'with public IP' $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4) > /var/www/projectLEMP/index.html`

open http://<Public-IP-Address>:80 through browser

![nginx-browse](./Images/nginx-browse.PNG)

## STEP 5 
–TESTING PHP WITH NGINX

`sudo nano /var/www/projectLEMP/info.php`

-Insert the file below

[<?php
phpinfo();]

Open http://ec2-54-193-68-224.us-west-1.compute.amazonaws.com/info.php in any browser

![info.php-access](./Images/info.php-access.PNG)


## STEP 6

–RETRIEVING DATA FROM MYSQL DATABASE WITH PHP

`sudo mysql`

`mysql> CREATE DATABASE example_database;`

`(CREATE USER 'example_user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';)`

`GRANT ALL ON example_database.* TO 'example_user'@'%';`

`exit`

![sql-table](./Images/sql-table.PNG)

`mysql -u example_user -p`

`SHOW DATABASES;`

`(CREATE TABLE example_database.todo_list ( item_id INT AUTO_INCREMENT,  content VARCHAR(255),  PRIMARY KEY(item_id));)`

`INSERT INTO example_database.todo_list (content) VALUES ("My first important item");`

`SELECT * FROM example_database.todo_list;`

` exit`

![mysql-database](./Images/mysql-database.PNG)

`nano /var/www/projectLEMP/todo_list.php`

-Copy the below content into your todo_list.php script:

[<?php
$user = "example_user";
$password = "password";
$database = "example_database";
$table = "todo_list";]

`[try {
  $db = new PDO("mysql:host=localhost;dbname=$database", $user, $password);
  echo "<h2>TODO</h2><ol>";
  foreach($db->query("SELECT content FROM $table") as $row) {
    echo "<li>" . $row['content'] . "</li>";
  }
  echo "</ol>";
} catch (PDOException $e) {
    print "Error!: " . $e->getMessage() . "<br/>";
    die();
}]`

-open http://<Public_domain_or_IP>/todo_list.php

![database-browse](./Images/database-browse.PNG)

# END OF PROJECT-2 
