# Local Kubernetes Deployment (K3s)

This folder contains scripts to help you spin up a lightweight Kubernetes (K3s) cluster on your local Ubuntu machine and deploy the Angular + Spring Boot application stack.

## 📄 Scripts

- `setup-k3.sh` – Installs K3s and configures `kubectl`
- `deploy.sh` – Applies Kubernetes manifests for frontend, backend, MongoDB, Solr, and ingress

## ⚙️ Requirements

- Ubuntu 22.04 or similar Linux distro
- curl
- kubectl
- Helm (optional but recommended)
- Docker (for building images locally if needed)

## 🔐 Environment Variables (.env required)

Make sure the following values are available in a `.env` file:

```env
DUCKDNS_TOKEN=your-duckdns-token
SOLR_ADMIN_USER=your-solr-username
SOLR_ADMIN_PASS=your-solr-password
```

These values are consumed during Solr setup and DuckDNS-based dynamic DNS configuration.

## 🚀 Usage

Install K3s:
```bash
./setup-k3.sh
```

Deploy the stack:
```bash
./deploy.sh
```

Verify:
```bash
kubectl get pods -A
kubectl get svc -A
```

## ✅ Notes

- These scripts assume a non-root user with sudo privileges.
- External access to services is configured via Ingress.
- Swap memory setup is handled in the [`aws/`](../aws) directory for EC2-based environments.
