
#!/bin/bash

if [ ! -d "ansible-venv" ]; then
    python3 -m venv ansible-venv
fi

source ansible-venv/bin/activate

if pip list | grep -q -i "^ansible"; then
    echo "Ansible is already installed."
    return 0 2>/dev/null || exit 0
else
    echo "Ansible is not installed. Installation in progress..."
    python3 -m pip install --upgrade pip
    pip install ansible
fi
