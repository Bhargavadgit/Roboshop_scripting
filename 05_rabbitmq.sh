#!/bin/bash
# to see logs on screen while running use | tee -a log_file
# to send logs for running status use &> $log_file
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp

user_id=$(id -u) #getting user id
logs_folder="/var/log/Roboshop_scripting"
log_file="${logs_folder}/${0}.log"


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
    echo "$2 ${R}failed${N} at $(timestamp)" | tee -a log_file
    exit 1
else
    echo "$2 ${G}success${N}at $(timestamp)"  | tee -a log_file  
fi
}

echo "================Script started $(timestamp)================="

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "${G}Coping rabbitmq.repo......${N}"

dnf install erlang rabbitmq-server -y
validate $? "${G}installed rabbitmq......${N}"

systemctl enable rabbitmq-server
systemctl start rabbitmq-server
validate $? "${G}enabled & started rabbitmq......${N}"

#adding user
rabbitmqctl list_users | grep -qw "roboshop"
if [ $? -ne 0 ]; then
    rabbitmqctl add_user roboshop roboshop123 &>> $log_file
    validate $? "adding user for roboshop"
else   
    echo "user alredy exist..${Y}skipping..${N}"
fi    
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> $log_file
validate $? "setting permissions for user in roboshop"

echo "================Script ended $(timestamp)================="| tee -a $logs_file
echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"


