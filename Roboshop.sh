#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="bhar92s.store"
hostedzone="Z07751372GOQ7XKXVY478"


timestamp(){
    (date "+%F_%T") 
}

echo "==============[info] Script started ==========="
echo "${Timestamp}"


for instance in "$@";
do
#--- Creating instance id for to get Ip's
echo "Creating Instance :${instance}"
Instance_id=$(aws ec2 run-instances \
        --image-id $ami_id \
        --instance-type $instance_type \
        --security-groups "Roboshop-common" "Roboshop-$instance" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=Roboshop-$instance}]"\
        --query "Instances[0].InstanceId" \
        --output text
        )
done

echo "instance id =$Instance_id"

#----Verifying Instance id to produce Ip's

if [ "$instance" != "frondend" ];then
        ip=$(aws ec2 describe-instances \
         --instance-ids ${Instance_id} \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --output text)
        r53_record="${instance}.${domain_name}"
        echo "Launched instance is not Froent end with Private ip"
        echo "${instance}.${domain_name}"
        
        
else
     ip=$(aws ec2 describe-instances \
         --instance-ids ${Instance_id} \
        --query "Reservations[].Instances[].publicIpAddress" \
        --output text)
        r53_record="${domain_name}"
         echo "Launched instance is  Froent end with  public ip"
        echo "${domain_name}"
        
fi           
#--Create Domain for current Instance
echo "r53_record = ${r53_record}"
echo "domain = ${domain_name}"
aws route53 change-resource-record-sets \
    --hosted-zone-id $hostedzone \
    --change-batch "{"Changes":[{"Action":"UPSERT",
    "ResourceRecordSet": {"Name":"$r53_record",
    "Type":"A","TTL":1,
    "ResourceRecords":[{"Value":"$ip"}]}}]}"

# Create a dynamic domain name from the instance name
record_name="${instance}.${domain_name}"

echo "Creating Route 53 record: ${record_name}"

# # Create Route 53 A record
# aws route53 change-resource-record-sets \
#     --hosted-zone-id "${hostedzone}" \
#     --change-batch "{
#         \"Changes\": [{
#             \"Action\": \"UPSERT\",
#             \"ResourceRecordSet\": {
#                 \"Name\": \"${record_name}\",
#                 \"Type\": \"A\",
#                 \"TTL\": 1,
#                 \"ResourceRecords\": [{
#                     \"Value\": \"${ip}\"
#                 }]
#             }
#         }]
#     }"    


echo "${instance} Created"
echo "${Timestamp}"

echo "==============[info] Script ended ==========="



