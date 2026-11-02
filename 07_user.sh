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
     echo -e "...[error]....${R} $2.. Failed...${N}...at $(timestamp)"
     exit 1
    else
     echo -e "..[info]...${G} $2.. success...${N}... at $(timestamp)"
    fi
}

echo "===================Script Started at $(timestamp)==================" | tee -a $log_file

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
    check_status $? -e "user added...as roboshop"
    else 
    echo -e "${Y} system user exist ..Skipping${N}"    
fi
rm -rf /app &>> $log_file #deleteing existing App data
check_status $?  "removeing old files of roboshop"

mkdir /app &>> $log_file # creating app directory
check_status $? "Creating app directory"

curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip
check_status $? "Downloading user"

cd /app  &>> $log_file
unzip /tmp/user.zip  &>> $log_file
check_status $? "unzip modules..."

npm install  &>> $log_file
check_status $? "Install Dependencies..."

# # coping data from user.service
# # get realpath ----realpath $<filename>
# #get dir path -----dirname $(realpath"0")
# # get script dir ---$(dirname"$(realpath"$0")")

sed -i "s/DOMAIN_NAME/$domain_name/g" "$script_dir/user.service" &>> $log_file
check_status $? "replacing domain name in user.service file..." 
cp "$script_dir/user.service" /etc/systemd/system/user.service  | tee -a $log_file
check_status $? "copied user.service file..." 

systemctl daemon-reload  &>> $log_file
check_status $? "daemon-reload user..."

systemctl enable user  &>> $log_file
check_status $? "enable user..."

systemctl start user  &>> $log_file
check_status $? "start user..."

systemctl restart user  &>> $log_file
check_status $? "restart user..."


echo "Total time ::$SECONDS"
echo "===================Script ebded at $(timestamp)==================" | tee -a $log_file


# #!/bin/bash

# user_id=$(id -u)
# logs_folder="/var/log/roboshop"
# logs_file="${logs_folder}/${0}.log"
# domain_name="daws92s.store"
# scripts_dir=$(dirname "$(realpath "$0")")
# R="\e[31m"
# G="\e[32m"
# Y="\e[33m"
# N="\e[0m"

# if [ $user_id -ne 0 ]; then
#     echo "Please run this script with sudo access.."
#     exit 1
# fi

# mkdir -p $logs_folder

# timestamp(){
#     date "+%F %T" 
# }

# validate(){
#     if [ $1 -ne 0 ]; then
#         echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
#         exit 1
#     else
#         echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
#     fi
# }

# echo "$(timestamp) [INFO] ==== Script started Execution =====" | tee -a $logs_file

# dnf module disable nodejs -y &>> $logs_file
# dnf module enable nodejs:24 -y &>> $logs_file
# dnf install nodejs -y &>> $logs_file
# validate $? "Installing nodejs 24"

# id roboshop &>> $logs_file
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
#     validate $? "Creating system user"
# else
#     echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
# fi

# rm -rf /app
# validate $? "Removing old code"

# mkdir -p /app
# validate $? "Creating app directory"

# curl -L -o /tmp/user.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/user-v4.zip &>> $logs_file
# validate $? "Downloading user"

# cd /app
# unzip /tmp/user.zip &>> $logs_file
# validate $? "Unzipping user"

# npm install &>> $logs_file
# validate $? "Installing dependencies"

# sed -i "s/DOMAIN_NAME/$domain_name/g" "$scripts_dir/user.service"
# cp "$scripts_dir/user.service" /etc/systemd/system/user.service

# systemctl daemon-reload &>> $logs_file
# systemctl enable user &>> $logs_file
# systemctl start user &>> $logs_file
# validate $? "Starting and enabling user"

# systemctl restart user
# validate $? "Restarting user"

# echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
# echo "$(timestamp) [INFO] ==== Script completed Execution =====" | tee -a $logs_file