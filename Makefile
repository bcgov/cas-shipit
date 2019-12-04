SHELL := /usr/bin/env bash
PATHFINDER_PREFIX := wksv3k
PROJECT_PREFIX := cas-

THIS_FILE := $(lastword $(MAKEFILE_LIST))
include .pipeline/oc.mk

.PHONY: whoami
whoami: $(call make_help,whoami,Prints the name of the user currently authenticated via `oc`)
	$(call oc_whoami)

.PHONY: lint
lint: $(call make_help,lint,Checks the configured yml template definitions against the remote schema using the tools namespace)
lint: OC_PROJECT=$(OC_TOOLS_PROJECT)
lint: whoami
	$(call oc_lint)

.PHONY: create_secrets
create_secrets: OC_PROJECT=$(OC_TOOLS_PROJECT)
create_secrets: POSTGRES_PASSWORD != openssl rand -base64 32 | tr -d /=+ | cut -c -16
create_secrets: RAILS_MASTER_KEY != openssl rand -base64 64 | tr -d '/=+\n' | cut -c -32
create_secrets: whoami
	$(eval OC_TEMPLATE_VARS += POSTGRES_PASSWORD_BASE_64="$(shell echo -n "$(POSTGRES_PASSWORD)" | base64)" RAILS_MASTER_KEY="$(shell echo -n "$(RAILS_MASTER_KEY)" | base64)")
	$(call oc_create_secrets)

.PHONY: configure
configure: $(call make_help,configure,Configures the tools project namespace for a build)
configure: OC_PROJECT=$(OC_TOOLS_PROJECT)
configure: whoami
	$(call oc_configure)

INCREMENTAL_BUILD=false
OC_TEMPLATE_VARS += INCREMENTAL_BUILD=$(INCREMENTAL_BUILD)

.PHONY: build
build: $(call make_help,build,Builds the source into an image in the tools project namespace)
build: OC_PROJECT=$(OC_TOOLS_PROJECT)
build: whoami
	$(call oc_build,$(PROJECT_PREFIX)shipit)

.PHONY: install
install: OC_PROJECT=$(OC_TOOLS_PROJECT)
install: whoami
	$(eval POSTGRES_PASSWORD = $(shell $(OC) -n "$(OC_PROJECT)" get secret/$(PROJECT_PREFIX)shipit-postgres -o go-template='{{index .data "database-password"}}' | base64 -d))
	$(eval OC_TEMPLATE_VARS += POSTGRES_PASSWORD="$(POSTGRES_PASSWORD)")
	$(call oc_deploy)
	$(call oc_wait_for_deploy_ready,$(PROJECT_PREFIX)shipit)

.PHONY: provision
provision: whoami
	$(call oc_new_project,$(OC_TOOLS_PROJECT))
	$(call oc_new_project,$(OC_TEST_PROJECT))
	$(call oc_new_project,$(OC_DEV_PROJECT))
	$(call oc_new_project,$(OC_PROD_PROJECT))
