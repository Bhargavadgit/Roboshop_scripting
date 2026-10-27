#!/bin/bash


user_id=$(id -u) #--getting userid

if [ $user_id -ne 0 ]; then
    echo "Please run scripts with sudo user / conatct Admin"
    exit 1
fi
