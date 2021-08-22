kubectl delete --all services,deploy,pods --namespace case

helm uninstall influenzanet-2.0 ./influenzanet-2.0

helm uninstall nginx-controller

kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.1.0/cert-manager.yaml
