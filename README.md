
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

Before proceeding, configure the `influenzanet-2.0/values.yaml` file to reflect the details of your deployment. In the `values.yaml` file you will find the following configuration values:

1. namespace, domain and back-end path configurations

    - `namespace`: the namespace under which each Kubernets component of Influenzanet will be registered, eg: `italy`
    - `domain`: the domain name hosting the platform, eg: `influweb.org`
    - `participantApiPath`: the path under which the participant API are served, eg: `/api`
    - `managementApiPath`: the path under which the management API are served, eg: `/admin`

2. TLS certificate configurations

    - `acmeServer`:  URL for the ACME server issuing TLS certificates, eg: `https://acme-v02.api.letsencrypt.org/directory`

    - `clusterIssuer`: name assigned to the ACME server, eg: `letsencrypt`

    - `connectedEmail`: email associated to the ACME server, will receive maintenance communication from the acme server.

3. Secrets: JWT, Mongo credentials, recaptcha key

    - `jwtKey`: base64 encoded key used for generating user authentication tokens, see [Generating a JWT key ](#generating-a-jwt-key ) for instructions on how to generate a key

    - `mongoUsername`: used to setup the mongo admin account

    - `mongoPassword`: password associated to the mongo admin account

    - `googleRecaptchaKey`: secret key associated to a Google recaptcha account, see [Generating a recaptcha key](#generating-a-recaptcha-key) for instructions on how to obtain a key

4. Persistent volume configurations (for mongo)

    Detailed information on these configuration values can be found in Kubernetes' documentation on [Persistent Volumes]( https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

    - `storageClass`: the storage class used by Kubernetes when requesting storage for the mongo database, eg: `standard`

    - `accessModes`: array of access modes for the requested storage, eg:
        - `- ReadWriteOnce`

    - `storageRequested`: size allocated for the storage, eg: `50Gi`

6. SMTP configurations for Email sending

    Specify default (`smtpServers`) and high priority (`smtpServers`) SMTP servers, for both entries you must specify:

    - `from`: what users see as the from address when receiving Influenzanet mails.
    - `sender`: email address of the sender (from can be a name as well)
    - `replyTo`: additional addresses to always send emails to (can be an empty array)
    - `servers`: array of SMTP servers specifying:
        - `host`: SMTP host
        - `port`: SMTP port
        - `auth`: contains the username and password credentials for the mailing service.

7. Microservice specific sections, containing configurations of the Kubernetes [deployment](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) and [service](https://kubernetes.io/docs/concepts/services-networking/service/) for each of the microservices. This includes docker image paths for each microservice, environment variables, port configurations and persistent volume attachments if needed. The most important value you need to change for each microservice is the location of the Dockerhub image:

    ```yaml
    participantWebapp:
      deployment:
        [...]
        spec:
          [...]
          template:
            spec:
              containers:
              - name: [container_name]
                image: [dockerhub_image]
              [...]
    ```

#### Generating a JWT key

The script used to generate a JWT key is hosted in the [user-management-service](https://github.com/influenzanet/user-management-service) repository. To generate a key cd into the directory `tools/key-generator` and run:

``` sh
go run main.go
```

copy the generated key and encode it in base64 format:

``` sh
echo -ne [jwt_key] | base64
```

put this value into to the `jwtKey` field.

#### Generating a recaptcha key

To generate a Google recaptcha key pair follow these steps:

- login into a Google account

- navigate to https://www.google.com/recaptcha/about/

- click on the admin console, and then click the plus icon. Give a suitable label.

- select reCAPTCHA v2 and an invisible recaptcha badge in the options

- add the domain , ie: influweb.org

- click submit, this should generate two keys, a public key and  a secret key.

- the public key is the one to be used it in the REACT_APP_RECAPTCHA_SITEKEY field in your [participant-webapp](https://github.com/influenzanet/participant-webapp) configuration file.

- the secret key is the one we need but must be base64 encoded before being put in `values.yml`:

    ```sh
    echo -ne [secret_key_here] | base64
    ```

- use the encoded value in the `googleRecaptchaKey` field.

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
