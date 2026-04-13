# Define variables
$VMName = Read-Host -Prompt "Enter VM Name"
$TemplateDiskPath = "C:\VHD\Template\Win11_23H2v2.vhdx"
$DiffDiskPath = "C:\VHD\$($VMName).vhdx"

If (Test-Path -Path $DiffDiskPath) {
    Write-Warning "VM with this name already exists. Choose another name or delete the existing."
    Exit 1
}

$SwitchName = "ExternalSwitch"

# Create the differencing disk
New-VHD -Path $DiffDiskPath -ParentPath $TemplateDiskPath -Differencing

# Create the VM
New-VM -Name $VMName -MemoryStartupBytes 4GB -Generation 2 -VHDPath $DiffDiskPath -SwitchName $SwitchName

# Enable Secure Boot
Set-VMFirmware -VMName $VMName -EnableSecureBoot On

Try {
    Enable-VMTPM -VMName $VMName -ErrorAction Stop
} Catch {
    # Create a new guardian
    New-HgsGuardian -Name "MyGuardian" -GenerateCertificates
    # Create and set the key protector
    $Owner = Get-HgsGuardian -Name "MyGuardian"
    $KeyProtector = New-HgsKeyProtector -Owner $Owner -AllowUntrustedRoot
    Set-VMKeyProtector -VMName $VMName -KeyProtector $KeyProtector.RawData
    # Enable TPM
    Enable-VMTPM -VMName $VMName
}

# Start the VM
Start-VM -Name $VMName
