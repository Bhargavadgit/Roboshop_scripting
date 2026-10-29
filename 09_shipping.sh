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
     echo -e "...[info]...${G} $2.. success...${N}.....at $(timestamp)"|
    fi
}

echo "===================Script Started at $(timestamp)==================" | tee -a log_file


dnf module enable maven:3.9 -y  &>> $log_file
check_status $? "enable Maven..."

dnf install maven java-25-openjdk-devel -y  &>> $log_file
check_status $? "Install Maven..."

alternatives --set java "java-21-openjdk.x86_64 (/usr/lib/jvm/java-21-openjdk-21.0.12.1.1-1.2.el9.x86_64/bin/java)"  &>> $log_file
check_status $? "Setting Java 21 as default Java version"

echo "export JAVA_HOME=$(dirname $(dirname $(readlink -f /usr/bin/java)))" > /etc/profile.d/java.sh  &>> $log_file
source /etc/profile.d/java.sh &>> $log_file
echo $JAVA_HOME  &>> $log_file
check_status $? "java home version"

# adding user,befor check if any users already added or not use command id roboshop
id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    echo "${Y}no user exist creating user${N}"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    check_status $? "user added to roboshop"
    else 
    echo -e "${Y} system user exist ..Skipping${N}"    
fi

#remove old files
rm -rf /app  &>> $log_file
check_status $? "remove old files app directory"  
mkdir /app  &>> $log_file
check_status $? "Creating app directory"  

curl -L -o /tmp/shipping.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/shipping-v4.zip
check_status $? "Downloading shipping"

cd /app  &>> $log_file
unzip /tmp/shipping.zip  &>> $log_file
check_status $? "unzip shipping"  

cd /app   &>> $log_file
mvn clean package   &>> $log_file
check_status $? "Installing dependencies"  
mv target/shipping.jar shipping.jar  &>> $log_file
check_status $? "moving shipping file"  

dnf install mysql -y  &>> $log_file
check_status $? "Install the MySQL client"  

# before loading the cities check if already exist or not, why because first time there is no cities it will load then
#through an error for loading cts
# check in google for geeting only number output  in shell command to find records count in mysql table
count=$(mysql -h mysql.bhar92s.store -uroot -pRoboShop@1  -N -B -e "SELECT COUNT(*) FROM cities.cities;") &>> $log_file
check_status $? "checking cities count"

if  [ $count -eq 0 ]; then
        mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/master-data.sql  | tee -a $log_file
        check_status $? "loading cities"  
    else
    echo "cities loaded already .....${Y}Skipping${N}"   | tee -a $log_file
fi        

id roboshop &>> $log_file
check_status $? "checking user existance"   | tee -a $log_file

if [ $? -ne 0 ]; then
    mysql -h mysql.$domain_name -uroot -pRoboShop@1 < /app/db/app-user.sql   | tee -a $log_file
    check_status $? "Create the app user"
    else
    echo "${Y}User exist...{N}"  | tee -a $log_file
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

echo "===================Script ended at $(timestamp)==================" | tee -a log_file