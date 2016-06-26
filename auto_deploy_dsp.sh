#!/bin/bash

## Variable values and datacapture: 

current_dir=$(pwd)

echo ""
echo "## Capturing Required Config for install:"
echo ""
read -p "Please enter install base install directory: " installdir
read -p "Please enter MySQL host address (127.0.0.1): " sqlhost
read -p "Please enter the root user for mysql: " mysqlrootuser
read -p "Please enter the root password for mysql: " mysqlrootpass
read -p "Please enter your desired DB User Name: " dbusername
read -p "Please enter your desired DB User Password: " dbuserpass
read -p "Please enter the name of your Database: " dbname
read -p "Please enter value for Zone IP settings (127.0.0.1): " zoneip
read -p "Please enter IP address of the SEARCH server (127.0.0.1): " searchip
read -p "Please enter the IP address of the LOGIN server (127.0.0.1): " loginip
read -p "Plese enter the IP address of the MAP server (127.0.0.1): " mapip 
read -p "Plese enter the IP address of the MESSAGE server (shared across all configs): " msgip

echo ""
echo "##Preparing to deploy DSP: Quetz..."
echo ""

echo ""
echo "##Creating install directory in: '${installdir}' ..."
echo ""
mkdir -p ${installdir}
mkdir -p ${installdir}/tmp
mkdir -p ${installdir}/dsp && echo "	--Install dirs created..."

echo ""
echo "##Deploying installation and auto-setup files..."
echo ""

cp ${current_dir}/install_dsp.tz ${installdir}/

tar xf ${installdir}/install_dsp.tz -C ${installdir}/tmp/ && echo "	--Installation files ready..."

echo ""
echo "##Creating DB User & Database..."
echo ""

sed -i 's/zoneipreplace/'${zoneip}'/g' ${installdir}/tmp/zone_ip.sql && echo "	--Zone IP configured..."
sed -i 's/dbusername'/${dbusername}'/g' ${installdir}/tmp/create_users.sql && echo "	--DB user configured..."
sed -i 's/dbuserpass/'${dbuserpass}'/g' ${installdir}/tmp/create_users.sql && echo "	--DB password configured..."
sed -i 's/dbname/'${dbname}'/g' ${installdir}/tmp/create_users.sql && echo "	--DB name configured..."

mysql -u ${mysqlrootuser} -p${mysqlrootpass} < ${installdir}/tmp/create_users.sql && echo "	--User & Database created successfully!"

echo ""
echo "##Grabbing stable DSP branch..."
echo ""

git clone http://github.com/DarkstarProject/darkstar.git/ ${installdir}/dsp/

echo ""
echo "## Now the actual init of the dabatase:"
echo ""

for i in ${installdir}/dsp/sql/*.sql
        do
        echo -n "Importing $i into the database..."
        mysql ${dbname} -u ${dbusername} -p${dbuserpass} < $i && echo "Successfully imported...$1"
        done && echo "Base database seed complete!"

mysql -u ${dbusername} -p${dbuserpass} < ${installdir}/tmp/zone_ip.sql && echo "Zone IP config applied to database..."

echo ""
echo "	--Database seed & config complete!"
echo ""

echo ""
echo "##Apply configuration changes to server configs..."
echo ""

sed -i 's/sqlhost'/${sqlhost}'/g' ${installdir}/tmp/map_darkstar.conf
sed -i 's/msgip'/${msgip}'/g' ${installdir}/tmp/map_darkstar.conf
sed -i 's/dbusername'/${dbusername}'/g' ${installdir}/tmp/map_darkstar.conf
sed -i 's/dbuserpass'/${dbuserpass}'/g' ${installdir}/tmp/map_darkstar.conf
sed -i 's/dbname'/${dbname}'/g' ${installdir}/tmp/map_darkstar.conf && echo "	--Map server configuration applied..."

sed -i 's/loginip'/${loginip}'/g' ${installdir}/tmp/login_darkstar.conf
sed -i 's/sqlhost'/${sqlhost}'/g' ${installdir}/tmp/login_darkstar.conf
sed -i 's/msgip'/${msgip}'/g' ${installdir}/tmp/login_darkstar.conf
sed -i 's/dbusername'/${dbusername}'/g' ${installdir}/tmp/login_darkstar.conf
sed -i 's/dbuserpass'/${dbuserpass}'/g' ${installdir}/tmp/login_darkstar.conf
sed -i 's/dbname'/${dbname}'/g' ${installdir}/tmp/login_darkstar.conf && echo "	--Login server configuration applied..."

sed -i 's/sqlhost'/${sqlhost}'/g' ${installdir}/tmp/search_server.conf
sed -i 's/dbusername'/${dbusername}'/g' ${installdir}/tmp/search_server.conf
sed -i 's/dbuserpass'/${dbuserpass}'/g' ${installdir}/tmp/search_server.conf
sed -i 's/dbname'/${dbname}'/g' ${installdir}/tmp/search_server.conf && echo "	--Search server configuration applied..."

cp ${installdir}/tmp/*.conf ${installdir}/dsp/conf/ && echo "...and applied to server."

echo ""
echo "##Time to run the code compile..."
echo ""

cd ${installdir}/dsp/

sh autogen.sh && echo "	--Autogen complete..."

./configure --enable-debug=gdb > ${installdir}/dsp/configure_install.log && echo "Configure complete...see configure_install.log for details... "

make > ${installdir}/dsp/make_install.log && echo "Make complete! See make_install.log for details..."


