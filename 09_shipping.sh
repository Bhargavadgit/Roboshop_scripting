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

#we are using Java25 version so we need to set it as default version
alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java" &>> $log_file
#alternatives --set java "/usr/lib/jvm/java-21-openjdk/bin/java"  &>> $log_file
check_status $? "Setting Java 25 as default Java version"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME
check_status $? "Setting Java home version"


#Create Application User
id roboshop &>> $log_file
if  [ $? -ne 0 ]; then
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
unzip /tmp/shipping.zip  &>> $log_file
check_status $? "unzip " 

mvn clean package  &>> $log_file
check_status $? "MVN pacakge dependencies"

mv target/shipping.jar shipping.jar  &>> $log_file
check_status $? "Moving pacakge to shipping jar " 

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/shipping.service"
cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service


dnf install mysql -y  &>> $log_file
check_status $? "Install sql client " 

# check cities already exist or not 
cities_count=$(mysql -h "mysql.$domain_name"-u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $log_file )
#count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $log_file )
if  [ -z "$cities_count" ] || [ "$cities_count" -eq 0 ]; then
    mysql -h mysql.$domain_name -u root -pRoboShop@1 < /app/db/master-data.sql
     check_status $? "Loading shipping data"
     else 
    echo -e "$(timestamp) [INFO] Master data already loaded...${Y}SKIPPING${N}"
fi     

mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
check_status $? "Creating APP user"

# sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/shipping.service"
# cp "$script_dir/shipping.service" /etc/systemd/system/shipping.service



systemctl daemon-reload  &>> $log_file
check_status $? "daemon reload" 

systemctl enable shipping  &>> $log_file
check_status $? "enable shipping" 

systemctl start shipping  &>> $log_file
check_status $? "start shipping" 

systemctl restart shipping | tee -a $log_file
check_status $? "restart shipping"  


# user_id=$(id -u)
# logs_folder="/var/log/roboshop"
# logs_file="${logs_folder}/${0}.log"
# domain_name="bhar92s.store"
# scripts_dir=$(dirname "$(realpath "$0")")
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# if [ $user_id -ne 0 ]; then
#     echo "Please run this script with sudo access.."
#     exit 1
# fi

# mkdir -p $logs_folder

# timestamp(){
#     date "+%F %T" 
# }

# validate(){
#     if [ $1 -ne 0 ]; then
#         echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
#         exit 1
#     else
#         echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
#     fi
# }

# echo "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a $logs_file

# dnf module enable maven:3.9 -y &>> $logs_file
# dnf install maven java-25-openjdk-devel -y &>> $logs_file
# validate $? "Installing Java and Maven"

# alternatives --set java "/usr/lib/jvm/java-25-openjdk/bin/java"
# validate $? "Setting Java 25 as default Java version"

# echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh
# source /etc/profile.d/java.sh
# echo $JAVA_HOME
# validate $? "Setting JAVA_HOME for maven"

# id roboshop &>> $logs_file
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
#     validate $? "Creating system user"
# else
#     echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
# fi

# rm -rf /app
# validate $? "Removing old code"

# mkdir -p /app
# validate $? "Creating app directory"

# curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip &>> $logs_file
# validate $? "Downloading shipping"

# cd /app
# unzip /tmp/shipping.zip &>> $logs_file
# validate $? "Unzipping shipping"

# mvn clean package &>> $logs_file
# validate $? "Installing dependencies"

# mv target/shipping.jar shipping.jar
# validate $? "Moving shipping.jar file"

# sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/shipping.service"
# cp "$scripts_dir/shipping.service" /etc/systemd/system/shipping.service

# dnf install mysql -y &>> $logs_file
# validate $? "Installing MySQL client"

# count=$(mysql -h "mysql.$domain_name" -u root -pRoboShop@1 -N -B -e "SELECT COUNT(*) FROM cities.cities;" 2>> $logs_file )
# if [ -z "$count" ] || [ "$count" -eq 0 ]; then
#     mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/master-data.sql
#     validate $? "Loading shipping data in to cities table in sql"
# else
#     echo -e "$(timestamp) [INFO] Master data already loaded...${Y}SKIPPING${N}"
# fi

# mysql -h "mysql.$domain_name" -uroot -pRoboShop@1 < /app/db/app-user.sql
# validate $? "Creating APP user"

# systemctl daemon-reload &>> $logs_file
# systemctl enable shipping &>> $logs_file
# systemctl restart shipping
# validate $? "Restarting/Starting shipping"


# echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
# echo "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file

