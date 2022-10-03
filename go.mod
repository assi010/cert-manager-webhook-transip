module github.com/assi010/cert-manager-webhook-transip

go 1.18

require (
	github.com/Azure/azure-sdk-for-go/sdk/azidentity v1.1.0
	github.com/Azure/azure-sdk-for-go/sdk/keyvault/azkeys v0.8.0
	github.com/assi010/gotransip/v6 v6.18.0
	github.com/cert-manager/cert-manager v1.8.1
	k8s.io/api v0.23.4
	k8s.io/apiextensions-apiserver v0.23.4
	k8s.io/apimachinery v0.23.4
	k8s.io/client-go v0.23.4
)
