# o6s Ansible Installation Playbooks

## Scope

Ansible playbooks to:

- Configure a host (or virtual machine) to become an Oracle Database server
- Download and install Oracle Database 26ai Free
- Add key supporting tools such as Oracle SQL Developer Command Line (SQLcl)
- Create the Oracle listener and database
- Provision a pluggable database (PDB) for Oracle APEX
- Download and install the latest version of Oracle APEX into the PDB
- Download, install, and secure (with a self-signed certificate) Apache Tomcat 9.x
- Download, install, and configure the latest version of Oracle REST Data Services (ORDS)
- Install and configure Nginx
- Install and configure Prometheus
- Install and configure Clickhouse database
- Install and configure Grafana

## Installed Software Inventory

Tested for compatibility against the following operating systems:

| Component          | Release      |
| :----------------- | :----------- |
| Linux Distribution | Oracle Linux |
|                    | RHEL         |
|                    | Rocky Linux  |
| Linux Version      | 8.10         |
|                    | 9.7          |

Latest compatibility tested SBOM:

| Component                        | Release                      |
| :------------------------------- | :--------------------------- |
| Oracle Database Base Version     | 26ai FREE (23.26.1.0.0)      |
| Oracle Database Patch Version    | <not applicable for 23 FREE> |
| APEX Base Version                | 24.2                         |
| APEX Patch Set Bundle            | 14                           |
| Oracle REST Data Services (ORDS) | 25.4.0.r3641739              |
| SQLcl                            | 25.4.2.044.1837              |
| Apache Tomcat                    | 9.0.115                      |
| PLSQL Logger                     | 3.1.1                        |
| utPLSQL                          | v3.1.14.4197                 |
| Nginx                            | Latest                       |
| Prometheus                       | v3.10.0.                     |
| Clickhouse                       | v25.8.16.34                  |
| Grafana                          | v12.4.0                      |

## Target Server Prerequisites

- Oracle Linux 8.6 or higher (either Red Hat Compatible Kernel or UEK)
- At least 2.5GB of memory (up to 4GB, if possible, is recommended)
- Internet egress (required to download the required software and packages - can be revoked after install)

## Ansible Playbook Overview

### Example Inventory File

```
#  Environment tiers:
[sandbox:children]
apex_group
reporting_group

#  Role groups:
[apex_group]
ol8-ora23aiFree-MBP main_user=spane ansible_host=localhost ansible_port=2200 ansible_user=simon
```

### Required Variables

| Parameter Name | Parameter Purpose                           | Default        |
| :------------- | :------------------------------------------ | :------------- |
| main_user      | The main user for APEX and database access. | Playbook fails |

### APEX Patching

APEX patches can be applied using the separate playbook `patch_apex_playbook.yml`. Currently, the patch file must be manually downloaded from [My Oracle Support](https://support.oracle.com/) and staged in `/tmp` on each target server.

## Usage

Provide the name of the inventory file to use using the `-i`, `--inventory` or `--inventory-file` option.

Provide the `main_user` value as either an extra variable on the command line or within the inventory file.

### Self-install Prerequisites

Self-installation (where the Ansible Control Node and Managed Hosts are the same) is generally not recommended but is possible.

> **IMPORTANT:** Installation will kill itself upon server reboot Ansible handlers (likely a few times over) but is restartable (idempotent).

After downloading or cloning this repo, install:

```bash
sudo dnf install -y epel-release
sudo dnf install -y \
  git \
  ansible-core \
  python3.12

ansible-galaxy collection install -r requirements.yml --force
```

Also ensure an ssh loopback works - example setup:

```bash
cd ~/.ssh
ssh-keygen -q -b 4096 -t rsa -N "" -f ~/.ssh/id_rsa
cat id_rsa.pub >> authorized_keys

# Test:
ssh $(whoami)@localhost date
```

For a loopback, the Ansible inventory file should include something similar to:

```bash
[apex_group]
localhost main_user=spane ansible_host=localhost ansible_port=22 ansible_user=opc
```

### Common Customizations

Review/consider adjusting certain settings using syntax similar to:

```bash
sed -i 's/simon.pane.2/pane/' roles/common/vars/main.yml
sed -i 's/shaw.ca/pythian.com/' roles/common/vars/main.yml
sed -i 's/Edmonton/Toronto/' roles/common/defaults/main.yml
sed -i 's/Edmonton/Toronto/' roles/common/vars/main.yml
sed -i 's/sdbs/pythian/' roles/common/defaults/main.yml
```

### Sample Invocations

To prepare the server, install the Oracle Database software, and create the database:

```bash
ansible-playbook install_oracle_playbook.yml -i ./inventory.personal --limit "apex_group"
```

> NOTE: the `main_user` is not required for this playbook as no users are created by these tasks.

To install Oracle APEX, Apache Tomcat v9.x, and configure ORDS with initial user `spane`:

```bash
ansible-playbook install_apex_playbook.yml -i ./inventory.personal --limit "apex_group" -e "main_user=spane"
```

Running the APEX patching playbook:

```bash
ansible-playbook patch_apex_playbook.yml -i ./inventory.personal --limit "apex_group"
```

Example: Install & Configure Oracle Database, Apex, Tomcat at once:

```bash
ansible-playbook install_oracle_playbook.yml -i ./inventory.personal --limit "apex_group" && \
ansible-playbook install_apex_playbook.yml   -i ./inventory.personal --limit "apex_group" && \
ansible-playbook install_site_playbook.yml   -i ./inventory.personal --limit "apex_group" && \
ansible-playbook install_apps_playbook.yml   -i ./inventory.personal --limit "apex_group"

ansible-playbook patch_apex_playbook.yml -i ./inventory.personal --limit "apex_group"
```

Or:

```bash
ansible-playbook install_oracle_playbook.yml -i ./inventory.linux --limit "apex_group" && \
ansible-playbook install_apex_playbook.yml   -i ./inventory.linux --limit "apex_group" && \
ansible-playbook install_site_playbook.yml   -i ./inventory.linux --limit "apex_group" && \
ansible-playbook install_apps_playbook.yml   -i ./inventory.linux --limit "apex_group"

ansible-playbook patch_apex_playbook.yml -i ./inventory.linux --limit "apex_group"
```
### Sample Invocations for tools

Example: Install Nginx:

```bash
ansible-playbook install_nginx.yml -i ./inventory.linux --ask-vault-pass
```

Example: Install Prometheus:

```bash
ansible-playbook install_prometheus.yml -i ./inventory.linux --ask-vault-pass
```

Example: Install Clickhouse:

```bash
ansible-playbook install_clickhouse.yml -i ./inventory.linux --ask-vault-pass
```

Example: Install Grafana:

```bash
ansible-playbook install_grafana.yml -i ./inventory.linux --ask-vault-pass
```

Example: Install & configure Nginx, Prometheus, Clickhouse and Grafana at once:

```bash
ansible-playbook install_all_tools.yml -i ./inventory.linux --ask-vault-pass
```

### Use of Ansible-Vault for tools

Ansible vault is used to encrypt credentials for Prometheus, Clickhouse and Grafana. These variables are stored in ansible-vault encrypted file named `vault.yml`, hence the use of `--ask-vault-pass` while running the tools playbooks.