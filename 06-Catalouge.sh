#!/bin/bash
# to see logs on screen while running use | tee -a log_file
# to send logs for running status use &> $log_file
# varable should be in{flower bracess} example check logs_folders
# function should be in closed bracess check timestamp
# to check user already exist or not use id
user_id=$(id -u) #get user id
logs_folder="/var/log/Roboshop_scripting"
log_file="${logs_folder}/${0}.log"
script_dir=$(dirname "$(realpath"0")")
domain_name="bhar92s.store"
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
id roboshop &>> $log_file
if [ $1 -ne 0 ]; then
    echo "$2 ${G}no user exist creating user${N}"
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $log_file
    check_status $? -e "${G}user added...as rpboshop${N}"
    else 
    echo -e "$2 ${Y} system user exist ..Skipping${N}"    
fi
# creating app remove if exist
rm -rf /app
check_status $? "delete existing app directory"

mkdir -p /app &>> $log_file
check_status $? "created app directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip

cd /app
unzip /tmp/catalogue.zip
check_status $? "unzip cataouge"

npm install
check_status $? "installing libreries"

# need to copy catalouge.service
# beacuse we are doing Automation we can't do manuval changes in repos 
#getting script name use 
#step-1 realpath $<script name>
#step-2 copy path & do command dirname <step1 result>
#we use $(dirname$"(realpath"$0")") ---gives path to directory

sed -i "s/DOMAIN_NAME/$domain_name" "$script_dir/catalogue.service"
cp "$script_dir/catalogue.service" /etc/systemd/system/catalogue.service
check_status $? "copied catalogue.service"

systemctl daemon-reload
check_status $? "demon reload catalogue.service"
systemctl enable catalogue
check_status $? "enable catalogue.service"
systemctl start catalogue
check_status $? "Start catalogue"

cp "$script_dir/mongo.repo" /etc/yum.repos.d/mongo.repo
check_status $? "copied mongorepo.service"

dnf install mongodb-mongosh -y &>> $log_file
check_status $? "Installed mongosh.service"

#to check products exist
product_count=$(mongosh --host mongodb.$domain_name --quiet --eval 'db.getSiblingDB("catalogue").products.countDocuments()')
check_status $? "products loaded"

if [ $product_count -ne 0 ]; then
    echo "Products loaded already"
    else 
    mongosh --host mongodb.$domain_name </app/db/master-data.js
    check_status $? "products loaded"
fi
systemctl restart mongodb
check_status $? "restarting..."

echo "Total time ::$SECONDS"
echo "===================Script ended at $(timestamp)=================="