#Requires -RunAsAdministrator

# NOTES:
# * This script is idempotent
# * This script does not require user input
# * NOTE: "winget" is not available during the lifetime of this script
# * Preconditions: none

function DoUnpinFromTaskbar([string]$appname) {
    $ErrorActionPreference = 'silentlycontinue'
     ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() `
      | Where-Object { $_.Name -eq $appname }).Verbs() `
      | Where-Object { $_.Name.replace('&', '') -match 'Unpin from taskbar' } `
      | ForEach-Object { $_.DoIt(); }
    $ErrorActionPreference = 'continue'
 }

 function DoPinToQuickAccess([string]$folder) {
    $ErrorActionPreference = 'silentlycontinue'
    $QuickAccess = New-Object -ComObject Shell.Application 
    $QuickAccess.Namespace("$folder").Self.InvokeVerb("pintohome")
    $ErrorActionPreference = 'continue'
 }

 function DoUnpinFromQuickAccess([string]$folder) {
    $ErrorActionPreference = 'silentlycontinue'
    $QuickAccess = New-Object -ComObject Shell.Application 
    ($QuickAccess.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items() | Where-Object {$_.Path -eq "$folder"}).InvokeVerb("unpinfromhome")
    $ErrorActionPreference = 'continue'
 }
 
# Privacy
if ($False) {
    Write-Host "Configuring Privacy..." -ForegroundColor "Green"

    # # General: Don't let apps use advertising ID for experiences across apps: Allow: 1, Disallow: 0
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Enabled" 0
    # Remove-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" "Id" -ErrorAction SilentlyContinue

    # # General: Disable Application launch tracking: Enable: 1, Disable: 0
    # Set-ItemProperty "HKCU:\\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Start-TrackProgs" 0

    # # General: Disable SmartScreen Filter for Store Apps: Enable: 1, Disable: 0
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppHost" "EnableWebContentEvaluation" 0

    # # General: Disable key logging & transmission to Microsoft: Enable: 1, Disable: 0
    # # Disabled when Telemetry is set to Basic
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Input")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Input" -Type Folder | Out-Null}
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Input\TIPC" "Enabled" 0

    # # General: Opt-out from websites from accessing language list: Opt-in: 0, Opt-out 1
    # Set-ItemProperty "HKCU:\Control Panel\International\User Profile" "HttpAcceptLanguageOptOut" 1

    # # General: Disable SmartGlass: Enable: 1, Disable: 0
    # #Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" "UserAuthPolicy" 0

    # # General: Disable SmartGlass over BlueTooth: Enable: 1, Disable: 0
    # #Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\SmartGlass" "BluetoothPolicy" 0

    # # General: Disable suggested content in settings app: Enable: 1, Disable: 0
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338393Enabled" 0
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338394Enabled" 0
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338396Enabled" 0

    # # General: Disable tips and suggestions for welcome and what's new
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-310093Enabled" 0

    # # General: Disable tips and suggestions when I use windows
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338389Enabled" 0

    # # Start Menu: Disable suggested content: Enable: 1, Disable: 0
    # #Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" "SubscribedContent-338388Enabled" 0

    # # Start Menu: Disable search entries
    # # if (!(Test-Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer")) {New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Type Folder | Out-Null}
    # # Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\Explorer" "DisableSearchBoxSuggestions" 1

    # # Camera: Don't let apps use camera: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\webcam" "Value" "Deny"

    # # Microphone: Don't let apps use microphone: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\microphone" "Value" "Deny"

    # # Notifications: Don't let apps access notifications: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userNotificationListener" "Value" "Deny"

    # # Speech, Inking, & Typing: Stop "Getting to know me"
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitTextCollection" 1
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization" "RestrictImplicitInkCollection" 1
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" "HarvestContacts" 0
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" "AcceptedPrivacyPolicy" 0
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings" -Type Folder | Out-Null}
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" "HasAccepted" 0

    # # Account Info: Don't let apps access name, picture, and other account info: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userAccountInformation" "Value" "Deny"

    # # Contacts: Don't let apps access contacts: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" "Value" "Deny"

    # # Calendar: Don't let apps access calendar: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appointments" "Value" "Deny"

    # # Call History: Don't let apps make phone calls: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCall" "Value" "Deny"

    # # Call History: Don't let apps access call history: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\phoneCallHistory" "Value" "Deny"

    # # Diagnostics: Don't let apps access diagnostics of other apps: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\appDiagnostics" "Value" "Deny"

    # # Documents: Don't let apps access documents: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\documentsLibrary" "Value" "Deny"

    # # Downloads: Don't let apps access downloads: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\downloadsFolder" "Value" "Deny"

    # # Email: Don't let apps read and send email: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\email" "Value" "Deny"

    # # File System: Don't let apps access the file system: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\broadFileSystemAccess" "Value" "Deny"

    # # Location: Don't let apps access the location: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" "Value" "Deny"

    # # Messaging: Don't let apps read or send messages (text or MMS): Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\chat" "Value" "Deny"

    # # Music Library: Don't let apps access music library: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\musicLibrary" "Value" "Deny"

    # # Pictures: Don't let apps access pictures: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\picturesLibrary" "Value" "Deny"

    # # Radios: Don't let apps control radios (like Bluetooth): Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\radios" "Value" "Deny"

    # # Screenshot: Don't let apps take screenshots: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureProgrammatic" "Value" "Deny"

    # # Screenshot Borders: Don't let apps access screenshot border settings: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\graphicsCaptureWithoutBorder" "Value" "Deny"

    # # Tasks: Don't let apps access the tasks: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" "Value" "Deny"

    # # Other Devices: Don't let apps share and sync with non-explicitly-paired wireless devices over uPnP: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\bluetoothSync" "Value" "Deny"

    # # Videos: Don't let apps access videos: Allow, Deny
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\videosLibrary" "Value" "Deny"

    # # Feedback: Windows should never ask for my feedback
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf" -Type Folder | Out-Null}
    # if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules")) {New-Item -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" -Type Folder | Out-Null}
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" "NumberOfSIUFInPeriod" 0

    # # Feedback: Telemetry: Send Diagnostic and usage data: Basic: 1, Enhanced: 2, Full: 3
    # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "AllowTelemetry" 1
    # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" "MaxTelemetryAllowed" 1
}

# Devices, Power, and Startup
if ($True) {
    Write-Host "Configuring Devices, Power, and Startup..." -ForegroundColor "Green"

    # Sound: Disable Startup Sound
    # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" "DisableStartupSound" 1
    # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI\BootAnimation" "DisableStartupSound" 1
    # Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\EditionOverrides" "UserSetting_DisableStartupSound" 1

    # Power: Disable Hibernation
    powercfg /hibernate off

    # Power: Disable Sleep on AC Power
    powercfg /change /standby-timeout-ac 0

    # Power: Monitor sleep
    powercfg /change /monitor-timeout-ac 20

    # SSD: Disable SuperFetch
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" "EnableSuperfetch" 0
}

# Desktop, Explorer, Taskbar, and System Tray
if ($True) {
    Write-Host "Configuring Desktop, Explorer, Taskbar, and System Tray..." -ForegroundColor "Green"

    # Ensure necessary registry paths
    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Type Folder | Out-Null}
    if (!(Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState")) {New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" -Type Folder | Out-Null}
    # if (!(Test-Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search")) {New-Item -Path "HKLM:\Software\Policies\Microsoft\Windows\Windows Search" -Type Folder | Out-Null}

    # Explorer: Show hidden files by default: Show Files: 1, Hide Files: 2
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "Hidden" 1

    # Explorer: Show file extensions by default
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "HideFileExt" 0

    # Explorer: Show path in title bar
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" "FullPath" 1

    # Explorer: Avoid creating Thumbs.db files on network volumes
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "DisableThumbnailsOnNetworkFolders" 1

    # Taskbar: Hide the Search, Task, Widget, Chat buttons, and built-in Microsoft apps
    # Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" "SearchboxTaskbarMode" 0  # Search
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowTaskViewButton" 0 # Task
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarDa" 0 # Widgets
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "TaskbarMn" 0 # Chat
    DoUnpinFromTaskbar "Microsoft Store"
    DoUnpinFromTaskbar "Mail"
    DoUnpinFromTaskbar "Store"
    DoUnpinFromTaskbar "Edge"
    DoUnpinFromTaskbar "Microsoft Edge"

    # Taskbar: Show colors on Taskbar, Start, and SysTray: Disabled: 0, Taskbar, Start, & SysTray: 1, Taskbar Only: 2
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" "ColorPrevalence" 1

    # Taskbar: Display seconds in the clock
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "ShowSecondsInSystemClock" 1

    # Taskbar: Hide Meet Now (aka Skype)
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "HideSCAMeetNow" 1
    
    # Titlebar: Disable theme colors on titlebar
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\DWM" "ColorPrevalence" 0

    # Recycle Bin: Disable Delete Confirmation Dialog
    Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" "ConfirmFileDelete" 0

    # Desktop: Show 'This PC' Icon
    $thisPCIconRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"
    $thisPCRegValname = "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" 
    $item = Get-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -ErrorAction SilentlyContinue 
    if ($item)
    {
        Set-ItemProperty  -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0  
    }
    else
    {
        New-ItemProperty -Path $thisPCIconRegPath -Name $thisPCRegValname -Value 0 -PropertyType DWORD | Out-Null  
    }

    # Desktop: Microsoft Edge Icon
    # New-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\EdgeUpdate" -Name "CreateDesktopShortcutDefault" -Value 0 -PropertyType DWORD | Out-Null
    if (Test-Path -Path "$HOME\Desktop\Microsoft Edge.lnk") {
        Remove-Item "$HOME\Desktop\Microsoft Edge.lnk"
    }
    if (Test-Path -Path "C:\Users\Public\Desktop\Microsoft Edge.lnk") {
        Remove-Item "C:\Users\Public\Desktop\Microsoft Edge.lnk"
    }

    # File Exporer: Clean and Setup Quick Access
    DoPinToQuickAccess("$HOME\Music")           # https://stackoverflow.com/a/63655938
    DoUnpinFromQuickAccess("$HOME\Music")
    DoPinToQuickAccess("$HOME\Videos")
    DoUnpinFromQuickAccess("$HOME\Videos")
    DoUnpinFromQuickAccess("$HOME\Pictures")
    DoPinToQuickAccess("$HOME")
}

# Default Windows Applications
if ($True) {
    Write-Host "Configuring Default Windows Applications..." -ForegroundColor "Green"

    # Uninstall Windows Media Player
    Disable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -WarningAction SilentlyContinue | Out-Null

    # Prevent "Suggested Applications" from returning
    #Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableWindowsConsumerFeatures" 1 -Force
    #Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableCloudOptimizedContent" 1 -Force
    #Set-ItemProperty "HKLM:\Software\Policies\Microsoft\Windows\CloudContent" "DisableConsumerAccountStateContent" 1 -Force

    # Uninstall pre-installed apps
    if([System.Environment]::OSVersion.Version.Build -lt 22000) {
        if (Test-Path "$HOME\.dotfiles\bin\remove-win10apps.ps1") {
            & "$HOME\.dotfiles\bin\remove-win10apps.ps1"
        }
    }
    else {
        if (Test-Path "$HOME\.dotfiles\bin\remove-win11apps.ps1") {
            & "$HOME\.dotfiles\bin\remove-win11apps.ps1"
        }
    }
}

# Start Menu
if ($True) {
    Write-Host "Configuring Start Menu (Don't press any keys)..." -ForegroundColor "Green"

    # Our blank template
    $START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

    $layoutFile="C:\Windows\StartMenuLayout.xml"
    # $regAliases = @("HKLM", "HKCU")
    $regAliases = @("HKCU")

    # Delete layout file if it already exists
    If(Test-Path -Path $layoutFile)
    {
        Remove-Item $layoutFile -Force | Out-Null
    }

    # Creates the blank layout file
    $START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

    # Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        If(!(Test-Path -Path $keyPath))
        { 
            New-Item -Path $basePath -Name "Explorer" | Out-Null
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }

    # Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
    Stop-Process -name explorer
    Start-Sleep -s 5
    $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
    Start-Sleep -s 5

    # Enable the ability to pin items again by disabling "LockedStartLayout"
    foreach ($regAlias in $regAliases)
    {
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }

    # Hide Recently Added Items
    if (!(Test-Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer")) {New-Item -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Type Folder | Out-Null}
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "HideRecentlyAddedApps" -Value 1

    # Restart Explorer and delete the layout file
    Stop-Process -name explorer
    Start-Sleep -s 5
    $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
    Start-Sleep -s 5
    Remove-Item $layoutFile
}

# Accessibility and Ease of Use
if ($True) {
    Write-Host "Configuring Accessibility..." -ForegroundColor "Green"

    # Turn Off Windows Narrator Hotkey
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Narrator\NoRoam" "WinEnterLaunchEnabled" 0

    # Disable "Window Snap" Automatic Window Arrangement
    Set-ItemProperty "HKCU:\Control Panel\Desktop" "WindowArrangementActive" 0

    # Disable automatic fill to space on Window Snap
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapFill" 0

    # Disable showing what can be snapped next to a window
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "SnapAssist" 0

    # Disable automatic resize of adjacent windows on snap
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" "JointResize" 0

    # Disable auto-correct
    # Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\TabletTip\1.7" "EnableAutocorrection" 0

    # Disable Windows Narrator and all Assistive Technology
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" -Name "Narrator.exe" -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\Narrator.exe" "Debugger" "%1"
    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options" -Name "AtBroker.exe" -ErrorAction SilentlyContinue | Out-Null
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\AtBroker.exe" "Debugger" "%1"
}

# Internet Explorer
if ($True) {
    Write-Host "Configuring Internet Explorer..." -ForegroundColor "Green"

    # Set home page to `about:blank` for faster loading
    Set-ItemProperty "HKCU:\Software\Microsoft\Internet Explorer\Main" "Start Page" "about:blank"

    # Disable 'Default Browser' check: "yes" or "no"
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Main" "Check_Associations" "no"

    # Disable Password Caching [Disable Remember Password]
    Set-ItemProperty "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings" "DisablePasswordCaching" 1

    # Disable IE11
    if([System.Environment]::OSVersion.Version.Build -lt 22000) {
        Disable-WindowsOptionalFeature -FeatureName "Internet-Explorer-Optional-amd64" -Online -NoRestart -WarningAction SilentlyContinue | Out-Null
    }
}

# Disk Cleanup (CleanMgr.exe)
if ($False) {
    Write-Host "Configuring Disk Cleanup..." -ForegroundColor "Green"

    $diskCleanupRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\"

    # Cleanup Files by Group: 0=Disabled, 2=Enabled
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "BranchCache"                                  ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Downloaded Program Files"                     ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Internet Cache Files"                         ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Offline Pages Files"                          ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Old ChkDsk Files"                             ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Previous Installations"                       ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Recycle Bin"                                  ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "RetailDemo Offline Content"                   ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Service Pack Cleanup"                         ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Setup Log Files"                              ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "System error memory dump files"               ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "System error minidump files"                  ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Temporary Files"                              ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Temporary Setup Files"                        ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Thumbnail Cache"                              ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Update Cleanup"                               ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Upgrade Discarded Files"                      ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "User file versions"                           ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Defender"                             ) "StateFlags6174" 2   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting Archive Files"        ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting Queue Files"          ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting System Archive Files" ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting System Queue Files"   ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Error Reporting Temp Files"           ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows ESD installation files"               ) "StateFlags6174" 0   -ErrorAction SilentlyContinue
    Set-ItemProperty $(Join-Path $diskCleanupRegPath "Windows Upgrade Log Files"                    ) "StateFlags6174" 0   -ErrorAction SilentlyContinue

    Remove-Variable diskCleanupRegPath
}

# PowerShell Console
if ($True) {
    Write-Host "Configuring Console..." -ForegroundColor "Green"

    # Make 'Source Code Pro' an available Console font
    Set-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Console\TrueTypeFont' 000 'Source Code Pro'
}

# Development
if ($True) {
    Write-Host "Enable Development Settings..." -ForegroundColor "Green"

    # Enable Remote Desktop
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\" -Name "fDenyTSConnections" -Value 0
    Set-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\" -Name "UserAuthentication" -Value 1
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Enable Developer Mode
    Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" "AllowDevelopmentWithoutDevLicense" 1
}

# WSL2
if ($False) {
    Write-Host "Installing Windows Subsystem for Linux..." -ForegroundColor "Green"
    wsl --install | Out-Null
}

# Home directory
if ($True) {
    Write-Host "Setup home directory..." -ForegroundColor "Green"

    # setup SSH
    if (Test-Path -Path "$HOME\.ssh") {
        Remove-Item "$HOME\.ssh" -Force | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path "$HOME\.ssh" -Target "$HOME\.dotfiles\ssh" | Out-Null

    # setup GPG
    if (Test-Path -Path "$env:APPDATA\gnupg") {
        Remove-Item "$env:APPDATA\gnupg" -Force | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path "$env:APPDATA\gnupg" -Target "$HOME\.dotfiles\gnupg" | Out-Null
    if (Test-Path -Path "$HOME\.gnupg") {
        Remove-Item "$HOME\.gnupg" -Force | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path "$HOME\.gnupg" -Target "$HOME\.dotfiles\gnupg" | Out-Null

    # setup bin
    if (Test-Path -Path "$HOME\.bin") {
        Remove-Item "$HOME\.bin" -Force | Out-Null
    }
    New-Item -ItemType SymbolicLink -Path "$HOME\.bin" -Target "$HOME\.dotfiles\bin" | Out-Null

    New-Item -Path "$HOME\Projects" -ItemType Directory -Force | Out-Null
}

Write-Host "Setup complete -- Returning to strap..." -ForegroundColor "Green"
