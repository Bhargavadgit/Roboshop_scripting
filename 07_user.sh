#!/bin/bash
# to see logs on screen while running use | tee -a log_file
# to send logs for running status use &> $log_file
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp
# to check user already exist or not use id
user_id=$(id -u) #get user id
logs_folder="/var/log/Roboshop_scripting"
log_file="${logs_folder}/${0}.log"
script_dir=$(dirname "$(realpath "$0")")
domain_name="bhar92s.store"
R="\e[31m" #red
G="\e[32m" #Green
Y="\e[33m" #yellow
N="\e[0m"  #normal

if [ $user_id -ne 0 ];then
 echo "not root user "
 exit 1
 else 
 echo "Processing..."
fi

mkdir -p $logs_folder

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

echo "===================Script Started at $(timestamp)==================" | tee -a log_file

dnf module disable nodejs -y  &>> $log_file
check_status $? "Diabled default verson"

dnf module enable nodejs:24 -y   &>> $log_file
check_status $? "enable node js 24"

dnf install nodejs -y   &>> $log_file
check_status $? "installed nodejs"

# adding user befor check if any users already added or not use command id roboshop
id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    echo -e "${G}no user exist creating user${N}"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    check_status $? -e "${G}user added...as roboshop${N}"
    else 
    echo -e "${Y} system user exist ..Skipping${N}"    
fi
rm -rf /app #deleteing existing App data
check_status $?  "removeing old files of roboshop"

mkdir /app # creating app directory

check_status $? "Creating app directory"

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip
check_status $? "Downloading user"

cd /app

unzip /tmp/user.zip  &>> $log_file
check_status $? "unzip modules..."

npm install
check_status $? "Install Dependencies..."

# coping data from user.service
# get realpath ----realpath $<filename>
#get dir path -----dirname $(realpath"0")
# get script dir ---$(dirname"$(realpath"$0")")

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/user.service"
cp "$script_dir/user.service" /etc/systemd/system/user.service
check_status $? "copied user.service file..." | tee -a log_file

systemctl daemon-reload
check_status $? "daemon-reload user..."

systemctl enable user
check_status $? "enable user..."

systemctl start user
check_status $? "start user..."

systemctl restart user
check_status $? "restart user..."

echo "Total time ::$SECONDS"
echo "===================Script ebded at $(timestamp)==================" | tee -a log_file