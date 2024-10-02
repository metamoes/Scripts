# Key components of the PowerShell script:

# 1. Set system manufacturer
# 2. Set system model
# 3. Set BIOS version and release date
# 4. Set processor name
# 5. Set hard drive serial number
# 6. Disable Hyper-V detection
# 7. Remove VirtualBox Guest Additions and VMware Tools registry entries
# 8. Disable Windows Hyper-V detection
# 9. Disable Time Synchronization
# 10. Modify reported physical memory
# 11. Set a realistic MAC address
# 12. Disable features typically associated with VMs
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

# Set system manufacturer
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemManufacturer" -Value "Dell Inc."

# Set system model
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemProductName" -Value "Inspiron 15 7000"

# Set BIOS version
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVersion" -Value "2.17.1246"

# Set BIOS release date
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSReleaseDate" -Value "04/01/2022"

# Set processor name
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "ProcessorNameString" -Value "Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz"

# Set hard drive serial number
$serialNumber = -join ((48..57) + (65..90) | Get-Random -Count 10 | ForEach-Object {[char]$_})
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

# Disable Time Synchronization
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Value "NoSync"

# Modify reported physical memory to a realistic value (e.g., 16 GB)
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "~MHz" -Value 2600 -Type "DWord"

# Disable features typically associated with VMs
$services = @("vmicheartbeat", "vmicvss", "vmicshutdown", "vmicexchange", "vmicrdv", "vmictimesync", "vmickvpexchange")
foreach ($service in $services) {
    Set-Service -Name $service -StartupType Disabled
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
}

# Disable synthetic timing for Hyper-V (if it exists)
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TSC" -Name "Start" -Value 4 -Type "DWord"

# Enable invariant TSC
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type "DWord"

# Disable Hyper-V specific time synchronization
$service = Get-Service -Name "vmictimesync" -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name "vmictimesync" -Force
    Set-Service -Name "vmictimesync" -StartupType Disabled
}

# Disable Windows Time service
$service = Get-Service -Name "W32Time" -ErrorAction SilentlyContinue
if ($service) {
    Stop-Service -Name "W32Time" -Force
    Set-Service -Name "W32Time" -StartupType Disabled
}

# Set USB controller information
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_8086&PID_1E31" -Name "DeviceDesc" -Value "USB 2.0 eXtensible Host Controller"
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\VID_1912&PID_0014" -Name "DeviceDesc" -Value "USB 3.0 eXtensible Host Controller"

# Set TPM information (if applicable)
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "TPMPresent" -Value 1 -Type "DWord"
Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "TPMVersion" -Value "1.2" -Type "String"

# Set sound device information
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0000" -Name "DeviceDesc" -Value "High Definition Audio Device"
Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e96c-e325-11ce-bfc1-08002be10318}\0000" -Name "DriverDesc" -Value "Realtek High Definition Audio"

Write-Host "Registry modifications and system changes completed successfully."
Write-Host "Some changes may require a system restart to take effect."

# Prompt for restart
$restart = Read-Host "Do you want to restart the computer now to apply all changes? (y/n)"
if ($restart -eq 'y') {
    Restart-Computer -Force
}
