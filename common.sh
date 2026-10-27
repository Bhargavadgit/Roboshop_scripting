#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="bhar92s.store"
hosted_zone="Z07751372GOQ7XKXVY478"


timestamp(){
    (date "+%F %T")
}
     
echo "===============[info] Script Started ========="
echo "Start time ::$(timestamp)"
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
        --instance-ids "$Instance_id" \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --output text)
        r53_record=${instance}.${domain_name}
        echo "Printed private :$IP"
        echo "R53=$r53_record"
else    
        IP=$(aws ec2 describe-instances \
        --instance-ids "$Instance_id" \
        --query "Reservations[].Instances[].PublicIpAddress" \
        --output text)
        r53_record=${domain_name}
        echo "Printed public :$IP"
        echo "R53=${r53_record}"
fi        

#---updating r53 record
# aws route53 change-resource-record-sets \
# --hosted-zone-id "${hosted_zone}",
# --change-batch '{"Changes":[{"Action":"UPSERT",
# "ResourceRecordSet":{"Name":"'$r53_record'",
# "Type":"A","TTL":1,
# "ResourceRecords":[{"Value":"'$ip'"}]}}]}'


echo "end time ::$(timestamp)"
echo "total time ::$SECONDS"
echo "===============[info] Script end ========="




