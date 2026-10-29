#!/bin/bash
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp
user_id=$(id -u) #--getting userid
logs_folder="/var/log/roboshop_scripting"
log_file="${logs_folder}/${0}.log"
#-- add clours to messages
R="\e[31m" # Red
G="\e[32m" # Green
Y="\e[33m" # Yellow
N="\e[0m" # No Color

mkdir -p $logs_folder


if [ $user_id -ne 0 ]; then
    echo "Please run scripts with sudo user / conatct Admin"
    exit 1
fi

timestamp(){
    (date "+%F %T")
    #  date "+%F %T"
}

check_status(){
    if [ $1 -eq 0 ]; then  
        echo -e "${G}...[info].. success....${N}....$(timestamp)"  
    else
       echo -e "${R}..[error]...$2 Failed....${N}....$(timestamp)"  
        exit 1
    fi
}
echo "==============Script start $(timestamp)============"

dnf module disable redis -y &>> $log_file
check_status $? "Diable Redis defalut"
dnf module enable redis:7 -y  &>> $log_file
check_status $? "enable Redis 7"
dnf install redis -y  &>> $log_file
check_status $? "Installing Redis 7"

# sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf
sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf

systemctl enable redis  &>> $log_file
check_status $? "enable Redis"
systemctl start redis  &>> $log_file
check_status $? "Start Redis"

systemctl restart redis  &>> $log_file
check_status $? "reStart Redis"

systemctl status redis  &>> $log_file
check_status $? "reStart status is active"

echo "total time :$SECONDS"
echo "$(timestamp)" # function should be in closed bracess
echo "==============Script end at $(timestamp) ============"
echo "$(timestamp) ==== [INFO]  Script completed Execution =====" | tee -a $logs_file



