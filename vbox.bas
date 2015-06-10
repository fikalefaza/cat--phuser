#!/bin/bash -ex

#By Rik Goldman

# Set Hostname
HOSTNAME=virtualbox
echo "$HOSTNAME" > /etc/hostname
sed -i "s|127.0.1.1 \(.*\)|127.0.1.1 $HOSTNAME|" /etc/hosts

echo "deb http://download.virtualbox.org/virtualbox/debian lucid contrib" >> /etc/apt/sources.list.d/sources.list

wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | apt-key add -

useradd --home /var/virtualbox virtualbox

#If home directory isn't created, create one now and set permissions
if [ ! -d /var/virtualbox ]; then
    mkdir /var/virtualbox
    mkdir /var/virtualbox/import
    chown -R virtualbox:virtualbox /var/virtualbox
    chmod 777 /var/virtualbox/import
fi

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get -y \
    -o DPkg::Options::=--force-confdef \
    -o DPkg::Options::=--force-confold \
    install build-essential \
    dkms \
    linux-generic-pae \
    linux-headers-generic-pae \
    apache2 \
    libapache2-mod-php5 \
    php5 \
    virtualbox-4.0 \
    webmin-apache \
    dialog \
    samba \
    webmin-samba \
    webmin-phpini
    

#Make a request of VBoxManage so service can be setop
#VboxManage list ostypes - doesn't work

#Setup vboxdrv
#/etc/init.d/vboxdrv setup - moved to inithook

#Create vbog.cfg
echo -e "VBOXWEB_USER=virtualbox" > /etc/vbox/vbox.cfg

#Set vboxweb-service service
update-rc.d vboxweb-service defaults

#Original Way to download, place phpvirtualbox, then clean up
#wget http://phpvirtualbox.googlecode.com/files/phpvirtualbox-4.0-3.zip


wget `wget -q -O - http://phpvirtualbox.googlecode.com/files/LATEST.txt` -O phpvirtualbox-latest.zip
unzip -n phpvirtualbox-latest.zip -d /var/www/
#rm phpvirtualbox-latest.zip

#Install extpack - Moved to firstboot.d
#wget http://download.virtualbox.org/virtualbox/4.0.2/Oracle_VM_VirtualBox_Ext... -O /var/virtualbox/Oracle_VM_VirtualBox_Extension_Pack-4.0.2-69518.vbox-extpack
#VBoxManage extpack install Oracle_VM_VirtualBox_Extension_Pack-4.0.2-69518.vbox-extpack
#rm /var/virtualbox/Oracle_VM_VirtualBox_Extension_Pack-4.0.2-69518.vbox-extpack


#Soft Links to phpvirtualbox
ln -s /var/www/phpvirtualbox-4.0-3 /var/www/phpvirtualbox
ln -s /var/www/phpvirtualbox-4.0-3 /var/www/virtualbox
ln -s /var/www/phpvirtualbox-4.0-3 /var/www/vb

#Enable virtualbox site
a2ensite phpvirtualbox

#Stop Services
/etc/init.d/apache2 stop
/etc/init.d/vboxdrv stop
/etc/init.d/vboxweb-service stop
