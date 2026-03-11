# developer-mac-setup
Ansible scripts to set up mac for a developer

## Prerequisites

Ansible must be installed on your Mac before running any playbook.
Use the provided helper script to install it:

```bash
bash install-ansible.sh
```

The script will:
1. Check for / install **Xcode Command Line Tools**
2. Check for / install **Homebrew**
3. Check for / install **Python 3** (via Homebrew)
4. Check for / install **pipx** (via Homebrew)
5. Install **Ansible** in an isolated environment via `pipx`

## Usage

After Ansible is installed, run the desired playbook:

```bash
ansible-playbook enhanced-developer-arduino.yml -K
```

`-K` prompts for your sudo password, which is required for a small number of tasks (e.g. changing the default shell).
