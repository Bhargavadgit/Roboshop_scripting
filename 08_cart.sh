#!/bin/bash
# to see logs on screen while running use | tee -a log_file
# to send logs for running status use &> $log_file
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp
# to check user already exist or not use id
user_id=$(id -u) #get user id
logs_folder="/var/log/Roboshop_scripting"
log_file="${logs_folder}/${0}.log"
script_dir=$(dirname "$(realpath"$0")")
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

dnf module disable nodejs -y
dnf module enable nodejs:24 -y
dnf install nodejs -y
check_status $? "diable defalut and enable install Nodejs"

# adding user,befor check if any users already added or not use command id roboshop
id roboshop &>> $log_file
if [ $? -ne 0 ]; then
    echo "${G}no user exist creating user${N}"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    check_status $? -e "${G}user added...as roboshop${N}"
    else 
    echo -e "${Y} system user exist ..Skipping${N}"    
fi


# removing old data
rm -rf /app
check_status $? "removing old files"

mkdir /app
check_status $? "Download the Application"

curl -L -o /tmp/cart.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/cart-v4.zip
check_status $? "Download user"

cd /app
check_status $? "app modules..."

unzip /tmp/cart.zip
check_status $? "unzip modules..."

# changes in cart.service file
sed -i "s/DOMAIN_NAME/$domaindomain_name/g" "$script_dir/cart.service"
cp "$script_dir/cart.service" /etc/systemd/system/cart.service
check_status $? "copy service file..."

systemctl daemon-reload
check_status $? "daemon-reload..cart."

systemctl enable cart
check_status $? "enable..cart."

systemctl start cart
check_status $? "start..cart."

systemctl restart cart
check_status $? "restart..cart."
echo "===================Script ended at $(timestamp)==================" | tee -a log_file