#!/bin/bash

## Variable values and datacapture: 

read -p "Please enter install base install directory: " installdir
read -p "Please enter the root user for mysql: " mysqlrootuser
read -p "Please enter the root password for mysql: " mysqlrootpass
read -p "Please enter your desired DB User Name: " dbusername
read -p "Please enter your desired DB User Password: " dbuserpass
read -p "Please enter the name of your Database: " dbname
read -p "Please enter value for Zone IP settings: " zoneip
read -p "Please enter IP address of the SEARCH server: " searchip
read -p "Please enter the IP address of the LOGIN server: " loginip
read -p "Plese enter the IP address of the MAP server: " mapip 

echo "Preparing to deploy DSP: Quetz..."

echo "Creating install directory in: '${installdir}' ..."
mkdir -p ${installdir}
mkdir -p ${installdir}/temp
mkdir -p ${installdir}/dsp_init && echo "Install dirs created..."

echo "Deploying installation and auto-setup files..."

tar xf install_dsp.tz -C ${installdir}/tmp/ && echo "Installation files ready..."

echo "Creating DB User & Database..."

sed -i 's/zoneipreplace/'${zoneip}'/g' ${installdir}/temp/zone_ip.sql && echo "Zone IP configured..."
sed -i 's/dbusername'/${dbusername}'/g' ${installdir}/temp/create_users.sql && echo "DB user configured..."
sed -i 's/dbuserpass/'${dbuserpass}'/g' ${installdir}/temp/create_users.sql && echo "DB password configured..."
sed -i 's/dbname/'${dbname}'/g' ${installdir}/temp/create_users.sql && echo "DB name configured..."

mysql -u ${mysqlrootuser} -p${mysqlrootpass} < ${installdir}/temp/create_users.sql && echo "User & Database created successfully!"
 
echo "Grabbing Quetz code..."

git clone https://github.com/m241dan/darkstar.git ${installdir}/git_clone_code && echo "Clone of QR branch complete.."

## Grabbing Quetz code but running DB inits from original DSP: 

echo "Removing SQL & inits from QR branch..."

rm -r ${installdir}/git_clone_code/sql && echo "Dropped DSP DB init..."

"Grabbing DB build/inits from DSP & merging into Quetz..."

git clone http://github.com/DarkstarProject/darkstar.git/ ${installdir}/dsp_init/

cp -r ${installdir}/dsp_init/sql ${installdir}/git_clone_code/

## Now the actual init of the dabatase:

for i in ${installdir}/git_clone_code/sql/*.sql
        do
        echo -n "Importing $i into the database..."
        mysql ${dbname} -u ${dbusername} -p${dbuserpass} < $i && echo "Successfully imported..."
        done

mysql -u ${dbusername} -p${dbuserpass} < ${installdir}/temp/zone_ip.sql
