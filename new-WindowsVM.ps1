# Define variables
$VMName = Read-Host -Prompt "Enter VM Name"

# Find the latest VHDX file in the template directory
$TemplateDir = "C:\VHD\Template"
$TemplateDiskPath = (Get-ChildItem -Path $TemplateDir -Filter "*.vhdx" | Sort-Object -Property LastWriteTime -Descending | Select-Object -First 1).FullName

if (-not $TemplateDiskPath) {
    Write-Error "No VHDX files found in $TemplateDir"
    Exit 1
}

Write-Host "Using template disk: $TemplateDiskPath"

$DiffDiskPath = "C:\VHD\$($VMName).vhdx"

If (Test-Path -Path $DiffDiskPath) {
    Write-Warning "VM with this name already exists. Choose another name or delete the existing."
    Exit 1
}

# Check for External Switch
$ExternalSwitch = Get-VMSwitch -SwitchType External -ErrorAction SilentlyContinue | Select-Object -First 1

if ($ExternalSwitch) {
    $SwitchName = $ExternalSwitch.Name
    Write-Host "Using existing external switch: $SwitchName"
} else {
    Write-Host "No external switch found. " -ForegroundColor Red
    # Note: Creating an external switch requires specifying a network adapter
    # This is typically done interactively. Manual setup may be required.
    Write-Warning "External switch creation requires a physical network adapter. Please ensure one is available or create the switch manually before proceeding." -ForegroundColor Yellow
    Exit 1
}

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
