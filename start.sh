kubectl create -f namespace.yaml

# openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout tls.key -out tls.crt -subj "/CN=nginxsvc/O=nginxsvc"

# kubectl create secret tls cert_case --key tls.key --cert tls.crt 
#kubectl create secret docker-registry regcred --docker-server=https://index.docker.io/v1/ --docker-username=username --docker-password=password --docker-email=email


# kubectl create secret generic regcred \
#    --from-file=.dockerconfigjson=config.json \
#    --type=kubernetes.io/dockerconfigjson
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-controller ingress-nginx/ingress-nginx


# kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.42.0/deploy/static/provider/cloud/deploy.yaml


kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# kubectl apply --validate=true -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml

kubectl apply -f secrets/cert_issuer.yaml

# kubectl get pods --namespace cert-manager

kubectl create -f secrets/secrets.yaml

# sudo mkdir /mnt/data

# sudo sh -c "echo 'Hello from Kubernetes storage' > /mnt/data/index.html"

# Deploying MongoDB instance
# kubectl create -f storageclass/persistant_volume.yaml
kubectl create -f storageclass/persistant_claim.yaml
kubectl create -f deployments/mongo-deployment.yaml 
kubectl create -f services/mongo-service.yaml

# Deploying Logging Service
kubectl create -f deployments/logging-deployment.yaml 
kubectl create -f services/logging-service.yaml

# Deploying Study Service
kubectl create -f deployments/study-deployment.yaml 
kubectl create -f services/study-service.yaml


# Deploying User Management Service
kubectl create -f deployments/user-management-deployment.yaml 
kubectl create -f services/user-management-service.yaml


# Deploying API Gateway
kubectl create -f deployments/participant-api-deployment.yaml 
kubectl create -f deployments/management-api-deployment.yaml 
kubectl create -f services/management-api-service.yaml
kubectl create -f services/participant-api-service.yaml


# Deploying Messaging Service
kubectl create -f configmaps/email-config.yaml
kubectl create -f deployments/email-client-deployment.yaml
kubectl create -f deployments/messaging-service-deployment.yaml
kubectl create -f deployments/messaging-scheduler-deployment.yaml
kubectl create -f services/email-client-service.yaml
kubectl create -f services/messaging-service.yaml
kubectl create -f services/messaging-scheduler-service.yaml

# Deploying Web Client Service
kubectl create -f configmaps/web-env-config.yaml 
kubectl apply -f deployments/web-client-deployment.yaml 
kubectl create -f services/web-client-service.yaml

# Deploying ingress services
kubectl create -f ingress/case-ingress.yaml
kubectl create -f ingress/case-ingress-web.yaml
