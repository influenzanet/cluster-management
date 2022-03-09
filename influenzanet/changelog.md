# 1.0

Full refactor of the values. Now each service has its own entry and each parameters passed to the service has its own value to facilitate the 
overrides of the values following the best practices.

The secrets jwtKey, googleRecaptchaKey, studyGlobalSecret are now encoded in base64 by the helm chart so the values provided by the key tool and google are to be used directly as value (no need for manual transformation any more).

The deprecated network K8s API version has been dropped.

Some values has been renamed:
 - `connectedEmail` to `acmeEmail`
 - simplifiedIngress to `ingress.simplified`
 - 