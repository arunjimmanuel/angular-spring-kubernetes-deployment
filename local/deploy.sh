#!/bin/bash

set -e

echo ">>> Waiting for Kubernetes API to be ready..."
for i in {1..30}; do
  if kubectl get nodes > /dev/null 2>&1; then
    echo "Kubernetes is ready."
    break
  fi
  echo "Waiting ($i)..."
  sleep 5
done

echo ">>> Ensuring Ingress-NGINX is installed..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo update

kubectl create namespace ingress-nginx || true

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.kind=DaemonSet \
  --set controller.daemonset.useHostPort=true \
  --set controller.hostPort.enabled=true \
  --set controller.service.type=ClusterIP \
  --set controller.containerPort.http=80 \
  --set controller.containerPort.https=443 \
  --set controller.admissionWebhooks.enabled=false

echo ">>> Waiting for ingress-nginx-controller DaemonSet to be ready..."
kubectl rollout status daemonset ingress-nginx-controller -n ingress-nginx --timeout=90s

echo ">>> Patching ingress-nginx-controller to set CPU/memory limits..."
kubectl -n ingress-nginx patch daemonset ingress-nginx-controller \
  --type='json' \
  -p='[
    {
      "op": "add",
      "path": "/spec/template/spec/containers/0/resources",
      "value": {
        "requests": {
          "cpu": "50m",
          "memory": "64Mi"
        },
        "limits": {
          "cpu": "150m",
          "memory": "128Mi"
        }
      }
    }
  ]'
# Get the directory where the script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
K8S_DIR="$SCRIPT_DIR/../k8s"
echo ">>> Applying MongoDB Kubernetes resources..."
kubectl apply --request-timeout=60s -f $K8S_DIR/mongo/base/mongo-pvc.yaml
kubectl apply --request-timeout=60s -f $K8S_DIR/mongo/base/mongo-deployment.yaml  
kubectl apply --request-timeout=60s -f $K8S_DIR/mongo/base/mongo-service.yaml

echo ">>> Applying Solr Kubernetes resources..."
kubectl create secret generic solr-auth-secret \
  --from-env-file=<(grep '^SOLR_' ../.env) \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply --request-timeout=60s -f $K8S_DIR/solr/base/solr-pvc.yaml
kubectl create configmap solr-schema-configmap --from-file=$K8S_DIR/solr/base/schema.json -o yaml --dry-run=client | kubectl apply -f -
kubectl apply --request-timeout=60s -f $K8S_DIR/solr/base/solr-deployment.yaml  
kubectl apply --request-timeout=60s -f $K8S_DIR/solr/base/solr-service.yaml

echo ">>> Waiting for ingress-nginx-controller DaemonSet to be ready (again)..."
kubectl rollout status daemonset ingress-nginx-controller -n ingress-nginx --timeout=90s

echo ">>> Applying Angular deployment and service..."
kubectl apply --request-timeout=60s -f $K8S_DIR/angular/base/angular-deployment.yaml
kubectl apply --request-timeout=60s -f $K8S_DIR/angular/base/angular-service.yaml
kubectl apply --request-timeout=300s -f $K8S_DIR/ingress/base/ingress.yaml --validate=false

echo ">>> Waiting for Solr deployment to be ready..."
kubectl rollout status deployment/solr --namespace=default --timeout=90s

echo ">>> Applying Spring Boot app deployment and service..."
kubectl apply --request-timeout=60s -f $K8S_DIR/spring/base/spring-deployment.yaml
kubectl apply --request-timeout=60s -f $K8S_DIR/spring/base/spring-service.yaml

echo ">>> Cleaning up unused containerd images..."
sudo ctr images prune --all

echo "Deployment complete."