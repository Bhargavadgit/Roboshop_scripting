#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain="bhar92s.store"
hostedzone="Z07751372GOQ7XKXVY478"

Timestamp(){

        (date+"%f_%T")
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

if [ $instance != "frondend" ];then
        ip=$(aws ec2 describe-instances \
         --instance-ids ${Instance_id} \
        --query "Reservations[*].Instances[*].PrivateIpAddress" \
        --output text)
        r53_record="${Instance}.${domain}"
        echo "Launched instance is not Froent end Private ip"
        echo "${instance}.${domain}"
        
else
     ip=$(aws ec2 describe-instances \
         --instance-ids ${Instance_id} \
        --query "Reservations[*].Instances[*].publicIpAddress" \
        --output text)
        r53_record="${domain}"
         echo "Launched instance is  Froent end  public ip"
        echo "${domain}"
        
fi           
#--Create Domain for current Instance

aws route53 change-resource-record-sets \
    --hosted-zone-id ${hostedzone} \
        --change-batch '
        {"Changes":[
                {"Action":"UPSERT"\
                   "ResourceRecordSet":${r53_record}"\
                   "Type":"A"\
                   "TTL":1\
                "ResourceRecords":[{"Value":"$ip"}]
                                        }
                }
                   ]
        }'


echo "${instance} Created"
echo "${Timestamp}"

echo "==============[info] Script ended ==========="



