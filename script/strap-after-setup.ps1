#Requires -RunAsAdministrator

param($strap_op_uri)

# NOTES:
# * This script is idempotent
# * This script requires user input and actions
# * Preconditions:
#   * Apps installed: winget
#   * Folders linked to dotfiles repo: $HOME/.bin, $HOME/.gnupg, $env:APPDATA/gnupg, $HOME/.ssh

# TODO:
# * Put common commands into a module
# * Don't error out; allow the user to attempt to fix the issue
# * Support unavailable biometrics in 1Password setup (add 1Password account directly on the CLI)
# * Find the executable paths dynamically (1Password, Synctrazor/Syncthing)

function CheckCommand
{
   param
   (
      [string]$cmdname
   )
   return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

function RefreshEnv
{
   $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
}

function AddToUserPath
{
   param
   (
      [string]$folder
   )
   $currentEnv = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::User).Trim(";");
   $addedEnv = $currentEnv + ";$folder"
   $trimmedEnv = (($addedEnv.Split(';') | Select-Object -Unique) -join ";").Trim(";")
   [Environment]::SetEnvironmentVariable("Path", $trimmedEnv, [EnvironmentVariableTarget]::User)
}

function AddToUserPathAndRefresh
{
   param
   (
      [string]$folder
   )
   AddToUserPath $folder
   RefreshEnv
}

# Prompt the user
Write-Host "!! IMPORTANT !!" -ForegroundColor "Red"
Read-Host -Prompt "This script requires user input and GUI interaction -- Press Return to continue after system is ready"

# Dependencies needed to continue
Write-Host "Installing dependencies..." -ForegroundColor "Green"

if(CheckCommand -cmdname 'winget')
{
   winget install AgileBits.1Password --silent --accept-source-agreements --accept-package-agreements | Out-Null
   winget install AgileBits.1Password.CLI --silent --accept-source-agreements --accept-package-agreements | Out-Null
   winget install GnuPG.GnuPG --silent --accept-source-agreements --accept-package-agreements | Out-Null
   winget install SyncTrayzor.SyncTrayzor --silent --accept-source-agreements --accept-package-agreements | Out-Null
}
else
{
   Write-Host "!! Exiting: Winget not installed or not in path !!" -ForegroundColor "Red"
   Return 1
}
RefreshEnv

# Add our .bin folder to the path so we can call some scripts
AddToUserPathAndRefresh -folder "$HOME\.bin"

# Setup 1Password
Write-Host "Press Return to continue AFTER Windows Hello is setup with at least one biometric option (e.g. PIN)" -ForegroundColor "Red"
Start-Sleep -Seconds 2
Start-Process ms-settings:signinoptions
Read-Host -Prompt "Is Windows Hello setup? Press Return to continue"
if(-not $strap_op_uri)
{
   $strap_op_uri = Read-Host -Prompt "Please enter a 1Password signup URI or press Return to setup manually"
}
Write-Host "Press Return to continue AFTER 1Password is setup -- Sign in and enable CLI and SSH-Agent under Developer settings" -ForegroundColor "Red"
Start-Sleep -Seconds 2
if($strap_op_uri)
{
   Start-Process -Filepath "$env:PROGRAMFILES\1Password\app\8\1Password.exe" -Args "$strap_op_uri" -RSO "$env:LOCALAPPDATA/Temp/1pass1.txt" -RSE "$env:LOCALAPPDATA/Temp/1pass2.txt"
}
else
{
   Start-Process -Filepath "$env:PROGRAMFILES\1Password\app\8\1Password.exe" -RSO "$env:LOCALAPPDATA/Temp/1pass1.txt" -RSE "$env:LOCALAPPDATA/Temp/1pass2.txt"
}
Read-Host -Prompt "Is 1Password CLI and SSH-Agent enabled? Press Return to continue"

# Setup GnuPG (initialize our keyring if needed)
gpg --list-keys | Out-Null

# Get our secrets
& "$HOME\.bin\extract-onepassword-secrets.ps1"

# Import our secrets by pretending we're BASH
if(Test-Path "$HOME\.secrets")
{
   foreach($line in (Get-Content "$HOME\.secrets" | Select-String -NotMatch "^#"))
   {
      $array = $line[0].ToString().split("=")
      if($array[0] -and $array[1])
      {
         # .secrets probably shouldn't export secrets, but remove it if it exists
         $exportArray = $array[0].ToString().split(" ")
         if(($exportArray[0] -eq "export") -and $exportArray[1])
         {
            $array[0] = $exportArray[1]
         }
         New-Variable -Name $array[0] -Value $array[1] -Force -Scope Script
      }
   }
}
else
{
   Write-Host "!! Exiting: Failed to get secrets !!" -ForegroundColor "Red"
   Return 1
}

# Setup Syncthing
Write-Host "Press Return to continue AFTER Syncthing is setup and sync completes" -ForegroundColor "Red"
Start-Sleep -Seconds 2
New-NetFirewallRule -DisplayName "Syncthing" -Direction Inbound -Program "$env:APPDATA\SyncTrayzor\syncthing.exe" -Action Allow | Out-Null
if(-not (Get-Process | Where-Object ProcessName -eq "SyncTrayzor"))
{
   Start-Process -Filepath "$env:ProgramFiles\SyncTrayzor\SyncTrayzor.exe" | Out-Null
   Start-Sleep -Seconds 15
}

