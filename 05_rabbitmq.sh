#!/bin/bash
# to see logs on screen while running use | tee -a log_file
# to send logs for running status use &> $log_file
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp

user_id=$(id -u) #getting user id
logs_folder="/var/log/Roboshop_scripting"
log_file="${logs_folder}/${0}.log"
R="\e[31m" # Red
G="\e[32m" # Green
Y="\e[33m" # Yellow
N="\e[0m"  # No Color

if [ $user_id -eq 0 ]; then
    echo "Proceding......"
else
    echo "Please run scripts with sudo user / conatct Admin"
    exit 1
fi

mkdir -p $logs_folder

timestamp(){
    (date "+%F_%T")
}

check_status(){
if [ $1 -ne 0 ]; then
    echo -e "$2 ${R}failed${N} at $(timestamp)" | tee -a log_file
    exit 1
else
    echo -e "$2 ${G}success${N}at $(timestamp)"  | tee -a log_file  
fi
}

echo "================Script started $(timestamp)================="

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>> $log_file
check_status $? "Coping rabbitmq.repo......"

dnf install erlang rabbitmq-server -y   &>> $log_file
check_status $? "installed rabbitmq......"

systemctl enable rabbitmq-server  &>> $log_file
systemctl start rabbitmq-server   &>> $log_file
check_status $? "enabled & started rabbitmq......"

#adding user
rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $log_file
    check_status $? "adding user for roboshop"
else   
    echo -e "user alredy exist..${Y}skipping..${N}"
fi    
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
check_status $? "setting permissions for user in roboshop"

echo "================Script ended $(timestamp)================="| tee -a $logs_file
echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"


