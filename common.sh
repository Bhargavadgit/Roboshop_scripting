#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="bhar92s.store"



echo "===============[info] Script Started ========="
echo "Start time ::$timestamp"
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
if [ "$Instance_id" != "Frontend" ]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids i-0123456789abcdef0 \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --output text)
        r53_record=${instance}.${domain_name}
        echo "Printed private :$IP"
else    
        IP=$(aws ec2 describe-instances \
        --instance-ids i-0123456789abcdef0 \
        --query "Reservations[].Instances[].PublicIpAddress" \
        --output text)
        r53_record=${domain_name}
        echo "Printed public :$IP"
fi        




echo "Start time ::$timestamp"
echo "total time ::$SECONDS"
echo "===============[info] Script end ========="