# Windows VM Replication Script

This Python script modifies a QCOW2 file and libvirt XML configuration to create a virtual machine that closely resembles a physical Windows machine. It's designed for educational and testing purposes, allowing users to simulate a real machine environment within a virtual setting.

## ⚠️ Disclaimer

This script is intended for **educational and legitimate testing purposes only**. Creating exact replicas of existing machines, especially with specific hardware IDs, can raise ethical and legal concerns. Ensure you have the necessary rights and permissions before using this script. The authors and contributors are not responsible for any misuse or legal issues arising from the use of this script.

## Features

- Configures a 6-core CPU with virtualization features
- Sets up a 128GB virtual hard drive
- Adds realistic hardware IDs and SMBIOS information
- Includes TPM 2.0 device emulation
- Configures sound device and USB controllers
- Adds a network interface with a realistic MAC address

## Prerequisites

- Python 3.6+
- libvirt
- qemu-img
- Appropriate permissions to modify VM configurations

## Usage

1. Ensure you have the necessary permissions and have backed up any important data.
2. Modify the script to set the correct path to your QCOW2 image and adjust any hardware details as needed.
3. Run the script:

   ```
   python vm_replication_script.py
   ```

4. The script will modify the QCOW2 file and update the libvirt XML configuration.

## Configuration Details

The script performs the following modifications:

- CPU: Configures a 6-core CPU with virtualization features (VMX/SVM)
- Storage: Resizes the QCOW2 image to 128GB and sets up a SATA drive
- SMBIOS: Adds realistic BIOS and system information
- Devices: Includes TPM 2.0, sound, USB, and network devices

## Customization

You can customize various aspects of the VM configuration by modifying the script:

- Change CPU cores, features, or topology
- Adjust storage size or type
- Modify SMBIOS information to match specific hardware
- Add or remove devices as needed

## Limitations

- This script does not replicate the actual content or software of a physical machine
- Some applications or Windows features may still detect that they're running in a virtual environment
- The effectiveness of hardware ID replication may vary depending on the specific use case

## Contributing

Contributions to improve the script or documentation are welcome. Please ensure that any contributions maintain the educational and ethical focus of this project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

