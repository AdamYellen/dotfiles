#Requires -RunAsAdministrator

# Finds any "mouse" device and sets it to use Natural Scrolling
# Requires reboot afterwards
Get-ChildItem -Path "HKLM:SYSTEM\CurrentControlSet\Enum\HID"
   | Get-ChildItem -ErrorAction SilentlyContinue
   | Get-ChildItem -ErrorAction SilentlyContinue
   | Get-Item -ErrorAction SilentlyContinue
   | Where-Object { $_.GetValue("FlipFlopWheel") -ne $null }
   | Set-ItemProperty -Name "FlipFlopWheel" -Value 1
