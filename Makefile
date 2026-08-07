ifneq (,$(wildcard .env))
include .env
export
endif

IMAGE_NAME ?= code-keeper-toolbox
CONTAINER_NAME ?= code-keeper-toolbox


.PHONY: help \
	init build start stop \
	tailscale ping check provision  clean

init:
	@chmod +x scripts/install_docker_rootless.sh
	@./scripts/install_docker_rootless.sh

build:
	@echo "==> Building toolbox..."
	@docker build -t "$(IMAGE_NAME)" .


start:
	@echo "==> Starting toolbox..."

	@if docker ps --format '{{.Names}}' | grep -q "^$(CONTAINER_NAME)$$"; then \
		echo "==> Toolbox is already running."; \
	else \
		docker rm -f "$(CONTAINER_NAME)" >/dev/null 2>&1 || true; \
		docker run -d \
			--name "$(CONTAINER_NAME)" \
			--env-file .env \
			-v "$(PWD):/workspace" \
			-w /workspace \
			"$(IMAGE_NAME)"; \
		echo "==> Toolbox started."; \
	fi
	@echo "==> Entering toolbox..."
	@docker exec -it "$(CONTAINER_NAME)" bash


stop:
	@echo "==> Stopping toolbox..."
	@docker rm -f "$(CONTAINER_NAME)" >/dev/null 2>&1 || true

ssh:
	@echo "==> Connecting to $(CODE_KEEPER_USER)@$(CODE_KEEPER_HOST) through Tailscale..."
	ssh \
		-i "$(SSH_KEY)" \
		-o ProxyCommand="nc -X 5 -x $(TAILSCALE_PROXY) %h %p" \
		$(CODE_KEEPER_USER)@$(CODE_KEEPER_HOST)

ping:
	@echo "==> Testing remote Ansible connectivity..."
	@ansible all -m ping \
		--vault-password-file=.vault_pass

check:
	@echo "==> Running Ansible check mode..."
	@ansible-playbook \
		ansible/playbook.yml \
		--vault-password-file=.vault_pass \
		--check


provision:
	@echo "==> Provisioning remote VM..."
	@ansible-playbook \
		ansible/playbook.yml \
		--vault-password-file=.vault_pass

clean:

	@echo "==> Removing toolbox..."
	@docker rm -f "$(CONTAINER_NAME)" 2>/dev/null || true

	@docker rmi  "$(IMAGE_NAME)" 2>/dev/null || true

	@echo "==> Cleanup complete."