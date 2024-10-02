import libvirt
import xml.etree.ElementTree as ET
import subprocess
import random
import uuid

# Connect to libvirt
conn = libvirt.open('qemu:///system')

# Define the VM image path
image_path = '/var/lib/libvirt/images/Windows.qcow2'

# Create a domain object from the image
domain = conn.lookupByName('Windows')  # Assuming 'Windows' is the VM name

# Get the domain XML
xml = domain.XMLDesc(0)
root = ET.fromstring(xml)

# Modify CPU configuration
cpu = root.find('./cpu')
if cpu is None:
    cpu = ET.SubElement(root, 'cpu')
cpu.set('mode', 'host-passthrough')
cpu.set('check', 'partial')
cpu.set('migratable', 'on')

# Remove topology if it exists
topology = cpu.find('topology')
if topology is not None:
    cpu.remove(topology)

# Add CPU features
features = cpu.find('feature[@name="svm"]')
if features is None:
    features = ET.SubElement(cpu, 'feature')
    features.set('policy', 'require')
    features.set('name', 'svm')  # or 'svm' for AMD

# Modify hard drive configuration
devices = root.find('devices')
disk = devices.find("./disk[@device='disk']")
driver = disk.find('driver')
driver.set('type', 'qcow2')
driver.set('cache', 'none')
driver.set('io', 'native')
source = disk.find('source')
source.set('file', image_path)
target = disk.find('target')
target.set('bus', 'scsi')  # Changed from 'sata' to 'scsi'
target.set('dev', 'sda')

# Add SCSI controller if not present
scsi_controller = devices.find("./controller[@type='scsi'][@model='virtio-scsi']")
if scsi_controller is None:
    scsi_controller = ET.SubElement(devices, 'controller')
    scsi_controller.set('type', 'scsi')
    scsi_controller.set('model', 'virtio-scsi')

# Add realistic hardware IDs
def generate_serial():
    return ''.join(random.choices('0123456789ABCDEF', k=16))

serial_elem = disk.find('serial')
if serial_elem is None:
    serial_elem = ET.SubElement(disk, 'serial')
serial_elem.text = f"WD-{generate_serial()}"

vendor_elem = disk.find('vendor')
if vendor_elem is None:
    vendor_elem = ET.SubElement(disk, 'vendor')
vendor_elem.text = 'WDC'  # Shortened from 'Western Digital' to comply with 8-char limit

product_elem = disk.find('product')
if product_elem is None:
    product_elem = ET.SubElement(disk, 'product')
product_elem.text = 'WD1000DHTZ'  # Example WD model number

# Set disk size to 128GB
subprocess.run(['qemu-img', 'resize', image_path, '128G'])
# Add realistic hardware IDs
def generate_serial():
    return ''.join(random.choices('0123456789ABCDEF', k=16))

serial_elem = disk.find('serial')
if serial_elem is None:
    serial_elem = ET.SubElement(disk, 'serial')
serial_elem.text = f"WD-{generate_serial()}"

vendor_elem = disk.find('vendor')
if vendor_elem is None:
    vendor_elem = ET.SubElement(disk, 'vendor')
vendor_elem.text = 'WDC'  # Shortened from 'Western Digital' to comply with 8-char limit

product_elem = disk.find('product')
if product_elem is None:
    product_elem = ET.SubElement(disk, 'product')
product_elem.text = 'WD1000DHTZ'  # Example WD model number

# Add a realistic SMBIOS configuration
os = root.find('os')
smbios = ET.SubElement(os, 'smbios')
smbios.set('mode', 'host')

# Modify BIOS settings
os = root.find('os')
boot = ET.SubElement(os, 'boot')
boot.set('dev', 'hd')

# Add OVMF UEFI firmware (if not already present)
loader = os.find('loader')
if loader is None:
    loader = ET.SubElement(os, 'loader')
    loader.set('readonly', 'yes')
    loader.set('type', 'pflash')
    loader.text = '/usr/share/OVMF/OVMF_CODE.fd'
    nvram = ET.SubElement(os, 'nvram')
    nvram.text = '/var/lib/libvirt/qemu/nvram/Windows_VARS.fd'

# Configure TPM 1.2
tpm = devices.find('tpm')
if tpm is None:
    tpm = ET.SubElement(devices, 'tpm')
tpm.set('model', 'tpm-tis')
backend = tpm.find('backend')
if backend is None:
    backend = ET.SubElement(tpm, 'backend')
backend.set('type', 'passthrough')
backend.set('version', '1.2')

# Add a sound device
sound = ET.SubElement(devices, 'sound')
sound.set('model', 'ich9')

# Remove existing USB controllers
for usb_controller in devices.findall("./controller[@type='usb']"):
    devices.remove(usb_controller)

# Add USB 2.0 controller (EHCI)
usb2_controller = ET.SubElement(devices, 'controller')
usb2_controller.set('type', 'usb')
usb2_controller.set('model', 'ehci')
usb2_controller.set('index', '0')

# Add USB 3.0 controller (xHCI)
usb3_controller = ET.SubElement(devices, 'controller')
usb3_controller.set('type', 'usb')
usb3_controller.set('model', 'nec-xhci')
usb3_controller.set('index', '1')

# Remove any existing USB device passthroughs
for usb_device in devices.findall("./hostdev[@type='usb']"):
    devices.remove(usb_device)

# Add a network interface with a realistic MAC address
interface = ET.SubElement(devices, 'interface')
interface.set('type', 'network')
ET.SubElement(interface, 'source').set('network', 'default')
ET.SubElement(interface, 'model').set('type', 'virtio')
mac = ET.SubElement(interface, 'mac')
mac.set('address', f"52:54:00:{':'.join([f'{random.randint(0, 255):02x}' for _ in range(3)])}")

# Add tablet device for better mouse integration
tablet = ET.SubElement(devices, 'input')
tablet.set('type', 'tablet')
tablet.set('bus', 'usb')

# Enable Hyper-V enlightenments
features = root.find('features')
if features is None:
    features = ET.SubElement(root, 'features')
hyperv = features.find('hyperv')
if hyperv is None:
    hyperv = ET.SubElement(features, 'hyperv')
    ET.SubElement(hyperv, 'relaxed').set('state', 'on')
    ET.SubElement(hyperv, 'vapic').set('state', 'on')
    ET.SubElement(hyperv, 'spinlocks').set('state', 'on')
    ET.SubElement(hyperv, 'vpindex').set('state', 'on')
    ET.SubElement(hyperv, 'runtime').set('state', 'on')
    ET.SubElement(hyperv, 'synic').set('state', 'on')
    ET.SubElement(hyperv, 'stimer').set('state', 'on')
    ET.SubElement(hyperv, 'reset').set('state', 'on')
    ET.SubElement(hyperv, 'vendor_id').set('state', 'on')
    ET.SubElement(hyperv, 'frequencies').set('state', 'on')
    ET.SubElement(hyperv, 'reenlightenment').set('state', 'on')
    ET.SubElement(hyperv, 'tlbflush').set('state', 'on')
    ET.SubElement(hyperv, 'ipi').set('state', 'on')
    ET.SubElement(hyperv, 'evmcs').set('state', 'on')

# Save changes to the domain XML
new_xml = ET.tostring(root).decode()
conn.defineXML(new_xml)

# Close the connection
conn.close()

print("QCOW2 file and VM configuration updated successfully.")
