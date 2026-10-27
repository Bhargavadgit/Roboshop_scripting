#!/bin/bash


user_id=$(id -u) #--getting userid
logs_folder="/var/log/roboshop_scripting"
log_file="${logs_folder}/${0}.log"
#-- add clours to messages
R='\e[31m' # Red
G='\e[32m' # Green
Y='\e[33m' # Yellow
N='\e[0m'  # No Color

mkdir -p $logs_folder


if [ $user_id -ne 0 ]; then
    echo "Please run scripts with sudo user / conatct Admin"
    exit 1
fi

Timestamp(){
    (date +"%F %t")
}

validate(){
    if [ $1 -eq 0 ]; then  
        echo "$2 success"
    else
       echo "$2 failed"
        exit 1
    fi
}
echo "==============Script start $timestamp ============"
cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "${G}Mongo Repo copied...${N}"

dnf install mongodb-org -y  &>> log_file
validate $? "Installing Mongodb"

systemctl enable mongod
systemctl start mongod
Validate $? "Enable & restarting Mongodb"

echo "Total time ::$seconds"
echo "===============Script end $timestamp ============"


