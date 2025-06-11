# Ansible Lab with Docker & Docker Compose

Spin up a lightweight local Ansible lab using Docker and Docker Compose — no
VMs, no cloud, just containers.

## Features

- 1x Control node with Ansible installed
- 2x Managed nodes with SSH access
- Uses Docker's internal networking for clean communication
- One-command bootstrap using `make`

## Requirements

- Docker
- Docker Compose
- `make`

## Usage

Clone the repo, then:

```bash
make
```

### Available Commands

```bash
make up           # Start containers
make bootstrap    # Install Ansible, generate SSH keys, copy keys
make ping         # Run 'ansible -m ping' to verify connectivity
make ssh          # Enter control node shell
make down         # Stop all containers
make clean        # Full cleanup including SSH keys
```

## Example Ansible Test

```bash
ansible -i inventory.ini all -m ping
```

Expected output:

```text
ansible_node1 | SUCCESS => {...}
ansible_node2 | SUCCESS => {...}
```

## Notes

- Containers communicate via Docker internal DNS (`ansible_node1`, `ansible_node2`).
- SSH key auth is set up automatically via `ssh-copy-id` from the control node.
- Managed nodes use the `root` user with password `root`.

## FAQ

**Q: Why not use localhost and mapped ports?**  
A: Inside Docker, `localhost` refers to the container itself. We connect via
container names using Docker’s internal DNS.

**Q: Can I add more managed nodes?**  
A: Yep — just duplicate one of the `node` services in `docker-compose.yml`,
expose a new port, and update `Makefile` + `inventory.ini`.

---

### When You're Done

```bash
make clean   # Removes SSH keys from control node and stops the containers
make down    # Stop containers
```

---

Happy automating!
