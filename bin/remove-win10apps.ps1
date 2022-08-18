#Requires -RunAsAdministrator

function Remove-UWP {
   param (
       [string]$name
   )

   Get-AppxPackage $name | Remove-AppxPackage | Out-Null
   Get-AppxPackage $name | Remove-AppxPackage -AllUsers | Out-Null
   # Get-AppXProvisionedPackage -Online | Where DisplayName -like $name | Remove-AppxProvisionedPackage -Online -AllUsers
}

# To list all appx packages:
# Get-AppxPackage | Format-Table -Property Name,Version,PackageFullName
$windowsApps = @(
   "*.AutodeskSketchBook"
   "*.DisneyMagicKingdoms"
   "*.MarchofEmpires"
   "*.SlingTV"
   "*.TikTok"
   "*.Twitter"
   "*549981C3F5F10*"
   "4DF9E0F8.Netflix"
   "AdobeSystemsIncorporated.AdobeCreativeCloudExpress"
   "AmazonVideo.PrimeVideo"
   "Clipchamp.Clipchamp"
   "Disney.37853FC22B2CE"
   "DolbyLaboratories.DolbyAccess"
   "Facebook.Facebook*"
   "Facebook.Instagram*"
   "king.com.*"
   "Microsoft.3DBuilder"
   "Microsoft.BingFinance"
   "Microsoft.BingNews"
   "Microsoft.BingSports"
   "Microsoft.BingWeather"
   "Microsoft.GamingApp"
   "Microsoft.GetHelp"
   "Microsoft.Getstarted"
   "Microsoft.Messaging"
   "Microsoft.Microsoft3DViewer"
   "Microsoft.MicrosoftOfficeHub"
   "Microsoft.MicrosoftSolitaireCollection"
   "Microsoft.MicrosoftStickyNotes"
   "Microsoft.MixedReality.Portal"
   "Microsoft.MSPaint"
   "Microsoft.Office.OneNote"
   "Microsoft.Office.Sway"
   "Microsoft.OneConnect"
   "Microsoft.Paint"
   "Microsoft.People"
   "Microsoft.PowerAutomateDesktop"
   "Microsoft.Print3D"
   "Microsoft.ScreenSketch"
   "Microsoft.SkypeApp"
   "Microsoft.ToDos"
   "Microsoft.Wallet"
   "Microsoft.Windows.Photos"
   "Microsoft.WindowsAlarms"
   "Microsoft.WindowsFeedbackHub"
   "Microsoft.WindowsMaps"
   "Microsoft.WindowsSoundRecorder"
   "Microsoft.Xbox.TCUI"
   "Microsoft.XboxApp"
   "Microsoft.XboxGameOverlay"
   "Microsoft.XboxGamingOverlay"
   "Microsoft.XboxIdentityProvider"
   "Microsoft.XboxSpeechToTextOverlay"
   "Microsoft.YourPhone"
   "Microsoft.ZuneMusic"
   "Microsoft.ZuneVideo"
   "MicrosoftTeams"
   "SpotifyAB.SpotifyMusic"
)

# Remove the pre-installed apps (silently)
Set-Variable ProgressPreference SilentlyContinue
foreach ($app in $windowsApps) {
   Remove-UWP $app
}
Set-Variable ProgressPreference Continue
