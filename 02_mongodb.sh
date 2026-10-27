#!/bin/bash


user_id=$(id -u) #--getting userid
logs_folder="/var/logs/roboshop_scripting"
log_file="${logs_folder}/${0}.log"

if [ $user_id -ne 0 ]; then
    echo "Please run scripts with sudo user / conatct Admin" &>> log_file
    exit 1
fi

mkdir -p $logs_folder

Timestamp(){
    (date +"%F %t")
}
