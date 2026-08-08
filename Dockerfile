FROM tailscale/tailscale:latest

RUN apk add --no-cache \
    ansible \
    bash \
    git \
    make \
    openssh-client \
    netcat-openbsd \
    python3 \
    py3-pip

WORKDIR /workspace
ENV ANSIBLE_CONFIG=/workspace/ansible/ansible.cfg

COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

CMD ["sleep", "infinity"]