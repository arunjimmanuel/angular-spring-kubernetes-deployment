# ⚡ Minimal Kubernetes Setup using K3s on AWS EC2 (Ubuntu 22.04, t3.micro)

This guide provides a step-by-step setup of a lightweight Kubernetes cluster using [K3s](https://k3s.io/) on an **AWS EC2 `t3.micro` instance running Ubuntu 22.04**.

It is optimized for minimal memory usage, dynamic volume provisioning, and integration with **GitHub Actions** using `kubectl` and `Helm`.

---

## 🚀 Requirements

- AWS EC2 instance (`t3.micro` or similar)
- Ubuntu 22.04 LTS (64-bit)
- Access via SSH with `sudo` privileges
- Ports 6443 (Kubernetes API), 80 (HTTP), and optionally 443 (HTTPS) open in your Security Group

---

## ✅ Installation Steps

### 1. Update Ubuntu Packages

```bash
sudo apt update && sudo apt upgrade -y
```

---

### 2. Install K3s (Minimal Setup)

Disable unnecessary components for low-memory environments:

```bash
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--disable traefik --disable metrics-server --disable local-storage --disable servicelb" sh -
```

---

### 3. Configure kubectl for Your User

```bash
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
```

---

### 4. Export KUBECONFIG in Shell (Optional)

```bash
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc
source ~/.bashrc
```

---

### 5. Verify the K3s Node is Running

```bash
kubectl get nodes
```

---

### 6. Install Helm (Client Only)

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

---

### 7. Get Base64-Encoded Kubeconfig (for GitHub Actions)

To use your cluster in GitHub Actions (as a secret):

```bash
base64 -w 0 ~/.kube/config
```

> 💡 On macOS use:
> ```bash
> base64 ~/.kube/config | tr -d '\n'
> ```

Use this string as your `KUBECONFIG_B64` GitHub secret.

---

### 8. Install the Local Path Provisioner (for PVC Support)

K3s disables the default provisioner when you use `--disable local-storage`, so re-enable it manually:

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
```

---

### 9. Set `local-path` as the Default Storage Class

```bash
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

---

## 📦 What You Now Have

- A minimal, single-node Kubernetes cluster via K3s
- Helm v3 installed for managing charts
- PersistentVolumeClaim (PVC) support via `local-path` provisioner
- GitHub Actions ready (`kubectl` configured via base64 secret)

---

## ✅ Recommended Add-ons

- **Ingress-NGINX Controller (with hostPort):**
  - Use Helm with `hostPort.enabled=true` if port 80 is open
- **MongoDB, Spring Boot, Angular apps**: You can deploy these as separate Kubernetes resources

---

## 🧹 Optional Cleanup

To uninstall K3s:

```bash
sudo /usr/local/bin/k3s-uninstall.sh
```

---

## 📝 Author Notes

This setup is actively used in production-like development environments with GitHub Actions CI/CD pipelines and resource-constrained nodes.

---

## 📎 References

- [K3s Docs](https://docs.k3s.io/)
- [Helm](https://helm.sh/)
- [Local Path Provisioner](https://github.com/rancher/local-path-provisioner)