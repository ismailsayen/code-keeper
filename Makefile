# Executable names
VAGRANT = vagrant
ANSIBLE_PLAYBOOK = ansible-playbook
ANSIBLE_PING = ansible

# File paths
INVENTORY = ansible/hosts.ini
PLAYBOOK = ansible/playbook.yml

.PHONY: help up destroy halt provision status rebuild restart ping apply ssh

# Default target: display help
help:
	@echo "Usage: make [command]"
	@echo ""
	@echo "Available commands:"
	@echo "  make up        : Start and provision the VM(s)"
	@echo "  make halt      : Gracefully shut down the VM(s)"
	@echo "  make destroy   : Forcefully delete the VM(s) without confirmation"
	@echo "  make provision : Re-run provisioning scripts"
	@echo "  make rebuild   : Destroy and recreate the VM(s) from scratch"
	@echo "  make status    : Show current state of the VM(s)"
	@echo "  make ping      : Test SSH connection to the VM using Ansible ping"
	@echo "  make apply     : Run ansible-playbook directly from host machine"

up:
	@echo "🚀 Starting Vagrant environment..."
	$(VAGRANT) up

destroy:
	@echo "⚠️  Destroying virtual machine..."
	$(VAGRANT) destroy -f

halt:
	@echo "🛑 Stopping virtual machine..."
	$(VAGRANT) halt

provision:
	@echo "⚙️  Running provisioners..."
	$(VAGRANT) provision

status:
	$(VAGRANT) status

ssh:
	@echo "🔑 Connecting to the virtual machine via SSH..."
	$(VAGRANT) ssh

ping:
	@echo "📡 Testing Ansible SSH connectivity..."
	$(ANSIBLE_PING) all -i $(INVENTORY) -m ping

apply:
	@echo "🚀 Executing Ansible playbook on target VM..."
	$(ANSIBLE_PLAYBOOK) -i $(INVENTORY) $(PLAYBOOK) --ask-vault-pass

rebuild: destroy up

restart: halt up