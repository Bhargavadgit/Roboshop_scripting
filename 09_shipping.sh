#!/bin/bash
# to see logs on screen while running use | tee -a log_file
# to send logs for running status use &> $log_file
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp
# to check user already exist or not use id
user_id=$(id -u) #get user id
logs_folder="/var/log/Roboshop_scripting"
log_file="${logs_folder}/${0}.log"
script_dir=$(dirname "$(realpath "$0")")
domain_name="bhar92s.store"
R="\e[31m" #red
G="\e[32m" #Green
Y="\e[33m" #yellow
N="\e[0m"  #normal

if [ $user_id -ne 0 ];then
 echo -e "${R}not root user${N} "
 exit 1
 else 
 echo "Processing..."
fi

mkdir -p $logs_folder

timestamp(){
    date "+%F %T"
}

check_status(){
    if  [ $1 -ne 0 ]; then
        echo -e "...[error]...${R} $2.. Failed...${N}.... at $(timestamp)"
        exit 1
        else
        echo -e "...[info]...${G} $2.. success...${N}.....at $(timestamp)"
    fi
}

echo "===================Script Started at $(timestamp)==================" | tee -a $log_file
#dnf module enable maven:3.9 -y  &>> $log_file
dnf install maven -y &>> $log_file
check_status $? "install maven" 

dnf install maven java-25-openjdk-devel -y  &>> $log_file
check_status $? " maven java 25" 

alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java" &>> $log_file
#alternatives --set java "/usr/lib/jvm/java-21-openjdk/bin/java"  &>> $log_file
check_status $? "Setting Java 21 as default Java version"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
check_status $? "Setting Java home version"

#Create Application User
id roboshop &>> $log_file
if  [ $? -ne 0]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    check_status $? "setting up application user"
    else 
    echo "..[info]...application user exist ...{Y}skipping{N}...."
fi  
rm -rf /app  &>> $log_file
check_status $? "Removing old data in app"

mkdir /app  &>> $log_file
check_status $? "creating app directory"

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip

cd /app
unzip /tmp/shipping.zip
check_status $? "unzip " 

cd /app
mvn clean package
check_status $? "MVN pacakge " 

mv target/shipping.jar shipping.jar
check_status $? "Moving pacakge to shipping jar " 

dnf install mysql -y
check_status $? "Install sql client " 

# check cities already exist or not 
cities_count=$(mysql -h "mysql.$domain_name"-u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $logs_file )
#count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $logs_file )
if  [ -z $cities_count ] || [ cities_count -ne 0 ]; then
    mysql -h mysql.$domain_name -u root -pRoboShop@1 < /app/db/master-data.sql
     check_status $? "Loading shipping data"
     else 
    echo -e "$(timestamp) [INFO] Master data already loaded...${Y}SKIPPING${N}"
fi     

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/shipping.service"
cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service


systemctl daemon-reload  &>> $log_file
check_status $? "daemon reload" 

systemctl enable shipping  &>> $log_file
check_status $? "enable shipping" 

systemctl start shipping  &>> $log_file
check_status $? "start shipping" 

systemctl restart shipping | tee -a $log_file
check_status $? "restart shipping"  

echo "===================Script ended at $(timestamp)==================" | tee -a $log_file