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

dnf module enable mysql:8.4 -y &>> $log_file
check_status $? "module enabled"

dnf install mysql-server -y &>> $log_file
check_status $? "installed mysql"

systemctl enable mysqld &>> $log_file
systemctl start mysqld  &>> $log_file
check_status $? "enable and starting mysql"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $log_file
check_status $? "set up rrot password"

echo "Total time ::$SECONDS"
echo "================Script ended $(timestamp)==================="