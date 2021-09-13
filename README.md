
# Running a kubernetes deployment

This guide will walk you through creating a Kubernetes deployment for the Influenzanet platform. It will walk you through creating individual images for each of the repositories and deploying them on to a running Kubernetes cluster.

## Dependencies

1. Docker images for each service must be built and hosted at your Dockerhub repository. See [influenzanet-setup-guide](https://github.com/influenzanet/influenzanet-setup-guide) for instructions on setting this up.

2. A cluster with Kubernetes installed.

## Creating a deployment of the docker hub images on a Kubernetes Cluster

### Dependencies

1. Kubernetes service running on a cluster

2. Ingress is enabled on the cluster.

3. A suitable domain name is present for the server.

4. A clone of this repository

   ```sh
   git clone https://github.com/influenzanet/cluster-management.git
   ```

### Set up

Before proceeding, configure the values.yaml to reflect the details of your deployment.

In the values.yaml files, sections represent the following configurations:
1. namespace, domain and backend path configurations,
2. TLS certificate configurations,
3. Secret - JWT, Mongo credentials, recaptcha configurations  
	3.1 How to get a recaptcha key:  
		Navigate to https://www.google.com/recaptcha/about/  
		Click on the admin console, and then click the plus icon. Give a suitable label.  
		Select reCAPTCHA v2 and an invisible recaptcha badge in the options  
		Add the domain , i.e. Influweb.org  
		Click submit, this should generate two keys, a public key and  a secret key.  
		Copy the public key and paste it in the REACT_APP_RECAPTCHA_SITEKEY field in your sample-env.config file in the participant-webapp  
		Next, copy the secret key and convert it to a base-64 format (you can use https://www.base64encode.org/ to perform this conversion)  

5. Persistant volume configurations (for mongo), 
6. SMTP configurations for Email sending,
7. Microservice sections -> containing configurations of the deployment and service files for each of the microservices. This includes docker image paths for each microservice, environment variables, port configurations and persistant volume attachments if needed.

**Once these have been configured, run the install_start.sh script to install certificate-manager, nginx ingress load-balancer and the influenzanet 2.0 application.**

### Deployment Steps

Once the repository has been checked out into the server and your configuration is in place:

1. Run the deployment script `install_start.sh` for the first time you set up the system.

2. To stop and clean up the Influenzanet services from the cluster run `stop.sh`

3. To reinstall the Influenzanet services platform after a clean-up, only run `start.sh` (prevents unnecessary re-installation of nginx ingress & certificate manager)

### Troubleshooting

1. Verify that the NGINX Ingress controller is running

  ```
  kubectl get pods -n kube-system
  ```

2. Check the status of the deployments by running the following commands:

  ```
  kubectl get deployments,services,pods --namespace=[influenzanet_namespace]
  ```

3. On GKE sometimes webhook creation might fail for nginx admission, to get past this error run the following:

  ```
  kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
  ```

4. Lets encrypt (which is used for certificate creation) has a duplicate certificate creation limit of 5 per week.  Check logs of the created certificate by runnning

  ```
  kubectl describe certificate <cert-name> -n [influenzanet_namespace]
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

7. In case the script `start.sh` or `install_start.sh` fails with an error: _"Failed to connect to Kubernetes cluster"_, ensure that you run the following in the google connect console.

  ```
  gcloud container clusters get-credentials influweb-italy-cluster --zone europe-west1-d --project infuweb-italy
  ```

  This will allow you to set the credentials to gain access to run the script.
  If this fails too, then try executing the instructions in the `install_start.sh` script manually in the terminal.
