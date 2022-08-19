#Requires -RunAsAdministrator

param($strap_op_uri)

# NOTES:
# * This script is idempotent
# * This script requires user input and actions
# * Preconditions:
#   * Apps installed: scoop, winget
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

function UpdateStoreApps
{
   $wmiObj = Get-WmiObject -Namespace "root\cimv2\mdm\dmmap" -Class "MDM_EnterpriseModernAppManagement_AppManagement01"
   $wmiObj.UpdateScanMethod() | Out-Null
   Start-Sleep -Seconds 30
   Remove-Variable wmiObj    
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

function IsWindows10
{
   return([System.Environment]::OSVersion.Version.Build -lt 22000)
}

# Prompt the user
Write-Host "!! IMPORTANT !!" -ForegroundColor "Red"
Read-Host -Prompt "This script requires user input and GUI interaction -- Press Return to continue after system is ready"

# Do we have winget yet?
while(-not (CheckCommand -cmdname 'winget'))
{
   Write-Host "Trying to update the Microsoft Store to get winget..." -ForegroundColor "Green"
   UpdateStoreApps   # has a built-in sleep
}

# Dependencies needed to continue
Write-Host "Installing dependencies..." -ForegroundColor "Green"
if(CheckCommand -cmdname 'scoop')
{
   scoop install 1password-cli 6>&1 | Out-Null
}
else
{
   Write-Host "!! Exiting: Scoop not installed or not in path !!" -ForegroundColor "Red"
   Return 1
}

if(CheckCommand -cmdname 'winget')
{
   winget install AgileBits.1Password --silent --accept-source-agreements --accept-package-agreements | Out-Null
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
Write-Host "Press Return to continue AFTER 1Password is setup -- Sign in and enable CLI under Developer settings" -ForegroundColor "Red"
Start-Sleep -Seconds 2
if($strap_op_uri)
{
   Start-Process -Filepath "$env:LOCALAPPDATA\1Password\app\8\1Password.exe" -Args "$strap_op_uri" -RSO "$env:LOCALAPPDATA/Temp/1pass1.txt" -RSE "$env:LOCALAPPDATA/Temp/1pass2.txt"
}
else
{
   Start-Process -Filepath "$env:LOCALAPPDATA\1Password\app\8\1Password.exe" -RSO "$env:LOCALAPPDATA/Temp/1pass1.txt" -RSE "$env:LOCALAPPDATA/Temp/1pass2.txt"
}
Read-Host -Prompt "Is 1Password CLI enabled? Press Return to continue"

# Setup GnuPG (initialize our keyring if needed)
gpg --list-keys | Out-Null

# Get our secrets
& "$HOME\.bin\extract-onepassword-secrets.ps1"

# Import our secrets by pretending we're BASH
if(Test-Path "$HOME\.secrets")
{
   Get-Content "$HOME\.secrets" | Select-String -NotMatch "^#" | ForEach-Object
   { 
      $array = $_[0].ToString().split("=")
      if($array[0] -and $array[1])
      {
         # .secrets probably shouldn't export secrets, but remove it if it exists
         $exportArray = $array[0].ToString().split(" ")
         if(($exportArray[0] -eq "export") -and $exportArray[1]) {
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
   Start-Process -Filepath "$env:APPDATA\SyncTrayzor\syncthing.exe" -NoNewWindow -Args "cli config folders add --id $SECRET_SYNCTHING_MASTER_FOLDER_ID --label `"configs (~.sync)`" --path ~\.sync"
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

# Setup Git
Write-Host "Setup Git..." -ForegroundColor "Green"

# Get rid of scoop's git and get it from winget instead
scoop uninstall git -p 6>&1 | Out-Null
Copy-Item -Path "$HOME\.dotfiles\script\strap-support\git.inf" -Destination "C:\git.inf" -Force
$git_install_inf = "C:\git.inf"
$git_install_args = "/SP- /VERYSILENT /SUPPRESSMSGBOXES /NOCANCEL /NORESTART /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /LOADINF=""$git_install_inf"""
winget install Git.Git --override "$git_install_args" | Out-Null
Remove-Item -Path "C:\git.inf" -Force
RefreshEnv

# Squelch git 2.x warning message when pushing
if(-not (git config --system push.default))
{
   git config --system push.default simple
}

# Never modify line-endings
git config --system core.autocrlf off

# Point git at the installed GnuPG
git config --system gpg.program "C:/Program Files (x86)/gnupg/bin/gpg"

# Setup SSH
Write-Host "Setup SSH..." -ForegroundColor "Green"

# By default the ssh-agent service is disabled. Configure it to start automatically.
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent

# Update built-in help
Write-Host "Updating PowerShell help..." -ForegroundColor "Green"
Update-Help -UICulture en-US -Force -ErrorAction SilentlyContinue | Out-Null

# Remove installed Apps that came back after Windows updated
if(Test-Path "$HOME\.dotfiles\bin\remove-windows-apps.ps1")
{
   & "$HOME\.dotfiles\bin\remove-windows-apps.ps1"
}

# Install Rotz
Write-Host "Setup Rotz..." -ForegroundColor "Green"
scoop install 7zip 6>&1 | Out-Null
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
