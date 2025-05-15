# Angular + Spring Boot Deployment on Kubernetes (AWS EC2 with K3s)

![Kubernetes](https://img.shields.io/badge/Kubernetes-K3s-blue) ![AWS](https://img.shields.io/badge/AWS-EC2-orange) ![Docker](https://img.shields.io/badge/Docker-Containerization-blue) ![CI/CD](https://img.shields.io/badge/CI/CD-GitHub%20Actions-green)

## 🔍 Overview

This repository provides a complete deployment setup for a full-stack application—**Angular frontend** + **Spring Boot backend**—using **K3s Kubernetes** on an **AWS EC2 Ubuntu server**. The setup includes:

- Lightweight Kubernetes (K3s)
- Secure, JWT-based communication
- Docker containerization
- GitHub Actions CI/CD pipeline

## 🧰 Tech Stack

- **Frontend**: Angular 17
- **Backend**: Spring Boot 3
- **Containers**: Docker
- **Orchestration**: Kubernetes (K3s)
- **Ingress**: NGINX
- **CI/CD**: GitHub Actions (`.github/workflows/deploy.yaml`)
- **Platform**: AWS EC2 (Ubuntu 22.04)
- **Package Manager**: Helm

## 📁 Repository Structure

```
angular-spring-kubernetes-deployment/
├── .github/
│   └── workflows/
│       └── deploy.yaml
├── aws/
│   ├── create-instance.sh
│   ├── create-swap-memory.sh
│   ├── git-action-runner.sh
│   ├── terminate-instance.sh
│   └── README.md
├── k8s/
│   ├── angular/
│   │   └── base/
│   │       ├── angular-deployment.yaml
│   │       └── angular-service.yaml
│   ├── ingress/
│   │   ├── base/
│   │   │   └── ingress.yaml
│   │   └── overlays/
│   │       ├── kustomization.yaml
│   │       └── path-ingress-host.yaml
│   ├── mongo/
│   │   ├── mongo-deployment.yaml
│   │   ├── mongo-service.yaml
│   │   └── mongo-pvc.yaml
│   ├── solr/
│   │   ├── schema.json
│   │   ├── solr-deployment.yaml
│   │   ├── solr-service.yaml
│   │   └── solr-pvc.yaml
│   └── spring/
│       ├── spring-deployment.yaml
│       └── spring-service.yaml
├── local/
│   ├── deploy.sh
│   ├── setup-k3.sh
│   └── README.md
└── README.md


```

## 🚀 Deployment Guide

### 1. 🚀 Launch AWS EC2 Instance

- **Type**: `t2.micro`
- **AMI**: Ubuntu 22.04 LTS
- **Ports**: 22 (SSH), 80 (HTTP), 443 (HTTPS)

### 2. ⚙️ Install K3s

SSH into the EC2 instance and run:
```bash
curl -sfL https://get.k3s.io | sh -
```

### 3. 🛠️ Configure kubectl
```bash
mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

### 4. 🧱 Apply Kubernetes Manifests
Choose environment (`dev` or `prod`) and apply:
```bash
kubectl apply -f k8s/dev/namespace.yaml
kubectl apply -f k8s/dev/backend-deployment.yaml
kubectl apply -f k8s/dev/frontend-deployment.yaml
kubectl apply -f k8s/dev/ingress.yaml
```

### 5. 🌐 Set Up Ingress Controller
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx
```

After installation, check the LoadBalancer IP and use it to access your app.

### 6. 🔗 Access the Application
Use the EC2 public IP or domain name to view your deployed application.

## ⚙️ GitHub Actions CI/CD

Automated CI/CD workflow is available at:
```
.github/workflows/deploy.yaml
```

**Workflow Highlights:**
- Trigger on push to `main`
- Build and push Docker images
- Apply K8s manifests using kubeconfig

> 💡 GitHub Secrets required:
> - `DOCKER_USERNAME`
> - `DOCKER_PASSWORD`
> - `KUBECONFIG_B64` (base64 encoded kubeconfig file)

## 🔐 Security
- JWT used for secure API communication
- Kubernetes Secrets for sensitive configs
- TLS via Ingress NGINX (can be extended with cert-manager)

## 📊 Monitoring & Logging

Optionally integrate:
- **Prometheus + Grafana** for monitoring
- **ELK stack** for logging (Elasticsearch, Logstash, Kibana)

## 🔎 SEO Tags
`Spring Boot Kubernetes`, `Angular Docker K8s`, `CI/CD GitHub Actions Kubernetes`, `K3s EC2 Deployment`, `Full Stack Cloud Native Java App`, `Helm Deployment`, `Ingress Controller`, `Kubernetes NGINX`, `Lightweight Kubernetes`, `Microservice Deployment AWS`

## 👤 Author
**Arun Jaya Immanuel**  
🔗 [LinkedIn](https://www.linkedin.com/in/arunimmanuel/)  
💼 Backend Developer | Spring Boot | Kubernetes | Cloud-Native Solutions

---
Feel free to fork or star ⭐ this project if it helps you!
