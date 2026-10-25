#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"


# we are creating instance through loop
for instance in $@
do 
aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type $instance_type \
        --security-groups "Roboshop-common" "Roboshop-$instance" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-$instance}]"\
        --query "Instances[0].InstanceId" \
        --output text
done
