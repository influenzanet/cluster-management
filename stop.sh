kubectl delete deployment mongo logging study user-management participant-api management-api web-client --namespace=case
kubectl delete pvc task-pv-claim --namespace=case
kubectl delete pv task-pv-volume --namespace=case
kubectl delete service mongo-atlas-service logging-service web-client-service study-service user-management-service management-api-service participant-api-service --namespace=case
kubectl delete secrets jwt-collection case-mongodb-atlas --namespace=case
kubectl delete secrets cert_case regcred
kubectl delete configmaps web-env-config --namespace=case
kubectl delete ingress case-ingress case-ingress-web --namespace=case