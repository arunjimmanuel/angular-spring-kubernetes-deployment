#!/bin/bash

# 1. CONFIGURATION
AMI_ID="ami-0f9de6e2d2f067fca"
INSTANCE_TYPE="t2.micro"
KEY_NAME="aimmanuel"
SECURITY_GROUP="sg-0241f23876bd773b6"
TAG_NAME="dev-server"
REGION="us-east-1"

# 2. Create EC2 instance
echo "Launching EC2 instance..."
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --key-name "$KEY_NAME" \
  --security-group-ids "$SECURITY_GROUP" \
  --count 1 \
  --block-device-mappings 'DeviceName=/dev/sda1,Ebs={VolumeSize=30,DeleteOnTermination=true,VolumeType=gp2}' \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
  --region "$REGION" \
  --query 'Instances[0].InstanceId' \
  --output text)

echo "Instance created: $INSTANCE_ID"

# 3. Wait for instance to be running
echo "Waiting for instance to enter 'running' state..."
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"

# 4. Get the public IP
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$REGION" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "Instance is ready. Public IP: $PUBLIC_IP"

# 5. Wait for SSH to become available
echo "Waiting for SSH to be ready..."
until ssh -o StrictHostKeyChecking=no -i ~/.ssh/"$KEY_NAME".pem ubuntu@$PUBLIC_IP 'echo SSH Ready'; do
  sleep 5
done

# 6. Upload your setup-k3s.sh
echo "Uploading setup-k3s.sh..."
scp -i ~/.ssh/"$KEY_NAME".pem setup-k3s.sh ubuntu@$PUBLIC_IP:/home/ubuntu/

# 7. Run the script
echo "Running setup scripts remotely..."
ssh -i ~/.ssh/"$KEY_NAME".pem ubuntu@$PUBLIC_IP 'bash create-swap-memory.sh'
ssh -i ~/.ssh/"$KEY_NAME".pem ubuntu@$PUBLIC_IP 'bash local/setup-k3s.sh'
ssh -i ~/.ssh/"$KEY_NAME".pem ubuntu@$PUBLIC_IP 'bash git-action-runner.sh'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load the .env file from the root folder (one level up)
source "$SCRIPT_DIR/../.env"
# Update DuckDNS
curl "https://www.duckdns.org/update?domains=arunimmanuel&token=$DUCKDNS_TOKEN&ip=$PUBLIC_IP"

echo "All done!"