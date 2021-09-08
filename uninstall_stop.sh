sh stop.sh

helm uninstall nginx-controller

kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml
