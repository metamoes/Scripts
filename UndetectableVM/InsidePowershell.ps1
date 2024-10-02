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
    
    try {
        if (!(Test-Path $Path)) {
            New-Item -Path $Path -Force | Out-Null
        }
        New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        return $true
    } catch {
        Write-Host "Error setting registry value: $Path\$Name"
        return $false
    }
}

# Initialize success flag
$allSuccessful = $true

# Set system manufacturer
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemManufacturer" -Value "Dell Inc.")

# Set system model
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "SystemProductName" -Value "Inspiron 15 7000")

# Set BIOS version
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSVersion" -Value "2.17.1246")

# Set BIOS release date
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\BIOS" -Name "BIOSReleaseDate" -Value "04/01/2022")

# Set processor name
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "ProcessorNameString" -Value "Intel(R) Core(TM) i7-10750H CPU @ 2.60GHz")

# Set hard drive serial number
$serialNumber = -join ((48..57) + (65..90) | Get-Random -Count 10 | ForEach-Object {[char]$_})
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\HARDWARE\DEVICEMAP\Scsi\Scsi Port 0\Scsi Bus 0\Target Id 0\Logical Unit Id 0" -Name "SerialNumber" -Value "WD-$serialNumber")

# Disable Hyper-V detection
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\HyperV" -Name "HyperVisorLoadOptions" -Value 1 -Type "DWord")

# Remove VirtualBox Guest Additions if present
if (Test-Path "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions") {
    try {
        Remove-Item -Path "HKLM:\SOFTWARE\Oracle\VirtualBox Guest Additions" -Recurse
        Write-Host "Removed VirtualBox Guest Additions registry entries."
    } catch {
        Write-Host "Failed to remove VirtualBox Guest Additions registry entries."
        $allSuccessful = $false
    }
}

# Remove VMware Tools if present
if (Test-Path "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools") {
    try {
        Remove-Item -Path "HKLM:\SOFTWARE\VMware, Inc.\VMware Tools" -Recurse
        Write-Host "Removed VMware Tools registry entries."
    } catch {
        Write-Host "Failed to remove VMware Tools registry entries."
        $allSuccessful = $false
    }
}

# Disable Windows Hyper-V detection
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -Type "DWord")

# Disable Time Synchronization
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" -Name "Type" -Value "NoSync")

# Modify reported physical memory to a realistic value (e.g., 16 GB)
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor\0" -Name "~MHz" -Value 2600 -Type "DWord")

# Disable features typically associated with VMs
$services = @("vmicheartbeat", "vmicvss", "vmicshutdown", "vmicexchange", "vmicrdv", "vmictimesync", "vmickvpexchange")
foreach ($service in $services) {
    try {
        Set-Service -Name $service -StartupType Disabled
        Stop-Service -Name $service -Force -ErrorAction Stop
    } catch {
        Write-Host "Failed to disable service: $service"
        $allSuccessful = $false
    }
}

# Disable synthetic timing for Hyper-V (if it exists)
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Services\TSC" -Name "Start" -Value 4 -Type "DWord")

# Enable invariant TSC
$allSuccessful = $allSuccessful -and (Set-RegistryValue -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" -Name "GlobalTimerResolutionRequests" -Value 1 -Type "DWord")

# Disable Windows Time service
$service = Get-Service -Name "W32Time" -ErrorAction SilentlyContinue
if ($service) {
    try {
        Stop-Service -Name "W32Time" -Force
        Set-Service -Name "W32Time" -StartupType Disabled
    } catch {
        Write-Host "Failed to disable Windows Time service."
        $allSuccessful = $false
    }
}

# Create a dialog box to show the result
Add-Type -AssemblyName System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = "VM Modification Result"
$form.Size = New-Object System.Drawing.Size(300,150)
$form.StartPosition = "CenterScreen"

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,60)
$label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

if ($allSuccessful) {
    $label.Text = "All modifications were successful!"
    $form.BackColor = [System.Drawing.Color]::LightGreen
} else {
    $label.Text = "Some modifications failed. Check the console for details."
    $form.BackColor = [System.Drawing.Color]::LightCoral
}

$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(100,80)
$okButton.Size = New-Object System.Drawing.Size(75,23)
$okButton.Text = "OK"
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $okButton

$form.Controls.Add($label)
$form.Controls.Add($okButton)

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    # Prompt for restart
    $restart = Read-Host "Do you want to restart the computer now to apply all changes? (y/n)"
    if ($restart -eq 'y') {
        Restart-Computer -Force
    }
}