if($SECRET_SYNCTHING_MASTER_DEVICE_ID -and $SECRET_SYNCTHING_MASTER_FOLDER_ID)
{
   Start-Process -Filepath "$env:APPDATA\SyncTrayzor\syncthing.exe" -NoNewWindow -Args "cli config devices add --device-id $SECRET_SYNCTHING_MASTER_DEVICE_ID"
   Start-Sleep -Seconds 2
   New-Item -Path "$HOME\.sync" -ItemType Directory -Force | Out-Null
   $homedir = Resolve-Path -Path "$HOME\.sync"
   Start-Process -Filepath "$env:APPDATA\SyncTrayzor\syncthing.exe" -NoNewWindow -Args "cli config folders add --id $SECRET_SYNCTHING_MASTER_FOLDER_ID --label `"configs (~.sync)`" --path `"$homedir`""
}

Read-Host -Prompt "Is Syncthing setup and sync completed? Press Return to continue"
if(-not (Test-Path "$HOME\.sync\.first-sync"))
{
   Write-Host "!! Exiting: Syncthing is not setup !!" -ForegroundColor "Red"
   Return 1
}

###############################################################################
### Misc                                                                      #
###############################################################################
# Write-Host "Installing Visual Studio and toolchains..." -ForegroundColor "Green"
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022#bootstrapper-commands-and-command-line-parameters
# Full IDE
# winget install Microsoft.VisualStudio.2022.Community --override "--wait --quiet --addProductLang En-us --includeRecommended --add Microsoft.VisualStudio.Workload.NativeDesktop" | Out-Null
# Bare minimum (CLI and only the deps we need)
# winget install Microsoft.VisualStudio.2022.BuildTools --override "--wait --quiet --addProductLang En-us --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 --add Microsoft.VisualStudio.Component.Windows10SDK.19041"| Out-Null
# TODO: ^ Need to check for Win10/Win11

# # gsudo
# PowerShell -Command "Set-ExecutionPolicy RemoteSigned -scope Process; [Net.ServicePointManager]::SecurityProtocol = 'Tls12'; iwr -useb https://raw.githubusercontent.com/gerardog/gsudo/master/installgsudo.ps1 | iex"

# Write-Host "Setting up dotnet for Windows..." -ForegroundColor "Green"
# Write-Host "------------------------------------" -ForegroundColor "Green"
# [Environment]::SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development", "Machine")
# [Environment]::SetEnvironmentVariable("DOTNET_PRINT_TELEMETRY_MESSAGE", "false", "Machine")
# [Environment]::SetEnvironmentVariable("DOTNET_CLI_TELEMETRY_OPTOUT", "1", "Machine")
# winget install Microsoft.dotNetFramework --accept-source-agreements --accept-package-agreements | Out-Null
# dotnet tool install --global dotnet-ef
# dotnet tool update --global dotnet-ef

# Write-Host "Excluding repos from Windows Defender..." -ForegroundColor "Green"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\source\repos"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.nuget"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.vscode"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.dotnet"
# Add-MpPreference -ExclusionPath "$env:USERPROFILE\.ssh"
# Add-MpPreference -ExclusionPath "$env:APPDATA\npm"

# Write-Host "Enabling Hardware-Accelerated GPU Scheduling..." -ForegroundColor "Green"
# New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers\" -Name 'HwSchMode' -Value '2' -PropertyType DWORD -Force

# Point git at the installed GnuPG
git config --system gpg.program "C:/Program Files (x86)/gnupg/bin/gpg"

# Setup SSH
Write-Host "Setup SSH..." -ForegroundColor "Green"

# Disable the Microsoft OpenSSH ssh-agent service. We want to use the SSH agent built into 1Password.
Get-Service ssh-agent | Set-Service -StartupType Disabled
Stop-Service ssh-agent

# Enable and start the Microsoft OpenSSH server
Get-Service sshd | Set-Service -StartupType Automatic
Start-Service sshd

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if(!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled))
{
   New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# Use PowerShell as our default shell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Program Files\PowerShell\7\pwsh.exe" -PropertyType String -Force

# Add our authorized key to the special admin group and fix permissions
Copy-Item -Path "$HOME\.ssh\authorized_keys" -Destination "$Env:PROGRAMDATA\ssh\administrators_authorized_keys"
icacls.exe "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r /grant "Administrators:F" /grant "SYSTEM:F"

# Update built-in help
if(Get-Command -cmdname 'pwsh')
{
   Write-Host "Updating PowerShell Core help..." -ForegroundColor "Green"
   pwsh -Command {Update-Help -UICulture en-US -Force -ErrorAction SilentlyContinue}
}

# Install Rotz
Write-Host "Setup Rotz..." -ForegroundColor "Green"
winget install 7zip.7zip 6>&1 | Out-Null
if(-not (Test-Path "$HOME\.dotfiles\script\strap-support\rotz-windows.7z"))
{
   Write-Host "!! Exiting: Missing strap support files !!" -ForegroundColor "Red"
   Return 1
}
7z.exe e -y -o"$HOME" "$HOME\.dotfiles\script\strap-support\rotz-windows.7z" | Out-Null

# Run Rotz
& "$HOME\rotz.exe" install | Out-Null
& "$HOME\rotz.exe" link -f | Out-Null

# All done!
Write-Host "Strap-after-setup complete -- Returning to strap..." -ForegroundColor "Green"
