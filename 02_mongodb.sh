#!/bin/bash


user_id=$(id -u) #--getting userid
logs_folder="/var/log/roboshop_scripting"
log_file="${logs_folder}/${0}.log"
#-- add clours to messages
R="\e[31m" # Red
G="\e[32m" # Green
Y="\e[33m" # Yellow
N="\e[0m"  # No Color

mkdir -p $logs_folder


if [ $user_id -ne 0 ]; then
    echo "Please run scripts with sudo user / conatct Admin"
    exit 1
fi

timestamp(){
    (date +"%F %t")
}

check_status(){
    if [ "$1" -eq 0 ]; then  
        echo -e "${G} $2 success...${N}..$(timestamp)"
    else
       echo -e "${R} $2 Failed...${N}..$(timestamp)"
        exit 1
    fi
}
echo "==============Script start $(timestamp) ============"
cp mongo.repo /etc/yum.repos.d/mongo.repo
check_status  $?  "..Mongo Repo copied..."

dnf install mongodb-org -y  &>> log_file
check_status $? "Installing Mongodb"

systemctl enable mongod  &>> log_file
check_status $? "Enable  Mongodb"
systemctl start mongod  &>> log_file
check_status $? "starting Mongodb"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf

systemctl restart mongod  &>> log_file
check_status $? "restarting Mongodb"

systemctl status mongod | tee -a log_file

echo "Total time ::$SECONDS"
echo "===============Script end $(timestamp) ============"


