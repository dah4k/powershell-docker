# Copyright 2025 dah4k
# SPDX-License-Identifier: EPL-2.0

PROJECT_NAME:= $(shell echo "$(notdir $(PWD))" | tr "A-Z" "a-z")
DOCKER      ?= docker
DOCKER_TAG  ?= local/$(PROJECT_NAME)
_ANSI_NORM  := \033[0m
_ANSI_CYAN  := \033[36m

.PHONY: help usage
help usage:
	@grep -hE '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?##"}; {printf "$(_ANSI_CYAN)%-20s$(_ANSI_NORM) %s\n", $$1, $$2}'

.PHONY: $(DOCKER_TAG)
$(DOCKER_TAG): Dockerfile
	$(DOCKER) build --tag $(DOCKER_TAG) --file Dockerfile .

.PHONY: all
all: $(DOCKER_TAG) ## Build container image

.PHONY: test
test: $(DOCKER_TAG) ## Test run container image
	$(DOCKER) run --interactive --tty --rm --name=$(PROJECT_NAME) $(DOCKER_TAG)

.PHONY: debug
debug: $(DOCKER_TAG) ## Debug container image
	$(DOCKER) run --interactive --tty --rm --entrypoint=/bin/bash $(DOCKER_TAG)

.PHONY: clean
clean: ## Remove container image
	$(DOCKER) image remove --force $(DOCKER_TAG)

.PHONY: distclean
distclean: clean ## Prune all container images
	$(DOCKER) image prune --force
	$(DOCKER) system prune --force
