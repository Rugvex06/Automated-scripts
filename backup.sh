#!/bin/bash



# Configuration
AWS_REGION="us-east-1"               # Change this to your desired AWS region
S3_BUCKET="backup20232003"           # Change this to your S3 bucket name

# Retrieve a list of running EC2 instances
INSTANCE_LIST=$(aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" --region $AWS_REGION --query "Reservations[].Instances[].InstanceId" --output text)

# Iterate through each EC2 instance
for INSTANCE_ID in $INSTANCE_LIST
do
    echo "Processing instance: $INSTANCE_ID"

    # Create a snapshot of the EC2 instance's EBS volumes
    VOLUME_LIST=$(aws ec2 describe-volumes --filters "Name=attachment.instance-id,Values=$INSTANCE_ID" --region $AWS_REGION --query "Volumes[].VolumeId" --output text)

    for VOLUME_ID in $VOLUME_LIST
    do
        echo "Creating snapshot for volume: $VOLUME_ID"
        SNAPSHOT_ID=$(aws ec2 create-snapshot --volume-id $VOLUME_ID --region $AWS_REGION --query "SnapshotId" --output text)

        echo "Snapshot created: $SNAPSHOT_ID"

        # Upload the created snapshot ID to the S3 bucket
        if [ -n "$S3_BUCKET" ]; then
            echo "Uploading snapshot ID to S3 bucket: $S3_BUCKET"
            echo $SNAPSHOT_ID > /tmp/snapshot.txt
            aws s3 cp --region $AWS_REGION /tmp/snapshot.txt s3://$S3_BUCKET/$SNAPSHOT_ID.txt
        fi
    done
done

echo "Backup process completed"


