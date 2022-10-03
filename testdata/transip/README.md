# Solver testdata setup

Place your TransIP account name in the `config.json` file and update the private key value in the `secret.yaml` in order to run tests.

```json
{
  "accountName": "username",
  "privateKeySecretRef": {
    "name": "transip-credentials",
    "key": "private.key"
  },
  "ttl": 300
} 
```

## Testing using the azure keyvault

Running the test suite using the azure keyvault provider is also supported. 

First run:
```shell
az login
```

Then replace `privateKeySecretRef` with `keyManager` in the `config.json` file.

```json
{
  "accountName": "username",
  "keyManager": {
    "providerName": "AzureKeyVault",
    "vaultUrl": "https://my-azure-keyvault-url",
    "keyName": "name of the key in the vault"
  },
  "ttl": 300
}
```