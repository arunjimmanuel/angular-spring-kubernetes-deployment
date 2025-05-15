# AWS Automation Scripts

This directory contains shell scripts for managing EC2 instances and provisioning infrastructure for deploying the Angular + Spring Boot application via Kubernetes (K3s).

## 📄 Scripts

- `create-instance.sh` – Launches an Ubuntu EC2 instance with required ports and security groups.
- `create-swap-memory.sh` – Adds swap memory for better resource handling on t2.micro.
- `git-action-runner.sh` – Installs and registers a GitHub Actions self-hosted runner.
- `terminate-instance.sh` – Safely terminates EC2 instance and removes associated resources.

## ⚙️ Requirements

- AWS CLI installed and configured
- EC2 key pair with SSH access
- IAM user with EC2 full access

## 1. 🔧 Configuration

Before running any scripts, update the configuration variables in each script to match your setup:

```bash
AMI_ID="ami-0f9de6e2d2f067fca"
INSTANCE_TYPE="t2.micro"
KEY_NAME="your-key-name"
SECURITY_GROUP="sg-xxxxxxxxxxxxxxxxx"
TAG_NAME="dev-server"
REGION="us-east-1"
```

> 📁 Also ensure that your `~/.ssh` directory contains the private key: `~/.ssh/KEY_NAME.pem`

## 🔐 Environment Variables (.env required)

Create a `.env` file in the root of this repository with the following:

```env
DUCKDNS_TOKEN=your-duckdns-token
SOLR_ADMIN_USER=your-solr-username
SOLR_ADMIN_PASS=your-solr-password
```

These are used for dynamic DNS provisioning and Solr admin setup inside Kubernetes.

## 🚀 Usage

Launch a new EC2 instance:
```bash
./create-instance.sh
```

Add swap memory:
```bash
./create-swap-memory.sh
```

Set up a GitHub Actions runner:
```bash
./git-action-runner.sh
```

Terminate the instance:
```bash
./terminate-instance.sh
```

---
Feel free to adapt these scripts to suit other cloud environments or deployment workflows.
