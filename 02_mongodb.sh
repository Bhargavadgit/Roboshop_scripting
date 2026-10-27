#!/bin/bash


user_id=$(id -u) #--getting userid
logs_folder="/var/log/roboshop_scripting"
log_file="${logs_folder}/${0}.log"

mkdir -p $logs_folder
validate $? "Directoey Created"
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
# cp mongo.repo
