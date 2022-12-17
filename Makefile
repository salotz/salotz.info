
##@ Commands

bootstrap: ## Install development tools
	# install Nikola
	pipx install --force Nikola[extras]
	# add extra dependencies
	pipx inject Nikola[extras] pypandoc
	pipx inject Nikola[extras] pydevto
	# ghp-import as a standalone tool
	pipx install --force ghp-import
	# install plugins
	nikola plugin -i devto
.PHONY: bootstrap

build: ## Generate the static site
	nikola build
.PHONY: build

dev: ## Start the reloading development server
	nikola auto -b -p 5544
.PHONY: dev

check: build ## Run the Nikola checker
	nikola check -lf
.PHONY: check

deploy: ## Run the deployment
	nikola github_deploy
.PHONY: deploy

clean: ## Clean the project
	nikola clean
.PHONY: clean

##@ Help

# An automatic help command: https://www.padok.fr/en/blog/beautiful-makefile-awk
.DEFAULT_GOAL := help

help: ## (DEFAULT) This command, show the help message
	@echo "To get started fresh:"
	@echo "  > make bootstrap"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
.PHONY: help
