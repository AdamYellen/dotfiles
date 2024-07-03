$OP_ACCOUNT="yellen.1password.com"
$ID_GNUPG_PRIVATE="arsatc7yulxzaf33anloj6wrle"
$ID_SECRETS="j7dcx5ksiylxsj4dkopyntmvpq"
$MAX_RETRIES=10

if (-Not (Get-Command -Name "op" -ErrorAction SilentlyContinue)) {
   Write-Host "Error: 'op' not found in path" -ForegroundColor "Red"
   Exit 1
}

if (-Not (Get-Command -Name "gpg" -ErrorAction SilentlyContinue)) {
   Write-Host "Error: 'gpg' not found in path" -ForegroundColor "Red"
   Exit 1
}

function onepassword_login() {
   param (
      [string]$account
   )

   Start-Sleep -Seconds 1
   Invoke-Expression $(op signin --account $account)
   $retval = $?
   Start-Sleep -Seconds 1
   return $retval
}

function onepassword_get() {
   param (
      [string]$account,
      [string]$secret_id,
      [string]$secret_output
   )

   if (Test-Path -Path "$HOME\$secret_output") {
      Write-Host "'$secret_output' already exists." -ForegroundColor "Red"
      Return $False
   }
   Write-Host "Extracting '$secret_output'..." -ForegroundColor "Green"
   $success = $False
   $retries = $MAX_RETRIES
   do {
      Start-Sleep -Seconds 1
      op document get --account $account $secret_id --output "$HOME\$secret_output" | Out-Null
      $retval = $?
      Start-Sleep -Seconds 1
      if ($retval) {
         if ((Test-Path("$HOME\$secret_output")) -and ((Get-Item "$HOME\$secret_output").length -gt 0))
         {
            $success = $True
         }
      }
   } while ((-Not $success) -and (--$retries -gt 0))

   if ($success) {
      # chmod 600 "$HOME\$secret_output"
   }
   else {
      Write-Host "Failed to extract '$secret_output'." -ForegroundColor "Red"
   }
}

Write-Host "Logging in to 1Password..." -ForegroundColor "Green"
if (onepassword_login($OP_ACCOUNT)) {
   onepassword_get -account $OP_ACCOUNT -secret_id $ID_GNUPG_PRIVATE -secret_output ".gnupg/6933682+AdamYellen@users.noreply.github.com.private.gpg-key" | Out-Null
   onepassword_get -account $OP_ACCOUNT -secret_id $ID_SECRETS -secret_output ".secrets" | Out-Null
}
else {
   Write-Host "Login failed." -ForegroundColor "Red"
}

# Configure GPG
if (-Not (Test-Path "$HOME/.gnupg/gpg-agent.conf")) {
   # Cache passphrases for 7 days
   Set-Content -Path "$HOME/.gnupg/gpg-agent.conf" -Value "default-cache-ttl 604800$([System.Environment]::NewLine)max-cache-ttl 604800"   
}
gpgconf --kill gpg-agent
gpgconf --launch gpg-agent

# Import our keys
Write-Host "Importing GPG keys -- Will prompt for passphrase if set..." -ForegroundColor "Green"
gpg --import "$HOME/.gnupg/6933682+AdamYellen@users.noreply.github.com.public.gpg-key" "$HOME/.gnupg/6933682+AdamYellen@users.noreply.github.com.private.gpg-key" 2>&1 | Out-Null
