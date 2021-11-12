# influenzanet-mailgun

Install this chart to create a `mailgun` [webhooks](https://www.mailgun.com/guides/your-guide-to-webhooks/) endpoint. If you are using `mailgun` this is useful for receiving and logging delivery failures.

``` bash
helm install influenzanet-mailgun influenzanet-mailgun/ -f influenzanet/values.yaml
```

Each delivery failure will generate a log message on `stderr` which could then trigger an automatic alert on `GCE`.

## Dependencies

This chart depends on a `Docker` image built using the included `Dockerfile`. The image will run a simple `express` server receiving `POST` requests from `mailgun` and logging their content.

``` bash
cd influenzanet-mailgun
docker build . -t [dockerhub_repo]/mailgun-webhook:v1.0
docker push [dockerhub_repo]/mailgun-webhook:v1.0
```

## Configurable values

- `image`: location of the docker image, eg: `[dockerhub_repo]/mailgun-webhook`
endpoint: [endpoint-url-path]
- `endpoint`: the name of the endpoint to be created, eg: `/mailgun-[random_part]`