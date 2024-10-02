# Ensure the script is run with administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))  
{  
    Write-Host "This script needs to be run as an Administrator. Restarting with elevated privileges..."
    Start-Process powershell -Verb RunAs -ArgumentList ("-File", $MyInvocation.MyCommand.Path)
    Exit
}

# Function to set registry values
function Set-RegistryValue {
    param (
        [string]$Path,
        [string]$Name,
        [string]$Value,
        [string]$Type = "String"
    )
    
    if (!(Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force
}

# Generate a realistic serial number
function Get-RandomSerialNumber {
    $chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    return -join ((1..10) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

# Set system manufacturer
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemManufacturer" -Value "Dell Inc."

# Set system model
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemProductName" -Value "Inspiron 15 7000"

# Set BIOS version
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVersion" -Value "2.17.1246"

# Set BIOS release date
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSReleaseDate" -Value "04/01/2022"

# Set processor name (adjust as needed)
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "ProcessorNameString" -Value "Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz"

# Set hard drive serial number
$serialNumber = Get-RandomSerialNumber
Set-RegistryValue -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "SerialNumber" -Value "WD-$serialNumber"

# Disable Hyper-V detection
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\HyperV" -Name "HyperVisorLoadOptions" -Value 1 -Type "DWord"

# Remove VirtualBox Guest Additions if present
if (Test-Path "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions") {
    Remove-Item -Path "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions" -Recurse
    Write-Host "Removed VirtualBox Guest Additions registry entries."
}

# Remove VMware Tools if present
if (Test-Path "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools") {
    Remove-Item -Path "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools" -Recurse
    Write-Host "Removed VMware Tools registry entries."
}

# Disable Windows Hyper-V detection
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -Type "DWord"

# Disable Time Synchronization (often used by VMs)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Value "NoSync"

# Modify reported physical memory to a realistic value (e.g., 16 GB)
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "~MHz" -Value 2600 -Type "DWord"

# Set a realistic MAC address
$macAddress = "52-54-00-" + (1..3 | ForEach-Object { "{0:X2}" -f (Get-Random -Minimum 0 -Maximum 255) }) -join '-'
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0001" -Name "NetworkAddress" -Value $macAddress

# Disable features typically associated with VMs
$services = @("vmicheartbeat", "vmicvss", "vmicshutdown", "vmicexchange", "vmicrdv", "vmictimesync", "vmickvpexchange")
foreach ($service in $services) {
    Set-Service -Name $service -StartupType Disabled
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

Write-Host "Registry modifications and system changes completed successfully."
Write-Host "Some changes may require a system restart to take effect."
Write-Host "Generated Serial Number: WD-$serialNumber"
Write-Host "Generated MAC Address: $macAddress"

# Prompt for restart
$restart = Read-Host "Do you want to restart the computer now to apply all changes? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer -Force
}
