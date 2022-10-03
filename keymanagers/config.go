package keymanagers

import (
	"fmt"
	"github.com/assi010/gotransip/v6/authenticator"
)

type KeyManagerConfig struct {
	ProviderName string `json:"providerName"`
	VaultUrl     string `json:"vaultUrl"`
	KeyName      string `json:"keyName"`
}

func GetProvider(config KeyManagerConfig) (authenticator.KeyManager, error) {
	switch config.ProviderName {
	case azureKeyVaultProviderName:
		return AzureKeyVaultProvider{configuration: &config}, nil
	default:
		return nil, fmt.Errorf("given keymanager provider is not supported: %s", config.ProviderName)
	}
}
