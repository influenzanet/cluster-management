# influenzanet-maintenance

After installing this chart:

``` bash
helm install influenzanet-maintenance influenzanet-maintenance/ -f influenzanet/values.yaml
```

all traffic to the Influenzanet platform will be redirected to a custom `503` page. Traffic will still pass-through for clients having a specific random string in their user agent.

To disable maintenance mode just uninstall this chart:

``` bash
helm uninstall influenzanet-mailgun
```

## Configurable values

- `platformName`: the name of your platform to be disaplyed in the maintenance page, eg: Influweb
- `contactEmail`: the email contact to be displayed in the maintenance page
- `allowAgent`: a random string for traffic pass-through
