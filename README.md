 
# Running a kubernetes deployment - CASE

This guide will walk you through creating a Kubernetes deployment for CASE - Survey System. It will walk you through creating individual images for each of the repositories and deploying them on to a running kubernetes cluster.

## Dependencies

0. Ensure that docker images are built and hosted at Dockerhub. See getting-started guide for instructions on setting this up.
1. A cluster with Kubernetes installed.
2. git

## **Creating a deployment of the docker hub images on a Kubernetes Cluster**

### Dependencies

0. Kubernetes service running on a cluster
1. Clone the repository by running the command: ``` git clone https://github.com/influenzanet/cluster-management.git```
2. Ingress is enabled on the cluster.
3. A suitable domain name is present for the server.
  
### Set up

Before proceeding, configure the values.yaml to reflect the details of your deployment. You can either edit the influenzanet-2.0/values.yaml or create a copy of the file and edit that instead.

In the values.yaml files, sections represent the following configurations:
1. namespace, domain and backend path configurations,
2. TLS certificate configurations,
3. Secret - JWT, Mongo credentials, recaptcha configurations,
4. Persistant volume configurations (for mongo), 
5. SMTP configurations for Email sending,
6. Microservice sections -> containing configurations of the deployment and service files for each of the microservices. This includes docker image paths for each microservice, environment variables, port configurations and persistant volume attachments if needed.

**Once these have been configured, run the install_start.sh script to install certificate-manager, nginx ingress load-balancer and the influenzanet 2.0 application.**

If you chose to use an edited copy of the values.yaml file, to run the installation run the following commands:
```
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

helm install -f <your-edited0valuesfile.yaml> influenzanet-2.0 ./influenzanet-2.0
```

### Deployment Steps
Once the repository has been checked out into the server:
1. Run the deployment script install_start.sh for the first time you set up the system.
3. To stop and clean up run stop.sh
3. To run the system after the initial set up, run start.sh. (prevents unnecessary reinstallation of nginx ingress & certificate manager)
4. Manual running of the helm install and uninstall is required in case of an edited values.yaml file.

### Troubleshooting

1. When deploying on minikube enable the NGINX Ingress controller by running the following command:
	```
	minikube addons enable ingress
	```
2. Verify that the NGINX Ingress controller is running
	```
	kubectl get pods -n kube-system
	```
3. Check the status of the deployments by running the following commands:
	```
	kubectl get deployments,services,pods --namespace=case
	
	```
4. On GKE sometimes webhook creation might fail for nginx admission, to get past this error run the following:
	```
	kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
	```
5. Lets encrypt (which is used for certificate creation) has a duplicate certificate creation limit of 5 per week. 
	```
	check logs of the created certificate by runnning
	kubectl describe certificate <cert-name> -n case
	```
6. In case of errors in mail sending, you might have to edit the nginx ingress controller deployment and add the following ports
	```

        - containerPort: 465
          name: smtpssl
          protocol: TCP
        - containerPort: 587
          name: smtpauth
          protocol: TCP
	```

	and to the nginx controller service the following: 
	```
		- name: smtp
			port: 587
			protocol: TCP
			targetPort: 587
		- name: smtpssl
			port: 465
			protocol: TCP
			targetPort: 465
	```