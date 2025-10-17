OS ?= $(shell go env GOOS)
ARCH ?= $(shell go env GOARCH)

IMAGE_NAME := "ghcr.io/assi010/cert-manager-webhook-transip"
IMAGE_TAG := "v1.1.2"

OUT := $(shell pwd)/_out

KUBE_VERSION=1.34.1

$(shell mkdir -p "$(OUT)")
export TEST_ASSET_ETCD=_test/envtest/bin/etcd
export TEST_ASSET_KUBE_APISERVER=_test/envtest/bin/kube-apiserver
export TEST_ASSET_KUBECTL=_test/envtest/bin/kubectl
export TEST_ZONE_NAME=example.com.

test: _test/envtest
	go test -v .

_test/envtest:
	curl -fsSL https://github.com/kubernetes-sigs/controller-tools/releases/download/envtest-v$(KUBE_VERSION)/envtest-v$(KUBE_VERSION)-$(OS)-$(ARCH).tar.gz -o envtest.tar.gz
	mkdir -p _test/envtest
	tar -xvf envtest.tar.gz
	mv controller-tools/envtest _test/envtest/bin
	rm envtest.tar.gz
	rm -R controller-tools

clean: clean-envtest

clean-envtest:
	rm -Rf _test/envtest

build:
	docker build -t "$(IMAGE_NAME):$(IMAGE_TAG)" .

.PHONY: rendered-manifest.yaml
rendered-manifest.yaml:
	helm template transip-webhook \
        --set image.repository=$(IMAGE_NAME) \
        --set image.tag=$(IMAGE_TAG) \
        deploy/transip-webhook > "$(OUT)/rendered-manifest.yaml"
