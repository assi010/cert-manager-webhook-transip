# TransIP Cert-Manager webhook

This is an implementation of a Cert-Manager webhook for implementing DNS01 acme verification with TransIP as a DNS provider.

[![Cert-Manager](https://img.shields.io/badge/Cert_manager-1.19.1-brightgreen)](https://cert-manager.io/docs/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.34.1-brightgreen)](https://kubernetes.io/docs/home/)
![Linux amd64](https://img.shields.io/badge/Linux-amd64-blue)
![Linux arm64](https://img.shields.io/badge/Linux-arm64-blue)

### Supported kubernetes versions

| Kubernetes | Supported | Tested | Notes                                          |
|------------|-----------|--------|------------------------------------------------|
| v1.31      | ✅         | ✅      |                                                |
| v1.32      | ✅         | ✅      |                                                |
| v1.33      | ✅         | ✅      |                                                |
| v1.34      | ✅         | ✅      | Cert-Manager supports k8s v1.34 starting v1.19 |


### Notes
⚠️ This webhook uses a [modified](https://github.com/assi010/gotransip) version of the gotransip package to support signing requests using an external KMS (e.g. Azure keyvault).\
🔒 This webhook is able to run in a [restricted](https://kubernetes.io/docs/concepts/security/pod-security-standards/) namespace as it runs rootless, with a read-only filesystem, and all Linux capabilities dropped for maximum security.\
🌐 In case you run a split-brain DNS setup for your domain, do not forget to configure the [recursive nameservers](https://cert-manager.io/docs/configuration/acme/dns01/#setting-nameservers-for-dns01-self-check) in cert-manager.

### Installation

You can use Helm to deploy the webhook:

```shell script
helm repo add transip-webhook https://assi010.github.io/cert-manager-webhook-transip/
helm install transip-webhook transip-webhook/transip-webhook
```

Alternatively, you can use kubectl to deploy:

```shell script
kubectl -n cert-manager apply -f https://raw.githubusercontent.com/assi010/cert-manager-webhook-transip/master/deploy/recommended.yaml
```

Both methods will simply deploy the webhook container into your Kubernetes environment. After deployment, you'll have to configure the webhook to interface with your TransIP account.

### Configuration

The webhook needs your TransIP account name and your API private key. The private key must be deployed as a secret.

_This command can be skipped when using the Azure KeyVault to sign api requests._

```shell script
# Given your private key is in the file private.key
kubectl -n cert-manager create secret generic transip-credentials --from-file=private.key
```

After saving your private key as a secret to the cluster, you'll have to configure the Issuer object. You can use the following as a template:
```yaml
apiVersion: cert-manager.io/v1
# Change to ClusterIssuer when used in multiple namespaces
kind: Issuer 
metadata:
  name: letsencrypt-staging
  namespace: your-desired-namespace
spec:
  acme:
    email: user@example.com
    # For production use: https://acme-v02.api.letsencrypt.org/directory
    server: https://acme-staging-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: le-staging-issuer-key
    solvers:
    - dns01:
        webhook:
          groupName: cert-manager.webhook.transip
          solverName: transip
          config:
            accountName: your-transip-username
            ttl: 300
            # When using the private key as secret in k8s
            privateKeySecretRef:
              name: transip-credentials
              key: private.key
            # When using managed identities and the Azure KeyVault
            # keyManager:
            #   providerName: "AzureKeyVault"
            #   vaultUrl: "https://my-azure-keyvault-url",
            #   keyName: "name of key in Azure KeyVault"
```

That's it! Now you're set up to request your first certificate!
You can use the following as an example:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: example-com
  namespace: your-desired-namespace
spec:
  secretName: example-com-secret
  dnsNames:
    - example.com
  issuerRef:
    name: letsencrypt-staging
    # We can reference ClusterIssuers by changing the kind here.
    # The default value is Issuer (i.e. a locally namespaced Issuer)
    kind: Issuer
```

### Running the test suite

Please start out by configuring your username in `testdata/transip/config.json` and private key in `testdata/transip/secret.yaml`. You can then run the test suite with:

```bash
$ TEST_ZONE_NAME=example.com. make test
```
