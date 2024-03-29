SHELL := /usr/bin/env bash

THIS_FILE := $(lastword $(MAKEFILE_LIST))
include .pipeline/oc.mk

.PHONY: whoami
whoami: $(call make_help,whoami,Prints the name of the user currently authenticated via `oc`)
	$(call oc_whoami)

.PHONY: lint
lint: $(call make_help,lint,Checks the configured yml template definitions against the remote schema using the tools namespace)
lint: whoami
	@helm dep up helm/cas-shipit
	@helm template cas-shipit helm/cas-shipit -f secret-values.example.yaml --validate -n $(OC_PROJECT)

.PHONY: install
install: whoami
	@helm repo add cas-postgres https://bcgov.github.io/cas-postgres/
	@helm repo add bitnami https://charts.bitnami.com/bitnami
	@helm dep build helm/cas-shipit
	@helm upgrade --install cas-shipit helm/cas-shipit -n $(OC_PROJECT) \
		--set image.tag=$(GIT_SHA1) --set image.pullPolicy=IfNotPresent
