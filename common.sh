#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"


# we are creating instance through loop it will give result instance id
for instance in $@
do 
Instance_id=$(
        aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type $instance_type \
        --security-groups "Roboshop-common" "Roboshop-$instance" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-$instance}]"\
        --query "Instances[0].InstanceId" \
        --output text
                 )
done
#--by usingthese we can get Ip's
if [$Instance_id != "Front end "]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids i-0123456789abcdef0 \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --output text)
        echo "Printed private :$IP"
else    
        IP=$(aws ec2 describe-instances \
        --instance-ids i-0123456789abcdef0 \
        --query "Reservations[].Instances[].PublicIpAddress" \
        --output text)
        echo "Printed public :$IP"
fi        

