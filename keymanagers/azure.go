package keymanagers

import (
	"context"
	"crypto/sha512"
	"encoding/base64"
	"fmt"
	"github.com/Azure/azure-sdk-for-go/sdk/azidentity"
	"github.com/Azure/azure-sdk-for-go/sdk/security/keyvault/azkeys"
)

const (
	azureKeyVaultProviderName string = "AzureKeyVault"
)

type AzureKeyVaultProvider struct {
	configuration *KeyManagerConfig
}

func (a AzureKeyVaultProvider) Sign(body []byte) (string, error) {
	keyName := a.configuration.KeyName
	vaultUrl := a.configuration.VaultUrl

	if keyName == "" || vaultUrl == "" {
		return "", fmt.Errorf("keyName and vaultUrl variables are required. Supplied keyname: '%s' and vaulturl: '%s'", keyName, vaultUrl)
	}

	cred, err := azidentity.NewDefaultAzureCredential(nil)
	if err != nil {
		return "", fmt.Errorf("failed to obtain a credential: %v", err)
	}

	client, err := azkeys.NewClient(vaultUrl, cred, nil)
	if err != nil {
		return "", err
	}

	version := ""
	algorithm := azkeys.SignatureAlgorithmRS512
	digest := sha512.Sum512(body)
	signParameters := azkeys.SignParameters{
		Algorithm: &algorithm,
		Value:     digest[:],
	}
	signResponse, err := client.Sign(context.TODO(), keyName, version, signParameters, nil)
	if err != nil {
		return "", fmt.Errorf("could not sign data: %w", err)
	}
	enc := signResponse.Result
	return base64.StdEncoding.EncodeToString(enc), nil
}
