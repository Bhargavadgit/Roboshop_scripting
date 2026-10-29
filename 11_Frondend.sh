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


if [ "$user_id" -ne 0 ]; then
    echo "Not root user"
    exit 1
fi

mkdir -p "$logs_folder"

timestamp() {
    date "+%F %T"
}

check_status() {
    if [ "$1" -ne 0 ]; then
        echo -e "...[error]...${R}.. $2 Failed...${N} at $(timestamp)" 
        exit 1
    else
        echo -e "...[info]...${G}.. $2 success...${N} at $(timestamp)" 
    fi
}

echo "=================== Script Started at $(timestamp) ==================" | tee -a $log_file

dnf module disable nginx -y &>> $log_file
check_status $? "Disable Nginx"

dnf module enable nginx:1.26 -y &>> $log_file
check_status $? "Disable Nginx"

dnf install nginx -y &>> $log_file
check_status $? "Install Nginx"

systemctl enable nginx  &>> $log_file
check_status $? "enable Nginx"

systemctl start nginx  &>> $log_file
check_status $? "start Nginx"

rm -rf /usr/share/nginx/html/*  &>> $log_file
check_status $? "removing old files"

# Download frontend files
curl -L -o /tmp/frontend.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/frontend-v4.zip
cd /usr/share/nginx/html
unzip /tmp/frontend.zip
check_status $? "Download frontend content"

# Copy Nginx configuration BEFORE starting Nginx
sed -i "s/DOMAIN_NAME/${domain_name}/g" "$script_dir/roboshop.conf" 
cp "$script_dir/roboshop.conf" /etc/nginx/default.d/roboshop.conf
check_status $? "Prepare Nginx config"

# Validate the final configuration before starting the service
nginx -t &>> $log_file
check_status $? "Check Nginx configuration"

systemctl enable nginx &>> $log_file
check_status $? "Enable Nginx"

systemctl restart nginx &>> $log_file
check_status $? "Start Nginx"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds" | tee -a $log_file
echo "$(timestamp) [INFO] ==== Script completed execution ====" | tee -a $log_file
