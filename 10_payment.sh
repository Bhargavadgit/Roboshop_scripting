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

dnf install python3.14 python3.14-pip -y
check_status $? "Installed Python"

# adding user,befor check if any users already added or not use command id roboshop
id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    echo "${G}no user exist creating user${N}"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    check_status $? -e "${G}user added...as roboshop${N}"
    else 
    echo -e "${Y} system user exist ..Skipping${N}"    
fi

#remove old files
rm -rf /app
check_status $? "remove old files app directory"  &>> $log_file

mkdir /app
check_status $? "Creating app directory"  &>> $log_file

curl -L -o /tmp/payment.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/payment-v4.zip
check_status $? "Downloading payment"

cd /app
unzip /tmp/payment.zip  &>> $log_file
check_status $? "unzip payment"  

cd /app
python3.14 -m venv /app/.venv &>> $log_file
check_status $? "Creating virtual environment"  

/app/.venv/bin/pip install -r requirements.txt &>> $log_file
check_status $? "Installing dependencies"  

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/payment.service"
cp "$scripts_dir/payment.service" /etc/systemd/system/payment.service

systemctl daemon-reload &>> $log_file
check_status $? "daemon-reload payment"

systemctl enable payment &>> $log_file
check_status $? "enable payment"

systemctl restart payment &>> $log_file
check_status $? "Starting/Restaring payment"

echo "===================Script ended at $(timestamp)==================" | tee -a log_file
