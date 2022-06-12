#!/bin/bash

PASSWORD="password"

for user in $(cat $1)
 do

	 if [ ! -d /etc/skel/.ssh/ ]
	 then
		 echo "Copying authorized_keys to /etc/skel";
		 sudo mkdir /etc/skel/.ssh
		 sudo cp /home/$USER/.ssh/id_rsa.pub /etc/skel/.ssh/authorized_keys
	 fi

	 if [ id -u $user > /dev/null 2>&1 ]
	 then
		 echo "User exists";
		 continue
	 else
		 echo "Adding user";
		 sudo useradd $user -G developers -m
		 echo -e "$PASSWORD\n$PASSWORD" | sudo passwd $user
		 sudo passwd -x 5 $user
		 sudo chmod 700 /home/$user/.ssh
		 sudo chmod 644 /home/$user/.ssh/authorized_keys
	 fi

 done

 echo "Done."



