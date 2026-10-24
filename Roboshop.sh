#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain="bhar92s.store"
hostedzone=Z07751372GOQ7XKXVY478

timestamp(){
   echo "time at :$(date +"%F_%T")"
}
echo "=============[info]Script Start time $timestamp ==============="

for instance in $@
do

echo "Creating Instance :${instance}"
Instance_id=$(aws ec2 run-instances \
    --image-id $ami_id \
    --instance-type $instance_type \
    --security-groups "Roboshop-shell" "roboshop-$instance" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-$instance}]"\
    --query 'instances[0].instances'\
    --output text
    )
done
 echo "Instance id = ${Instance_id}"
echo "=============[info]Script end time $timestamp =================="