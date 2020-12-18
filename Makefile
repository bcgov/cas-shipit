SHELL := /usr/bin/env bash

THIS_FILE := $(lastword $(MAKEFILE_LIST))
include .pipeline/oc.mk

.PHONY: whoami
whoami: $(call make_help,whoami,Prints the name of the user currently authenticated via `oc`)
	$(call oc_whoami)

.PHONY: lint
lint: $(call make_help,lint,Checks the configured yml template definitions against the remote schema using the tools namespace)
lint: OC_PROJECT=$(OC_TOOLS_PROJECT)
lint: whoami
	@helm template cas-shipit helm/cas-shipit -f secret-values.example.yml --validate

.PHONY: install
install: whoami
	@helm upgrade --install cas-shipit helm/cas-shipit --atomic
