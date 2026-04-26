# Homelab

Ansible + Terraform config for a bare-metal Ubuntu Server 26.04 homelab.

## Stack

- **OS:** Ubuntu Server 26.04 LTS
- **Docker management:** [Dockhand](https://dockhand.pro/manual/)
- **Server admin:** [Cockpit](https://cockpit-project.org/)
- **Remote access:** [Tailscale](https://tailscale.com/)
- **Reverse proxy:** [Caddy](https://caddyserver.com/) with Cloudflare DNS
- **External access:** Cloudflare Zero Trust Tunnel
- **Provisioning:** Ansible
- **Infrastructure:** Terraform (Cloudflare + Tailscale)

## Nodes

| Name | Role | Status |
|------|------|--------|
| odin | Primary | Active |
| thor | Secondary | Planned |

## Prerequisites

- Ansible installed on your local machine
- SSH access to the target server (password auth for first run)

```bash
# Install required Ansible collections
ansible-galaxy collection install -r requirements.yml
```

## Usage

Update `inventory/hosts.yml` with your server's IP, then:

```bash
# Full provision (all playbooks in order)
ansible-playbook site.yml

# Or run individual playbooks
ansible-playbook playbooks/bootstrap.yml
ansible-playbook playbooks/docker.yml
ansible-playbook playbooks/cockpit.yml
ansible-playbook playbooks/tailscale.yml
ansible-playbook playbooks/dockhand.yml
```

The first run will prompt for SSH and sudo passwords (`ansible.cfg` has `ask_pass` and `become_ask_pass` enabled).

## Terraform

Cloudflare DNS, Zero Trust tunnel, and access policies are managed in `infra/`.

```bash
cd infra
terraform init
terraform plan
terraform apply
```

Requires a `terraform.tfvars` file (gitignored) with Cloudflare and Tailscale credentials.

## Disk Layout

Configured manually during/after OS install — not managed by Ansible.

```
256 GB NVMe SSD (/dev/nvme0n1)
  VG: ubuntu-vg
  └── ubuntu-lv  100 GB  → /            (OS, packages, configs, Dockhand data)
  └── ~135 GB free                       (reserve for future OS needs)

1 TB NVMe SSD (/dev/nvme1n1)
  VG: data
  ├── docker LV   200 GB  → /var/lib/docker  (images, layers, build cache)
  ├── gamedata LV  500 GB  → /gamedata        (game server data)
  └── ~230 GB free                            (future use)
```

To recreate the 1 TB layout from scratch:

```bash
sudo pvcreate /dev/nvme1n1
sudo vgcreate data /dev/nvme1n1
sudo lvcreate -L 200G -n docker data
sudo lvcreate -L 500G -n gamedata data
sudo mkfs.ext4 /dev/data/docker
sudo mkfs.ext4 /dev/data/gamedata
sudo mkdir -p /gamedata
sudo mount /dev/data/gamedata /gamedata
sudo chown lance:lance /gamedata
# Add to /etc/fstab:
#   /dev/data/docker   /var/lib/docker ext4 defaults 0 2
#   /dev/data/gamedata /gamedata       ext4 defaults 0 2
```

## Project Structure

```
homelab/
├── ansible.cfg
├── site.yml
├── requirements.yml
├── inventory/
│   ├── hosts.yml
│   └── group_vars/all.yml
├── playbooks/
│   ├── bootstrap.yml
│   ├── docker.yml
│   ├── cockpit.yml
│   ├── tailscale.yml
│   └── dockhand.yml
├── stacks/              # Docker compose stacks (deployed via Dockhand)
└── infra/               # Terraform (Cloudflare + Tailscale)
```
