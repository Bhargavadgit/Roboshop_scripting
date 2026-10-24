#!/bin/bash

User_id=$(id -u) #--get userid
logs_folder= "/var/log/Roboshop_Scripting"
logs_file="${logs_folder}/${0}.log"

if [ $user_id -ne 0 ]; then
    echo "You are not root user, Please run the script with root user"
    exit 1
fi

mkdir -p $logs_Folder

date(){
   $(date "+%F_%T")
}

echo "=============[info]Script Start time $date ===============






echo "=============[info]Script end time $date ==================