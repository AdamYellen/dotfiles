#Requires -RunAsAdministrator

# NOTES:
# * This script is idempotent
# * This script does not require user input
# * Preconditions:
#   * Apps installed: winget

$SETUP_DEVICE_POWER_STARTUP = $True
$SETUP_POWERSHELL = $True
$SETUP_DEVELOPMENT = $True
$SETUP_WSL2 = $False

# Devices, Power, and Startup
if($SETUP_DEVICE_POWER_STARTUP)
{
    Write-Host "Configuring Devices, Power, and Startup..." -ForegroundColor "Green"

    # Power: Disable Hibernation
    powercfg /hibernate off

    # Power: Disable Sleep on AC Power
    powercfg /change /standby-timeout-ac 0

    # Power: Monitor sleep
    powercfg /change /monitor-timeout-ac 30
}

# PowerShell Console
if($SETUP_POWERSHELL)
{
    Write-Host "Configuring Console..." -ForegroundColor "Green"

    # Make 'Source Code Pro' an available Console font
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' 000 'Source Code Pro'
}

# Development
if($SETUP_DEVELOPMENT)
{
    Write-Host "Enable Development Settings..." -ForegroundColor "Green"

    # Enable Remote Desktop
    # Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
    # Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
    # Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Enable Developer Mode
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1

    # Enable long paths
    Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1

    # Setup Git
    # Squelch git 2.x warning message when pushing
    if(-not (git config --system push.default))
    {
        git config --system push.default simple
    }
    # Never modify line-endings
    git config --system core.autocrlf off
}

# WSL2
if($SETUP_WSL2)
{
    Write-Host "Installing Windows Subsystem for Linux..." -ForegroundColor "Green"
    wsl --install | Out-Null
}

# Home directory
Write-Host "Setup home directory..." -ForegroundColor "Green"

# setup SSH
if(Test-Path -Path "$HOME\.ssh")
{
    Remove-Item "$HOME\.ssh" -Force | Out-Null
}
New-Item -ItemType SymbolicLink -Path "$HOME\.ssh" -Target "$HOME\.dotfiles\ssh" | Out-Null
Add-WindowsCapability -Online -Name OpenSSH.Server*

# setup GPG
if(Test-Path -Path "$env:APPDATA\gnupg")
{
    Remove-Item "$env:APPDATA\gnupg" -Force | Out-Null
}
New-Item -ItemType SymbolicLink -Path "$env:APPDATA\gnupg" -Target "$HOME\.dotfiles\gnupg" | Out-Null
if(Test-Path -Path "$HOME\.gnupg")
{
    Remove-Item "$HOME\.gnupg" -Force | Out-Null
}
New-Item -ItemType SymbolicLink -Path "$HOME\.gnupg" -Target "$HOME\.dotfiles\gnupg" | Out-Null

# setup bin
if(Test-Path -Path "$HOME\.bin")
{
    Remove-Item "$HOME\.bin" -Force | Out-Null
}
New-Item -ItemType SymbolicLink -Path "$HOME\.bin" -Target "$HOME\.dotfiles\bin" | Out-Null

# setup other directories
New-Item -Path "$HOME\Projects" -ItemType Directory -Force | Out-Null

# All done!
Write-Host "Setup complete -- Returning to strap..." -ForegroundColor "Green"
