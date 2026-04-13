# Convert-WindowsImage
Creates a Windows VM for Hyper-V from a Windows-ISO

Forked and updated from https://github.com/x0nn/Convert-WindowsImage to support PowerShell Core 7.6 and later

# Release 25H2
Currently **tested**:
- Windows 11 / all versions 25H2 in UEFI

BIOS-DiskLayout
- It should work for all versions from Windows 7 up to 11. 

VM's run on Hyper-V (DiskLayout: BIOS uses Gen1-VM, UEFI uses Gen2-VM)

# REQUIRED: PowerShell 7.x (Core)
This script requires PowerShell Core 7.0 or later
It requires running as Adminstrator

## Examples

1. Dotsource the script to load the functions
   
`. .\Convert-WindowsImage.ps1`

2. Create a Windows 11 Pro VM

`Convert-WindowsImage -SourcePath "C:\ISO\en-us_windows_11_consumer_editions_version_25h2_updated_march_2026_x64_dvd_a1cf6c36.iso" -VHDFormat "VHDX" -Edition 6 -SizeBytes 50GB -DiskLayout "UEFI" -VHDPath "C:\VHD\Template\Win11_25H2.vhdx"`
					
If you don't know the Edition, use -Edition "LIST" and the function will fail, but *list all editions in the ISO/WIM-file*.

## Bugs

If you change the script for debugging remember to reload the functions
   
`. .\Convert-WindowsImage.ps1`

Please open an issue on github, when you found a bug. Run the script with "-Debug" and "-Verbose" options and a Transcript, like:

```
Start-Transcript
Convert-WindowsImage -.... -Debug -Verbose
Stop-Transcript
```

Please attach/post the transcript to the issue.

You've guessed it, PR's are welcome.

## Requirements

The script requires:
- **PowerShell 7.4 or later** (PowerShell Core)
- Windows Host (lowest is Windows 8, but Windows 10 or later is recommended) with
- **Administrator rights**

Note: This is a Windows-only script and cannot run on Linux or macOS.

## License

The code is licensed under the GPLv3-License since version 21H2.
The code **was** licensed under the MIT licencse (X11) before version 21H1 as per the original source this implementation is based upon. See `LICENSE` for details.
