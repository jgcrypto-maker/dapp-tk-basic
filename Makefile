SHELL := /bin/sh
.DEFAULT_GOAL := help

COMPOSE ?= docker compose
DEV := -f compose.yaml -f compose.dev.yaml
TOOLS := -f compose.yaml -f compose.tools.yaml

# Keep buildx state inside the repo (works in sandboxed/CI environments too).
BUILDX_CONFIG ?= $(CURDIR)/.buildx
export BUILDX_CONFIG

# Versions are pinned here and exported so Compose interpolation uses the same values.
FOUNDRY_VERSION ?= v1.5.1@sha256:3a70bfa9bd2c732a767bb60d12c8770b40e8f9b6cca28efc4b12b1be81c7f28e
NODE_IMAGE ?= node:22-alpine@sha256:fe4f6d74e20370acb04ad889077d14d0f64a9c8ea6a42bc60cddf1e844699914
WEB_IMAGE ?= dapp-tk-web:local
CONTRACTS_IMAGE ?= dapp-tk-contracts:local
export FOUNDRY_VERSION NODE_IMAGE WEB_IMAGE CONTRACTS_IMAGE

.PHONY: help doctor env dev up down logs ps test fmt fmt-check build-web build-contracts clean \
	naming docs-links compose-check check

help: ## Show this help
	@echo "dapp-tk-basic — make targets"
	@echo ""
	@echo "  make doctor           Check Docker, versions and required ports"
	@echo "  make env              Create .env.dev from .env.example when missing"
	@echo "  make dev              Start Anvil + Next.js with hot reload (foreground)"
	@echo "  make up               Start Anvil + Next.js in background"
	@echo "  make down             Stop and remove the DEV stack"
	@echo "  make logs             Follow DEV logs"
	@echo "  make ps               Show DEV service status"
	@echo "  make test             Run forge test in the contracts container"
	@echo "  make fmt              Format Solidity with forge fmt"
	@echo "  make fmt-check        Check Solidity formatting (CI)"
	@echo "  make naming           Check file names against docs/NAMING.md"
	@echo "  make docs-links       Check internal documentation links"
	@echo "  make compose-check    Validate the Compose files"
	@echo "  make check            Run naming, docs links, compose and fmt checks"
	@echo "  make build-web        Build the production web image (runner stage)"
	@echo "  make build-contracts  Build the contracts image"
	@echo "  make clean            Stop DEV and drop its volumes"

doctor: ## Check the host toolchain
	@docker version --format 'engine {{.Server.Version}}' >/dev/null 2>&1 || { echo "docker: no disponible"; exit 1; }
	@docker version --format 'engine {{.Server.Version}}'
	@docker compose version
	@docker buildx version
	@printf '3000: '; lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1 && echo "ocupado" || echo "libre"
	@printf '8545: '; lsof -nP -iTCP:8545 -sTCP:LISTEN >/dev/null 2>&1 && echo "ocupado" || echo "libre"

env: ## Create .env.dev from .env.example when missing
	@test -f .env.dev || { cp .env.example .env.dev; echo "creado .env.dev a partir de .env.example"; }

dev: env ## Start DEV stack in foreground
	$(COMPOSE) $(DEV) up --build

up: env ## Start DEV stack in background
	$(COMPOSE) $(DEV) up -d --build

down: ## Stop DEV stack
	$(COMPOSE) $(DEV) down --remove-orphans

logs: ## Follow DEV logs
	$(COMPOSE) $(DEV) logs -f --tail=100

ps: ## Show DEV service status
	$(COMPOSE) $(DEV) ps

test: env ## Run forge test in a container
	$(COMPOSE) $(TOOLS) run --rm --build contracts test -vvv

fmt: ## Format Solidity
	$(COMPOSE) $(TOOLS) run --rm --build contracts fmt

fmt-check: ## Check Solidity formatting
	$(COMPOSE) $(TOOLS) run --rm --build contracts fmt --check

build-contracts: ## Build the contracts image
	$(COMPOSE) $(TOOLS) build contracts

naming: ## Check file names against docs/NAMING.md
	./scripts/check-file-names.sh

docs-links: ## Check internal documentation links
	./scripts/check-links.sh

compose-check: ## Validate the Compose files
	$(COMPOSE) $(DEV) config --quiet
	$(COMPOSE) $(TOOLS) config --quiet

check: naming docs-links compose-check fmt-check ## Run all static checks

build-web: ## Build the production web image
	docker build --target runner -t $(WEB_IMAGE) ./web

clean: ## Stop DEV and remove its volumes
	$(COMPOSE) $(DEV) down -v --remove-orphans
