# Metamoes' Script Collection

Welcome to Metamoes' Script Collection repository. This repository contains a variety of scripts and configurations for different purposes, ranging from system setup to network configurations.

## Repository Contents

### 1. Linux System Setup Playbook

An Ansible playbook for setting up a Linux system with various tools and applications.

**Key Features**:
- System Tools installation (e.g., apt-file, python-pip3)
- Web Browsers (Firefox)
- Communication Tools (Discord)
- Gaming (Steam)
- Email Client (Thunderbird)
- Graphics and CUDA setup
- Development Tools (JetBrains suite)
- File Synchronization (Synology Drive)
- Music Streaming (Spotify)

**Usage**:
1. Save the playbook as `linux-install.yml`
2. Run the command: `ansible-playbook linux-install.yml`

### 2. Pi-hole with Unbound Docker Compose Configuration

A Docker Compose configuration for setting up Pi-hole with Unbound DNS resolver.

**Key Features**:
- Network-wide ad blocking
- Recursive DNS resolver
- Customizable web interface
- Optional SSH access
- Configurable reverse DNS

**Usage with Portainer**:
1. In Portainer, go to "Stacks" and click "Add stack"
2. Paste the Docker Compose YAML into the web editor
3. Set environment variables
4. Deploy the stack

## General Usage

Each script or configuration in this repository comes with its own specific instructions. Please refer to the individual README files or comments within the scripts for detailed usage guidelines.

## Customization

Most scripts and configurations in this repository can be customized to fit your specific needs. Look for environment variables, configuration files, or commented sections that allow for personalization.

## Security Reminders

- Always change default passwords (e.g., WEBPASSWORD in Pi-hole configuration) to strong, unique passwords before deployment.
- Verify network settings and ports to ensure they match your infrastructure and security requirements.
- Keep your systems and installed software up to date.

## Contributions

This repository is maintained by Metamoes. If you have suggestions, improvements, or bug reports, please open an issue or submit a pull request.

## Disclaimer

These scripts and configurations are provided as-is. Always review and understand any script or configuration before running it on your system. Metamoes is not responsible for any damages or issues that may arise from the use of these scripts.
