sh stop.sh

helm uninstall nginx-controller

kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cert-manager.yaml
