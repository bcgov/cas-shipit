SHELL := /usr/bin/env bash

THIS_FILE := $(lastword $(MAKEFILE_LIST))

# Borrowed from cas-pipeline to remove a dependency
OC_PROJECT=$(shell echo "$${ENVIRONMENT:-$${OC_PROJECT}}")
GIT=$(shell command -v git)
ifeq ($(GIT),)
$(error 'git' not found in $$PATH)
endif
GIT_SHA1=$(shell $(GIT) rev-parse HEAD)



.PHONY: whoami
whoami: $(call make_help,whoami,Prints the name of the user currently authenticated via `oc`)
	$(call oc_whoami)

.PHONY: lint
lint: $(call make_help,lint,Checks the configured yml template definitions against the remote schema using the tools namespace)
lint: whoami
	@helm dep up helm/cas-shipit
	@helm template cas-shipit helm/cas-shipit -f secret-values.example.yaml --validate -n $(OC_PROJECT)

.PHONY: install_pgo_cluster
install_pgo_cluster:
	@set -euo pipefail;
	helm repo add cas-postgres https://bcgov.github.io/cas-postgres/;
	helm repo update;

	helm upgrade --install --atomic --timeout 3000s \
		--namespace $(OC_PROJECT) \
		--values ./helm/cas-shipit-postgres-cluster/values.yaml \
		cas-shipit-db cas-postgres/cas-postgres-cluster

# TODO: Remove cas-postgres and add PG-Cluster deployment
.PHONY: install
install: whoami install_pgo_cluster
	@helm repo add cas-postgres https://bcgov.github.io/cas-postgres/
	@helm repo add bitnami https://charts.bitnami.com/bitnami
	@helm dep build helm/cas-shipit
	@helm upgrade --install cas-shipit helm/cas-shipit -n $(OC_PROJECT) \
		--set image.tag=$(GIT_SHA1) --set image.pullPolicy=IfNotPresent
