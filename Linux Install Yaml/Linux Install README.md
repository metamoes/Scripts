# Linux Development Environment Setup

This playbook will install and configure the following:

1. **System Tools**:
   - apt-file (for managing APT packages)
   - python3-pip

2. **Web Browsers**:
   - Firefox

3. **Communication Tools**:
   - Discord
   - Thunderbird (email client)

4. **Gaming**:
   - Steam

5. **Email Client**:
   - BlueMail

6. **Graphics and CUDA**:
   - NVIDIA GPU drivers
   - NVIDIA CUDA toolkit

7. **Development Tools**:
   - JetBrains Toolbox
   - CLion
   - PyCharm Professional
   - IntelliJ IDEA Ultimate

8. **File Synchronization**:
   - Synology Drive

9. **Music Streaming**:
   - Spotify

## Usage

1. Save the playbook as `linux-install.yml`
2. Open a terminal and navigate to the directory containing the playbook
3. Run the following command:
   ```
   ansible-playbook linux-install.yml
   ```

Note: This playbook requires sudo privileges to install software and make system changes.
