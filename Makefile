DIR     := $(shell pwd)
VM_NAME := "Code-Keeper-VM"
CONTAINER_NAME="tailscale-proxy"

TAILSCALE_PROXY := 127.0.0.1:1055
TAILSCALE_HOST  := 100.126.18.79
SSH_USER        := vagrant
SSH_KEY         := .vagrant/machines/default/virtualbox/private_key

.PHONY: help init up ssh halt status reload provision pass vbox ova clean proxy-up snapshot

# Default help display
help:
	@echo "Available commands:"
	@echo "  make init      - Install host dependencies (Vagrant, VirtualBox)"
	@echo "  make up        - Boot up the VM (runs provisioning on first boot)"
	@echo "  make ssh       - Open terminal session inside the VM"
	@echo "  make pass      - Retrieve temporary GitLab root password"
	@echo "  make status    - Check VM status"
	@echo "  make halt      - Stop the VM gracefully"
	@echo "  make reload    - Restart the VM (applies network/Vagrantfile changes)"
	@echo "  make provision - Re-run shell scripts on the running VM"
	@echo "  make vbox      - Export VM into reusable Vagrant .box"
	@echo "  make ova       - Export VM into VirtualBox .ova file"
	@echo "  make clean     - Stop VM, destroy state, and wipe build files"

init:
	@chmod +x scripts/install_deps.sh
	@./scripts/install_deps.sh
	@chmod +x scripts/install_docker_rootless.sh 
	@./scripts/install_docker_rootless.sh
	@chmod +x scripts/missing-files.sh
	@./scripts/missing-files.sh

up:
	@echo "==> Starting Virtual Machine..."
	@vagrant up

ssh:
	@vagrant ssh

ssh2:
	@echo "==> Connecting to $(TAILSCALE_HOST) via Tailscale..."
	@ssh \
		-i "$(SSH_KEY)" \
		-o ProxyCommand="nc -X 5 -x $(TAILSCALE_PROXY) %h %p" \
		$(SSH_USER)@$(TAILSCALE_HOST)

pass:
	@chmod +x scripts/get_password.sh
	@./scripts/get_password.sh

status:
	@vagrant status

halt:
	@echo "==> Stopping Virtual Machine..."
	@vagrant halt

reload:
	@echo "==> Reloading Virtual Machine..."
	@vagrant reload

provision:
	@echo "==> Re-running setup script..."
	@vagrant provision

vbox:
	@chmod +x scripts/export_vbox.sh
	@./scripts/export_vbox.sh $(VM_NAME)

ova:
	@chmod +x scripts/export_ova.sh
	@./scripts/export_ova.sh $(VM_NAME)

proxy-up:
	@./scripts/proxy.sh up

proxy-down:
	@./scripts/proxy.sh down

open-gitlab:
	@./scripts/proxy.sh open

deploy:
	@echo "==> Connecting VM to Tailscale..."
	@vagrant ssh -c "sudo tailscale up"

clean:
	@echo "==> Stopping and destroying Vagrant VM..."
	@vagrant halt 2>/dev/null || true
	@vagrant destroy -f 2>/dev/null || true
	@echo "==> Removing temporary build artifacts and exports..."
	@rm -rf *.box *.ova .vagrant/
	@echo "==> Host workspace cleaned."