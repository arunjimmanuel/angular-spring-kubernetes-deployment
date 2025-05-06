#!/bin/bash

# Configuration
REGION="us-east-1"
NAME_TAG="dev-server"

echo "🔍 Searching for EC2 instances with Name tag: $NAME_TAG..."

# Get all instance IDs with the tag (any state except terminated)
INSTANCE_IDS=$(aws ec2 describe-instances \
  --region "$REGION" \
  --filters "Name=tag:Name,Values=$NAME_TAG" "Name=instance-state-name,Values=pending,stopping,stopped,running" \
  --query "Reservations[].Instances[].InstanceId" \
  --output text)

# Check if any instance found
if [ -z "$INSTANCE_IDS" ]; then
  echo "✅ No matching instances to terminate."
  exit 0
fi

echo "⚠️ Found instance(s): $INSTANCE_IDS"
echo "🧨 Terminating instance(s)..."

# Terminate the instance(s)
aws ec2 terminate-instances \
  --region "$REGION" \
  --instance-ids $INSTANCE_IDS

# Wait for termination to complete
echo "⏳ Waiting for instance(s) to be terminated..."
aws ec2 wait instance-terminated \
  --region "$REGION" \
  --instance-ids $INSTANCE_IDS

echo "✅ Terminated successfully: $INSTANCE_IDS"
