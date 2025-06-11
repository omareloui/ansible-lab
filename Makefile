PORTS = 2222 2223
NODES = ansible_node1 ansible_node2

.PHONY: all up down bootstrap ssh ping clean

all: up bootstrap

up:
	@echo "[+] Starting containers..."
	docker compose up -d

down:
	@echo "[+] Stopping containers..."
	docker compose down

bootstrap: wait-for-ssh install-ansible gen-keys copy-keys

wait-for-ssh:
	@echo "[+] Waiting for SSH to be ready on all managed nodes..."
	@for port in $(PORTS); do \
		echo -n "  - Waiting on localhost:$$port"; \
		until nc -z localhost $$port; do \
			echo -n "."; \
			sleep 1; \
		done; \
		echo " OK"; \
	done

install-ansible:
	@echo "[+] Installing Ansible and tools in control node..."
	docker exec ansible_control bash -c "apt update && apt install -y ansible openssh-client sshpass"

gen-keys:
	@echo "[+] Generating SSH keypair in control node..."
	docker exec ansible_control bash -c "test -f ~/.ssh/id_rsa || ssh-keygen -t rsa -f ~/.ssh/id_rsa -q -N ''"

copy-keys:
	@echo "[+] Copying SSH key to managed nodes..."
	@for node in $(NODES); do \
		docker exec ansible_control bash -c "sshpass -p 'root' ssh-copy-id -o StrictHostKeyChecking=no root@$$node"; \
	done

ssh:
	@docker exec -it ansible_control bash

ping:
	@docker exec -it ansible_control bash -c "ansible -i inventory.ini all -m ping"

clean:
	@echo "[+] Cleaning up SSH keys..."
	-@docker exec ansible_control bash -c "rm -f ~/.ssh/id_rsa ~/.ssh/id_rsa.pub" || echo "Control container not running — skipping key cleanup"
	@docker compose down --volumes --remove-orphans
