param(
  [Parameter(Mandatory)] $packageName,
  [switch] $force
)

$missing = $False
$result = winget list -e $packageName
if("$result" -Match "No installed")
{
   $missing = $True
   Write-Host "Package $packageName not installed; Installing now."
}
elseif($force)
{
   Write-Host "Package $packageName already installed; Forcing now."
}

if($missing -Or $force)
{
   winget install $packageName --silent --accept-source-agreements --accept-package-agreements | Out-Null
}
else
{
   Write-Host "Package $packageName already installed"
}
