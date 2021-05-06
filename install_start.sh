# Install the ingress load balancer up front
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-controller ingress-nginx/ingress-nginx


# Install the certificate manager
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml

# Waiting for installation complete
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

helm install influenzanet-2.0 ./influenzanet-2.0