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

Timestamp(){
    (date +"%F %t")
}

check_status(){
    if [ $1 -eq 0 ]; then  
        echo "$2 success"
    else
       echo "$2 failed"
        exit 1
    fi
}
echo "==============Script start "$Timestamp" ============"

dnf module disable redis -y
check_status $? "Diable Redis defalut"
dnf module enable redis:7 -y
check_status $? "enable Redis 7"
dnf install redis -y
check_status $? "Installing Redis 7"

echo "==============Script end at ${Timestamp} ============"
echo "==============Script end at "$Timestamp" ============"


