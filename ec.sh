#!/bin/bash

# Configuration
INSTANCE_TYPE="t2.micro"        # Change this to your desired instance type
AMI_ID="ami-04646b9f978bfbd58" # Change this to the desired AMI ID
KEY_NAME="test1"       # Change this to your key pair name
SECURITY_GROUP="launch-wizard-1" # Change this to your security group name
COUNT=2                        # Number of instances to create

# Generate a unique name for instances
TIMESTAMP=$(date +%Y%m%d%H%M%S)
NAME_PREFIX="instance"
NAME_SUFFIX=$((RANDOM % 1000))

# Loop to create instances
for ((i=1; i<=$COUNT; i++))
do
    INSTANCE_NAME="${NAME_PREFIX}-${TIMESTAMP}-${NAME_SUFFIX}-${i}"
    echo "Creating instance $INSTANCE_NAME"
    aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type $INSTANCE_TYPE \
        --key-name $KEY_NAME \
        --security-groups $SECURITY_GROUP \
        --count 1 \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCE_NAME}]"
done

echo "Instance creation complete"


