#!/bin/bash
# to see logs on screen while running use | tee -a log_file
# to send logs for running status use &> $log_file
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp
# to check user already exist or not use id
user_id=$(id -u) #get user id
logs_folder="/var/log/Roboshop_scripting"
log_file="${logs_folder}/${0}.log"
R="\e[31m" #red
G="\e[32m" #Green
Y="\e[33m" #yellow
N="\e[0m"  #normal

mkdir -p $logs_folder

if [ $user_id -ne 0 ]; then
    echo -e "${R}..please run script with sudo user / contact admin${N}"
    exit 1
fi

timestamp(){
    date "+%F %T"
}

check_status(){
    if  [ $1 -ne 0 ]; then
     echo -e "${R} $2.. Failed...${N} at $(timestamp)"| tee -a log_file
     exit 1
    else
     echo -e "${G} $2.. success...${N} at $(timestamp)"| tee -a log_file
    fi
}

echo "===================Script Started at $(timestamp)=================="
dnf module disable nodejs -y
check_status $? "diabled default module"

dnf module enable nodejs:24 -y
check_status $? "diabled enable module nodejs24"

dnf install nodejs -y
check_status $? "installed nodejs24"

# adding user befor check if any users already added or not use command id roboshop
useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop





echo "Total time ::$SECONDS"
echo "===================Script ended at $(timestamp)=================="