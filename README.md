# Deploy influenzanet on a Kubernetes cluster

Influenzanet is a cloud-agnostic microservices platform. This guide will walk you through creating a Kubernetes deployment for the Influenzanet services, with an optional focus on the [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine?hl=it) cloud solution.

## Dependencies

1. Docker images for each Influenanet service must be built and hosted at your Dockerhub repository
   (see [influenzanet-setup-guide](https://github.com/influenzanet/influenzanet-setup-guide) for instructions on setting this up)

2. Kubernetes orchestrator running on a cluster

5. A local clone of this repository

6. [Helm](https://helm.sh/) package manager installed locally

## Deployment configuration

The Influenzanet Kubernetes deployment is managed using Helm charts. Before you can proceed with the deploy, you must customize the main chart values defined in the [influenzanet/values.yaml](./influenzanet/values.yaml) file.

Instead of modifying the main chart values directly, it's also possible to create additional `yaml` files in order to add/override values in the [influenzanet/values.yaml](./influenzanet/values.yaml). These additional files are to be passed to the `helm install` command using the `-f` flag. If one of the files defines secrets, it's advised not to track it and to store it in a secure location. Following this approach, we could define one `yaml` file for the common configuration parts and one or several others for the production/development environments and yet one another file storing the secrets.

Inside the `values.yaml` file you will find the following configuration values (see [influenzanet/values.yaml](./influenzanet/values.yaml) for a concrete example):

### Global variables

1. platform description

    - `namespace`: the namespace under which each Kubernets component of Influenzanet will be registered
    - `platformName`: the official name of the platform being deployed
    - `contactEmail`: principal email for contact / support

2. external access configuration

    - `ingress`:
      - `enabled`: `true`, if `false` no external access to the cluster will be set up
      - `name`: a name for the ingress

    - `domain`: the base domain name hosting the platform
    - `redirectDomains`: array of domains to be redirected to the base domain

    - `participantApiPath`: the path under which the participant API will be served, eg: `/api`
    - `managementApiPath`: the path under which the management API will be served, eg: `/admin`

4. TLS configuration

    - `tlsDomains`: array of additional domains to be included in the TLS certificate, in addition to `domain` and `redirectDomains` 

    The `issuerType` variable is used to switch between different TLS configurations.

    Using an ACME service:

    - `issuerType`: `acme`

    - `acmeServer`:  URL for the ACME server issuing TLS certificates

    - `clusterIssuer`: name assigned to this ACME server

    - `acmeEmail`: email associated to this ACME server, will receive maintenance communication

    - `tlsSecretName`: name for the generated secret storing the TLS certificate

    Using a local CA:

    - `issuerType`: `ca`
    - `CAIssuerSecretName`: name of the kubernetes secret containing the CA private key and certificate.

    Disable TLS entirely:

    - `issuerType`: `none` won't create any certificate issuer and no local CA 

5. basic authentication and anti-spam protection

    - `basicAuth`:
      - `enabled`: `true` / `false`
      - `username`: the username to be used 
      - `password`: the password to be required
      - `excludePaths`: array of paths to exclude

    - `useRecaptcha`: if `true`, use Google Recaptcha for protecting the signup process, disables Google Recaptcha if `false`

5. SMTP configuration for outgoing emails

    Specify default (`smtpServers`) and high priority (`prioSmtpServers`) SMTP servers, for both entries you must specify:

    - `from`: what users see as the from address when receiving Influenzanet mails.
    - `sender`: email address of the sender (from can be a name as well)
    - `replyTo`: additional addresses to always send emails to (can be an empty array)
    - `servers`: array of SMTP servers specifying:
        - `host`: SMTP host
        - `port`: SMTP port
        - `connections`: number of concurrent connections
        - `sendTimeout`: send timeout in seconds
        - `auth`: contains the username and password credentials for the mailing service.

1. platform secrets: JWT key, MongoDB credentials, recaptcha key

    - `jwtKey`: base64 encoded key used for generating user authentication tokens, see [Generating a JWT key](#generating-a-jwt-key) for instructions on how to generate a key

    - `mongoUsername`: used to setup the mongo admin account

    - `mongoPassword`: password associated to the mongo admin account

    - `googleRecaptchaKey`: secret key associated to a Google recaptcha account, see [Generating a recaptcha key](#generating-a-recaptcha-key) for instructions on how to obtain a key

    - `studyGlobalSecret`: global secret used by [study-service](https://github.com/influenzanet/study-service)

### Services confguration

1. MongoDB

    Optionally configure a cluster-local MongoDB instance to be used by the Influenzanet microservices or leverage on an external MongoDB provider.

    - `svcMongoDb`:
      - `enabled`: `true`, if `false` no MongoDB service will be created
      - `image`: Docker image to use, eg: `mongo:5.0`
      - `serviceName`: name used when referring to this service, eg: `mongo-service`
      - `containerPort`: port on which the service will listen for incoming connections, eg: `27017`
      - `storageRequested`: storage to be allocated for the db, eg: `50Gi`
      - `storageClass`: storage class to use when provisioning the persistent volume, if equal to `influenzanet-storage`, a custom storage class will be created and used, defined in [storageClass.yaml](./influenzanet/templates/storageClass.yaml). This is a custom storage class using Google CSI driver and a default `retain` policy. If you plan to use a default storage class or another one from your cloud provider, set this value accordingly.

    MongoDB connection and database configuration:

    - `dbConnectionStr`: point this to the internal MongoDB service, eg: `mongo-service:27017` or to an external MongoDB provider
    - `dbConnectionPrefix`: used for adding a suffix like `+srv` to the standard `mongodb` prefix 
    - `dbNamePrefix`: prefix to use for the databases created by the microservices (useful for multi tenant database scenarios)
    - `dbSecretName`: name of the kubernetes secret storing the MongoDB credentials defined earlier

6. Influenzanet microservices

    Microservice-specific sections containing configurations variables for each of the microservices. Each section includes docker image paths for the microservice, environment variables values to be passed to the backing pod, port configurations and MongoDB connection overrides (if needed).

    Each microservice has its own entry:

    - `svcManagementApi`
    - `svcParticipantApi`
    - `svcUserManagement`
    - `svcStudyService`
    - `svcMessaging`
    - `SvcMessageScheduler`
    - `svcEmailClient`
    - `svcLogging`

    Each entry provides a set of parameters to configure that service. The most important common parameters are:

    - `image`: name of the docker image to use
    - `replicas`: number of replicas to start for the service
    - `dbConnectionStr`: override for the corresponding global variable 
    - `dbConnectionPrefix`: override for the corresponding global variable 
    - `dbNamePrefix`: override for the corresponding global variable 
    - `dbSecretName`: override for the corresponding global variable 

    For the configuration parameters specific to each service (passed to the pods as environment variables), refer to the documentation inside the service repository among the [influenzanet repositories](https://githu.com/influenzanet).

## Deploy Instructions

Once your configuration is in place:

1. Point `kubectl` to the appropriate context

1. Run the script `install_deps.sh` the first time you set up the system.

3. To install/uninstall the base Influenzanet chart run:

    ``` sh
    helm install influenzanet ./influenzanet
    helm uninstall influenzanet
    ```

3. To uninstall the Influenzanet dependencies run `uninstall_deps.sh`

## Appendix

### Additional charts

Additional `helm` charts are available for several plug-in functionalities:

- [influenzanet-mailgun](./influenzanet-mailgun): chart for setting up mailgun [webhooks](https://www.mailgun.com/guides/your-guide-to-webhooks/)
- [influenzanet-maintenance](./influenzanet-maintenance): chart for enabling maintenance mode on the deployed Influenzanet platform

Each of the above charts depends on the base `influenzanet` chart and depends on the `values.yaml` contained therein, eg:

``` bash
helm install influenzanet-backups influenzanet-backups/ -f influenzanet/values.yaml
```

For further details see the `README.md` included in each subchart.

### Additional notes

#### Generating a JWT key

The script used to generate a JWT key is hosted in the [user-management-service](https://github.com/influenzanet/user-management-service) repository. To generate a key cd into the directory `tools/key-generator` and run:

``` sh
go run main.go
```
put this value into to the `jwtKey` field.

#### Generating a recaptcha key

To generate a Google recaptcha key pair follow these steps:

- login into a Google account

- navigate to https://www.google.com/recaptcha/about/

- click on the admin console, and then click the plus icon. Give a suitable label.

- select reCAPTCHA v2 and an invisible recaptcha badge in the options

- add the domain , ie: example.com

- click submit, this should generate two keys, a public key and  a secret key.

- the public key is the one to be used it in the REACT_APP_RECAPTCHA_SITEKEY field in your [participant-webapp](https://github.com/influenzanet/participant-webapp) configuration file.

- use the private key value in the `googleRecaptchaKey` value.

### Compatible Influenzanet services versions

This chart has been tested against the following versions of the influenzanet services:

| Service                 | Repository / Changelog        | Version  |
| ------------------------| ------------------------------|----------|
| participant-api         | [api-gateway][ag]             |  v1.2.0  |
| management-api          | [api-gateway][ag]             |  v1.2.0  |
| study-service           | [study-service][ss]           |  v1.3.1  |
| user-management-service | [user-management-service][us] |  v1.1.1  |
| email-client-service    | [messaging-service][ms]       |  v1.2.0  |
| message-scheduler       | [messaging-service][ms]       |  v1.2.0  |
| messaging-service       | [messaging-service][ms]       |  v1.2.0  |
| logging-service         | [logging-service][ls]         |  v0.2.0  |

[ag]: https://github.com/influenzanet/api-gateway/blob/master/CHANGELOG.md
[ss]: https://github.com/influenzanet/study-service/blob/master/CHANGELOG.md
[us]: https://github.com/influenzanet/user-management-service/blob/master/CHANGELOG.md
[ms]: https://github.com/influenzanet/messaging-service/blob/master/CHANGELOG.md
[ls]: https://github.com/influenzanet/logging-service
