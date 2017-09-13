
<#                            CyberArk Terminal Utility (CTU)

        CyberArk Terminal Utility is a terminal interface that uses REST API
        to access CyberArk instead of the outdated and restricted PACLI.

        Created by:   Ziyad Alshehri
        Built using:  CyberArk RESTAPI v9.9, and psPAS as a RestAPI wrapper

        Credits:
                  Pete Maan for the well-documented RestAPI PowerShell module
                              (https://github.com/pspete/psPAS)

                  Joe Garcia for his work on:
                    - CyberArk RestAPI (https://git.joeco.de/CyberArk-RESTAPI)
                    - PUU 2 (https://git.joeco.de/PasswordUploadUtility-v2)

        GitHub Repo:  https://github.com/zshehri/CTU
#>

#########       CTU Functions       ##########

function Get-CountSafeUsers
{
<#

.DESCRIPTION:
    This function loads all safe contents to a PS object, prints all users who have access to the safe.

#>

    [CmdletBinding()]
    param (
           [string] $Safe
    )

    # Load safe content as an object
    try{
      $safeContent = $token | Get-PASSafeMembers -SafeName $Safe -ErrorAction Stop
      # Calculate number of users (including system accounts)
      $UsersCount = ($safeContent.UserName | measure).Count
      # Outputting all safe users
      Write-Host " "
      Write-Host "The Safe $Safe is accessible by $UsersCount (including system accounts) "  -ForegroundColor "Yellow"
      Write-Host "Listing all accounts:"
      Write-Host " "
      $safeContent.UserName
      Write-Host " "
      }
    catch {
      Write-Host "[ERROR] Couldn't load safe $Safe content" -ForegroundColor "Red"
      #Write-Host "[DEBUG] Printing error: $_.Exception.Message" -ForegroundColor "Magenta"
    }
}

function Remove-SafeMember
{
<#

.DESCRIPTION:
    This function removes user's access to a safe, prints errors OR success message at the end, passes log message to the logging function

#>

     [CmdletBinding()]
     param (
           [string] $UserID,
           [string] $Safe
     )

     try   {$safeContent = $token | Get-PASSafeMembers -SafeName $Safe -ErrorAction Stop}
     catch {$msg = "[ERROR] Couldn't access safe $Safe"; Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName}

     if ($safeContent.Username -contains $UserID) {
        try {$Token | Remove-PASSafeMember -SafeName $Safe -MemberName $UserID -ErrorAction Stop | Out-Null
        $msg = "[SUCCESS] User $UserID access has been remove to $Safe"; Write-Host $msg -ForegroundColor "Green"; Out-LogWrite -message $msg -LogFileName $LogFileName}
        catch {$msg = "[ERROR] Couldn't remove user $UserID access to $Safe"; Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName
			   #Write-Host "[DEBUG] Printing error: $_.Exception.Message" -ForegroundColor "Magenta"
			  }
     } else {
        $msg = "[INFO] User $UserID does not exist in $Safe, no need to remove access"; Write-Host $msg -ForegroundColor "Cyan"; Out-LogWrite -message $msg -LogFileName $LogFileName
     }
}

function Set-AssignSafeMember
{
<#

.DESCRIPTION:
    This function sets new permissions to a user in a safe.
    If the user is defined in CyberArk but not added to this safe, user will be added, and then granted permissions as defined in the $Role:
    - User: Access to use resources in the safe, list all users, and view audit trails.
    - Owner: Access to manage resources in the safe, unlock accounts, and manage users access.
    - System: All permissions are granted (meant for system accounts, such as PVWA default accounts ...)

#>
     [CmdletBinding()]
     param (
           [string] $UserID,
           [string] $Safe,
           [string] $Role
     )

  # Check if user is already a member
  try   {$safeContent = $token | Get-PASSafeMembers -SafeName $Safe -ErrorAction Stop}
  catch {Write-Host "[ERROR] Couldn't access safe $Safe" -ForegroundColor "Red"}
  if (-not ($safeContent.Username -contains $UserID)) {

      # User is not there, add with Zero Permissions
      try {$Token | Add-PASSafeMember -SafeName $Safe -MemberName $UserID `
      -UseAccounts $false -RetrieveAccounts $false -ListAccounts $false `
      -AddAccounts $false -UpdateAccountContent $false -UpdateAccountProperties $false `
      -InitiateCPMAccountManagementOperations $false -SpecifyNextAccountContent $false `
      -RenameAccounts $false -DeleteAccounts $false -UnlockAccounts $false -ManageSafe $false `
      -ManageSafeMembers $false -BackupSafe $false -ViewAuditLog $false -ViewSafeMembers $false -ErrorAction Stop | Out-Null}
      catch {
        $msg = "[ERROR] Couldn't add $UserID to $Safe"; Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName
      }

  } else {

      # User is there , clearing permissions
      try {$Token | Set-PASSafeMember -SafeName $Safe -MemberName $UserID `
      -UseAccounts $false -RetrieveAccounts $false -ListAccounts $false `
      -AddAccounts $false -UpdateAccountContent $false -UpdateAccountProperties $false `
      -InitiateCPMAccountManagementOperations $false -SpecifyNextAccountContent $false `
      -RenameAccounts $false -DeleteAccounts $false -UnlockAccounts $false -ManageSafe $false `
      -ManageSafeMembers $false -BackupSafe $false -ViewAuditLog $false -ViewSafeMembers $false -ErrorAction Stop | Out-Null}
      catch {$msg = "[ERROR] Couldn't set zero permissions $UserID to $Safe"; Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName}
  }

      # Assign member permissions based on $Role input
      switch ($Role)
      {
        "User" {
          try{$Token | Set-PASSafeMember -SafeName $Safe -MemberName $UserID `
          -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true `
          -ViewAuditLog $true -ViewSafeMembers $true -ErrorAction Stop | Out-Null
          $msg = "[SUCCESS] User $UserID permissions were changed to $Role in $Safe"; Write-Host $msg -ForegroundColor "Green"; Out-LogWrite -message $msg -LogFileName $LogFileName
          }
          catch {$msg = "[ERROR] Couldn't assign $Role permissions to $UserID in $Safe"; Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName}
        }
        "Owner" {
          try {$Token | Set-PASSafeMember -SafeName $Safe -MemberName $UserID `
          -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true `
          -UpdateAccountContent $true -UpdateAccountProperties $true `
          -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true `
          -UnlockAccounts $true -ViewAuditLog $true -ViewSafeMembers $true -ErrorAction Stop | Out-Null
          $msg = "[SUCCESS] User $UserID permissions were changed to $Role in $Safe"; Write-Host $msg -ForegroundColor "Green"; Out-LogWrite -message $msg -LogFileName $LogFileName
          }
          catch {$msg = "[ERROR] Couldn't assign $Role permissions to $UserID in $Safe"; Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName}
        }
        "System" {
          try{$Token | Set-PASSafeMember -SafeName $Safe -MemberName $UserID `
          -UseAccounts $true -RetrieveAccounts $true -ListAccounts $true `
          -AddAccounts $true -UpdateAccountContent $true -UpdateAccountProperties $true `
          -InitiateCPMAccountManagementOperations $true -SpecifyNextAccountContent $true `
          -RenameAccounts $true -DeleteAccounts $true -UnlockAccounts $true -ManageSafe $true `
          -ManageSafeMembers $true -BackupSafe $true -ViewAuditLog $true -ViewSafeMembers $true -ErrorAction Stop | Out-Null
          $msg = "[SUCCESS] User $UserID permissions were changed to $Role in $Safe"; Write-Host $msg -ForegroundColor "Green"; Out-LogWrite -message $msg -LogFileName $LogFileName
          }
          catch {$msg = "[ERROR] Couldn't assign $Role permissions to $UserID in $Safe"; Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName}
        }
      }
}

function Set-BulkChangeSafeMembership
{

<#

.DESCRIPTION:
    This function loads changes from an excel file (based on the sample file in .\Templates\ folder),
    executes permission changes as requested, and generates a log file in .\Logs\ folder with the results

#>

     [CmdletBinding()]
     param (
           [string] $FilePath
     )

     ### Loading file
     if (test-path $filepath) {
          $extn = [IO.Path]::GetExtension($filepath)
          switch ($extn)
          {
            ".csv"  {$file = Import-Csv $filepath}
            ".xls"	{$ws = Read-Host "Enter Worksheet Name, leave blank if there's only one" ; $file = Import-Excel -Filename $filepath -WorksheetName:$ws}
			      ".xlsx"	{$ws = Read-Host "Enter Worksheet Name, leave blank if there's only one" ; $file = Import-Excel -Filename $filepath -WorksheetName:$ws}
            default {Write-Output "[ERROR] File type is not supported" -ForegroundColor "Red"}
          }

      } else {
          Write-Output "$FilePath doesn't exist"}

     ### Confirm Action ###

     # Calculating number of changes per user (object count)
     $ChangesCount = ($file.UserID | measure).Count

     Write-Host " "
     Write-Host "Applying permission changes to $ChangesCount users as listed in your file"  -ForegroundColor "Yellow"
     Read-Host "Press Enter to continue..." | Out-Null

     # Log all changes in the following log file
     $LogfileName = "Bulk-Safe-Access-Changes-"+(Get-Date).toString("yyyy-MM-dd-HHmmss")+".txt"
     $Counter = 1
     foreach ($line in $file) {
        Write-Host "Entry number: $Counter"; $Counter++
        switch ($line.Action)
        {
            "Owner"   { Set-AssignSafeMember -Safe $line.Safe -UserID $line.UserID -Role "Owner" }

            "User"    { Set-AssignSafeMember -Safe $line.Safe -UserID $line.UserID -Role "User" }

            "Remove"  { Remove-SafeMember -Safe $line.Safe -UserID $line.UserID }

            Default   { $msg = "[ERROR] Action is not defined:("+($line.Action)+")for user"+($line.UserID)+"and safe"+($line.Safe);
                        Write-Host $msg -ForegroundColor "Red"; Out-LogWrite -message $msg -LogFileName $LogFileName}
	     }

     }
     Write-Host "Log file has been created in "$PSScriptRoot"\Logs\$logfilename" -ForegroundColor "Yellow"
}

function set-BulkUploadAccounts
{

<#

.DESCRIPTION:
    This function loads new accounts from an excel file (based on the sample file in .\Templates\ folder),
    adds each account to the respective safe, and generates a log file in .\Logs\ folder with the results

    NOTE: This function was borrowed from PUU 2, with slight changes. I couldn't test it with this tool
    If you want to test it, uncomment each line tagged with [DEV] in the main code
#>

  [CmdletBinding()]
  param (
        [string] $FilePath
  )

  ### Loading file
  if (test-path $filepath) {
       $extn = [IO.Path]::GetExtension($filepath)
       switch ($extn)
       {
         ".csv"  {$file = Import-Csv $filepath}
         ".xls"	 {$ws = Read-Host "Enter Worksheet Name, or the first worksheet will be imported by default" ; $file = Import-Excel -Filename $filepath -WorksheetName:$ws}
         ".xlsx" {$ws = Read-Host "Enter Worksheet Name, or the first worksheet will be imported by default" ; $file = Import-Excel -Filename $filepath -WorksheetName:$ws}
         default {Write-Output "[ERROR] File type is not supported" -ForegroundColor "Red"}
       }

   } else {
       Write-Output "$FilePath doesn't exist"}

  # Count the number of rows in the Excel File
  $rowCount = $file.Count
  $counter = 0

  ## STEP THROUGH EACH ROW
  foreach ($row in $file) {

      # INCREMENT COUNTER
      $counter++

      # DEFINE VARIABLES FOR EACH VALUE
      $objectName             = $row.ObjectName
      $safe                   = $row.Safe
      $password               = $row.Password
      $platformID             = $row.PlatformID
      $address                = $row.Address
      $username               = $row.Username

      # If DisableAutoMgmt is yes or true, disable it.  Otherwise, ignore.
      if ($row.DisableAutoMgmt -eq "yes" -or $row.DisableAutoMgmt -eq "true") {
          $disableAutoMgmt = $true
      } else {
          $disableAutoMgmt = $false
      }
      if ($disableAutoMgmt -eq $true) {
          $disableAutoMgmtReason = $row.DisableAutoMgmtReason
      } else {
          $disableAutoMgmtReason = ""
      }

      #CHECK IF ACCOUNT ALREADY EXISTS IN VAULT
      $getResult = Get-PASRESTGetAccount -Authorization $sessionID -Address $address -Username $username -Safe $safe
      if ($getResult -ne $false) {
          # If results are returned matching the specific username and address combination, break to the next row.
          if([int]$getResult.Count -le 0) { Write-Host "[ERROR] Username ${username}@${address} already exists in the Vault." -ForegroundColor "Red"; continue }
      }

      # ADD ACCOUNT TO VAULT
      $addResult = Add-PASRESTAddAccount -Authorization $sessionID -ObjectName $objectName -Safe $safe -PlatformID $platformID -Address $address -Username $username -Password $password -DisableAutoMgmt $disableAutoMgmt -DisableAutoMgmtReason $disableAutoMgmtReason
      # If nothing is returned, there was an error and it will break to next row.
      if ($addResult -eq $false) { Write-Host "[ERROR] There was an error adding ${username}@${address} into the Vault." -ForegroundColor "Red"; continue }
      else { Write-Host "[SUCCESS] [${counter}/${rowCount}] Added ${username}@${address} successfully." -ForegroundColor "Green" }
  }
}

function Add-PASRESTAddAccount
{

<#

.DESCRIPTION:
    This function adds an account to a safe

    NOTE: This function was borrowed from PUU 2, with slight changes. I couldn't test it with this tool
    If you want to test it, uncomment each line tagged with [DEV] in the main code
#>

    [CmdletBinding()]
    param (
          [string]$ObjectName,
          [string]$Safe,
          [string]$PlatformID,
          [string]$Address,
          [string]$Username,
          [string]$Password,
          [boolean]$DisableAutoMgmt,
          [string]$DisableAutoMgmtReason
    )
    # Declaration
    $webServicesAddAccount = "$baseURL/PasswordVault/WebServices/PIMServices.svc/Account"
    $Authorization = $sessionID

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$Authorization)
    $bodyParams = @{account = @{safe = $Safe; platformID = $PlatformID.Replace(" ",""); address = $Address; accountName = $ObjectName; password = $Password; username = $Username; disableAutoMgmt = $DisableAutoMgmt; disableAutoMgmtReason = $DisableAutoMgmtReason}} | ConvertTo-JSON -Depth 2

    # Execution
    try {
        $addAccountResult = Invoke-RestMethod -Uri $webServicesAddAccount -Method POST -ContentType "application/json" -Header $headerParams -Body $bodyParams -ErrorVariable addAccountResultErr
        return $addAccountResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

function Get-PASRESTGetAccount
{

<#

.DESCRIPTION:
    This function retrieves an account from a safe

    NOTE: This function was borrowed from PUU 2, with slight changes. I couldn't test it with this tool
    If you want to test it, uncomment each line tagged with [DEV] in the main code
#>

    [CmdletBinding()]
    param (
          [string]$Address,
          [string]$Username,
          [string]$Safe=""
    )
    # Declaration
    $webServicesGetAccount = "$baseURL/PasswordVault/WebServices/PIMServices.svc/Accounts"
    $Authorization = $sessionID

    # Authorization
    $headerParams = @{}
    $headerParams.Add("Authorization",$Authorization)
    $requestURI = "$($webServicesGetAccount)?Keywords=$($Address),$($Username)"
    if ($safe -ne "") {
        $requestURI = "$($requestURI)&Safe=$($Safe)"
    }
    # Execution
    Write-Host "Request URI: $($requestURI)"
    try {
        $getAccountResult = Invoke-RestMethod -Uri "$($requestURI)" -Method GET -Header $headerParams -ErrorVariable getAccountResultErr
        return $getAccountResult
    }
    catch {
        Write-Host "StatusCode:" $_.Exception.Response.StatusCode.value__
        Write-Host "StatusDescription:" $_.Exception.Response.StatusDescription
        Write-Host "Response:" $_.Exception.Message
        return $false
    }
}

Function Out-LogWrite
{

<#

.DESCRIPTION:
    This function takes log message and log file name as string inputs, and stamps it with time & date
    and attaches the log to the log file in .\Logs\

#>

   Param ([string]$message, [string]$LogfileName)
   $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
   $newlog = $Stamp+"-"+$message
   $filedir = "$PSScriptRoot\Logs\$LogfileName"

   Add-content $filedir -value $newlog
}

function OpenFile-Dialog($initialDirectory)
{

<#

.DESCRIPTION:
    This function opens file dialog to browse files and folders, filtered by csv by defualt
    and returns the file path

#>


    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "CSV (*.csv)| *.csv"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

#########         Main code         ##########

## Use TLS 1.2 instead of default 1.0
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

## Import module funtions
Write-Host "[INFO] Importing required modules ..." -ForegroundColor "Cyan"

try{ Import-module "$PSScriptRoot\psPAS" -ErrorAction Stop } catch { Write-Host "[ERROR] Couldn't load psPAS, make sure you're running script in the same directory" -ForegroundColor "Red"}
try{ Import-module "$PSScriptRoot\psCTU" -ErrorAction Stop } catch { Write-Host "[ERROR] Couldn't load psCTU, make sure you're running script in the same directory" -ForegroundColor "Red"}

Clear-Host
# SHOW ASCII ART
Show-CTUART

## USER INPUT
[System.Uri]$baseURL = Read-Host "Please enter your PVWA address (https://pvwa.CyberArk.local)"

#--> [TEMP] comment previous line & uncoment next one to hardcode your PVWA address if you want
#$baseURL = "https://pvwa.CyberArk.local"

if(-not (Test-Connection -computer $baseURL.host -Count 1 -quiet))
  {
    Write-Host "[ERROR] Server is not accessible." -ForegroundColor "Red";
    Exit
  }

Write-Host "[INFO] Server is accessible, enter credentials ..." -ForegroundColor "Cyan"

$cred = Get-Credential -Message "Please enter your REST API Username and Password"
$APIuser = $cred.Username

# START A NEW SESSION
Write-Host "[INFO] Connecting to PVWA server $baseURL ..." -ForegroundColor "Cyan"
try{
  $token = New-PASSession -Credential $cred -BaseURI $baseURL -ErrorAction Stop
  $sessionID = $token.sessionToken.Authorization
}

catch [Microsoft.PowerShell.Commands.WriteErrorException]{
  Write-Host "[WARNING] CTU could not establish a secure connection to your PVWA server." -ForegroundColor "Magenta"
  Read-Host "Presss Enter to ignore certificate verification and continue. (CTRL+C to exit)"| Out-Null
  [System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
  $token = New-PASSession -Credential $cred -BaseURI $baseURL
  $sessionID = $token.sessionToken.Authorization
}

catch{
  $errorMsg= $($_.Exception.Message)
  Write-Host "[ERROR] There is an error: $errorMsg" -ForegroundColor "Red"
  if ($errorMsg -eq "403") { Write-Host "[ERROR] Invalid credentials, wrong username or password." -ForegroundColor "Red" }
  # elseif ($errorMsg -eq "404") { TODO: add other http status errors }
}

if ($sessionID -ne $null)
{
  Write-Host "[Success] $APIuser is successfully connected to PVWA over RestAPI" -ForegroundColor "Green"
  Write-Host "Session ID: $sessionID" -ForegroundColor "DarkGreen"
  Write-Host " "
  Write-Host "[INFO] Loading CyberArk Terminal Utility..." -ForegroundColor "Cyan"

  Start-Sleep -m 5000
  Write-Host " "

    Do
    {
        Show-MainMenu
        $input = Read-Host "Please make a selection"
        switch ($input)
           {
               '1'   {
                       cls
                       Show-CTUHeader
                       'You chose option #1, function (Show-SafesMenu), options will be added soon!'

                      # [DEV] Comment previous line, uncomment next lines to show options

                      # Show-SafesMenu
                      # $input = Read-Host "Please make a selection"
                      #
                      # switch ($input)
                      # {
                      #   '1' { # Add safe
                      #
                      #       }
                      #   '2' { # Modify safe
                      #
                      #       }
                      #   '3' { # Remove safe
                      #
                      #       }
                       pause

           }   '2'   {
                       cls
                       Show-CTUHeader
                       'You chose option #2, function (Show-UsersMenu), options will be added soon!'
                       pause

           }   '3'   {
                       cls
                       Show-CTUHeader
                       Show-PermissionsMenu
                       $input = Read-Host "Please make a selection"
                       ## User chose from Users menu
                       switch ($input)
                       {
                         '1' {
                               ### > Get User inputs
                               Write-Host " "
                               $inSafe =   Read-Host "Enter Safe (SecureVault_123)"
                               Write-Host " "
                               $inUserID = Read-Host "Enter User ID (User123)"

                               ### Confirm Action ###
                               Write-Host " "
                               Write-Host "Assigning $inUserID as an Owner of safe $inSafe"  -ForegroundColor "Yellow"
                               Read-Host "Press Enter to continue..." | Out-Null

                               ### Pass inputs to function >
                               $LogfileName = "Change-user-access-to-a-safe-"+(Get-Date).toString("yyyy-MM-dd-HHmmss")+".txt"
                               Set-AssignSafeMember -Safe $inSafe -UserID $inUserID -Role "Owner"
                             }

                         '2' {
                               ### > Get User inputs
                               Write-Host " "
                               $inSafe =   Read-Host "Enter Safe (SecureVault_123)"
                               Write-Host " "
                               $inUserID = Read-Host "Enter User ID (User123)"

                               ### Confirm Action ###
                               Write-Host " "
                               Write-Host "Assigning $inUserID as a User in safe $inSafe"  -ForegroundColor "Yellow"
                               Read-Host "Press Enter to continue..." | Out-Null

                               ### Pass inputs to function >
                               $LogfileName = "Change-user-access-to-a-safe-"+(Get-Date).toString("yyyy-MM-dd-HHmmss")+".txt"
                               Set-AssignSafeMember -Safe $inSafe -UserID $inUserID -Role "User"
                             }

                         '3' {
                               ### > Get User inputs
                               Write-Host " "
                               $inSafe =   Read-Host "Enter Safe (SecureVault_123)"
                               Write-Host " "
                               $inUserID = Read-Host "Enter User ID (User123)"

                               ### Confirm Action ###
                               Write-Host " "
                               Write-Host "Removing $inUserID from accessing safe $inSafe"  -ForegroundColor "Yellow"
                               Read-Host "Press Enter to continue..." | Out-Null

                               ### Pass inputs to function >
                               $LogfileName = "Change-user-access-to-a-safe-"+(Get-Date).toString("yyyy-MM-dd-HHmmss")+".txt"
                               Remove-SafeMember -Safe $inSafe -UserID $inUserID
                             }

                         '4' {
                               ### > Get User inputs
                               $inSafe =   Read-Host "Enter Safe (SecureVault_123)"

                               ### Pass inputs to function to list all safe users >
                               Get-CountSafeUsers -Safe $inSafe
                             }

                         '5' {
							                 ### > Get User inputs
                               Write-Host "[INFO] File format should match the template in "$PSScriptRoot"\Templates\Bulk_permission_changes.csv" -ForegroundColor "Cyan"
                               pause
                               try{$filepath = OpenFile-Dialog($Env:CSIDL_DEFAULT_DOWNLOADS)}
                               catch{Write-Output "Invalid file name"}

              							   ### Pass inputs to function >
                               Set-BulkChangeSafeMembership -FilePath $filepath
                               Write-Host " "
                             }
                         'q' {continue}

                     default { Write-Host "The input is not defined!" -ForegroundColor "Red" }
                       }
           }   '4'   {
                       cls
                       Show-CTUHeader
                       'You chose option #4, function (Show-AccountsMenu), options will be added soon!'

                    # [DEV] Comment previous line, uncomment next lines to show options

                    #   Show-AccountsMenu
                    #   $input = Read-Host "Please make a selection"
                    #   ## User chose from Users menu
                    #   switch ($input)
                    #   {
                    #     '1' {
                    #           ### > Get User inputs
                    #           [string]$inObjectName = Read-Host "Enter Object Name"
                    #           [string]$inSafe = Read-Host "Enter Safe (SecureVault_123)"
                    #           [string]$inPlatformID = Read-Host "Enter PlateformID"
                    #           [string]$inAddress = Read-Host "Enter Address"
                    #           [string]$inUsername = Read-Host "Enter Username"
                    #           [string]$inPassword = Read-Host "Enter Password"
                    #           [boolean]$inDisableAutoMgmt = Read-Host "Disable Auto Management (Yes/No)"
                    #           [string]$inDisableAutoMgmtReason = Read-Host "Disable Auto Management Reason"
                    #
                    #           ### Confirm Action ###
                    #           Write-Host " "
                    #           Write-Host "Adding a new account $inUsername to safe $inSafe"  -ForegroundColor "Yellow"
                    #           Read-Host  "Press Enter to continue..." | Out-Null
                    #
                    #           ### Pass inputs to function >
                    #           Add-PASRESTAddAccount -ObjectName $inObjectName -Safe $inSafe -PlateformID $inPlatformID -Address $inAddress -Username $inUsername -Password $inPassword -DisableAutoMgmt $inDisableAutoMgmt -DisableAutoMgmtReason $inDisableAutoMgmtReason
                    #         }
                    #
                    #     '2' { ### [DEV] Below commands are just fillers
                    #
                    #           ### > Get User inputs
                    #           Write-Host " "
                    #           $inSafe =   Read-Host "Enter Safe (SecureVault_123)"
                    #           Write-Host " "
                    #           $inUserID = Read-Host "Enter User ID (User123)"
                    #
                    #           ### Confirm Action ###
                    #           Write-Host " "
                    #           Write-Host "Assigning $inUserID as an Owner of safe $inSafe"  -ForegroundColor "Yellow"
                    #           Read-Host  "Press Enter to continue..." | Out-Null
                    #
                    #           ### Pass inputs to function >
                    #           Set-AssignSafeMember -Safe $inSafe -UserID $inUserID -Role "Owner"
                    #         }
                    #
                    #     '3' {
                    #           ### > Get User inputs
                    #           Write-Host " "
                    #           $inSafe =   Read-Host "Enter Safe (SecureVault_123)"
                    #           Write-Host " "
                    #           $inUserID = Read-Host "Enter User ID (User123)"
                    #
                    #           ### Confirm Action ###
                    #           Write-Host " "
                    #           Write-Host "Assigning $inUserID as an Owner of safe $inSafe"  -ForegroundColor "Yellow"
                    #           Read-Host  "Press Enter to continue..." | Out-Null
                    #
                    #           ### Pass inputs to function >
                    #           Set-AssignSafeMember -Safe $inSafe -UserID $inUserID -Role "Owner"
                    #         }
                    #
                    #     '4' {
                    #           ### > Get User inputs
                    #           Write-Host " "
                    #           $inSafe =   Read-Host "Enter Safe (SecureVault_123)"
                    #           Write-Host " "
                    #           $inUserID = Read-Host "Enter User ID (User123)"
                    #
                    #           ### Confirm Action ###
                    #           Write-Host " "
                    #           Write-Host "Assigning $inUserID as an Owner of safe $inSafe"  -ForegroundColor "Yellow"
                    #           Read-Host  "Press Enter to continue..." | Out-Null
                    #
                    #           ### Pass inputs to function >
                    #           Set-AssignSafeMember -Safe $inSafe -UserID $inUserID -Role "Owner"
                    #         }
                    #
                    #     '5' {
                    #           ### > Get User inputs
                    #           Write-Host " "
                    #           $inSafe =   Read-Host "Enter Safe (SecureVault_123)"
                    #           Write-Host " "
                    #           $inUserID = Read-Host "Enter User ID (User123)"
                    #
                    #           ### Confirm Action ###
                    #           Write-Host " "
                    #           Write-Host "Assigning $inUserID as an Owner of safe $inSafe"  -ForegroundColor "Yellow"
                    #           Read-Host "Press Enter to continue..." | Out-Null
                    #
                    #           ### Pass inputs to function >
                    #           Set-AssignSafeMember -Safe $inSafe -UserID $inUserID -Role "Owner"
                    #         }
                    #
                    #     '6' {

                    #            ### > Get User inputs
                    #            Write-Host "[INFO] File format should match the template in "$PSScriptRoot"\Templates\Bulk_upload_passwords.csv" -ForegroundColor "Cyan"
                    #            pause
                    #            try{$filepath = OpenFile-Dialog($Env:CSIDL_DEFAULT_DOWNLOADS)}
                    #            catch{Write-Output "Invalid file name"}
                    #
                    #            ### Pass inputs to function >
                    #            set-BulkUploadAccounts -FilePath $filepath
                    #            Write-Host " "

                    #         }
                    #
                    #     'Q' {continue}
                    # default { Write-Host "The input is not defined!" -ForegroundColor "Red" }
                    # }

                       pause

           }   'd'   {
                       cls
                       Show-CTUHeader
                       Write-Host "RestAPI Session ID: $sessionID "  -ForegroundColor "Yellow"
                       Write-Host "---------------------------------------------"
                       Write-Host " "
                       Write-Host "Session is established to $baseURL using ($APIuser) credentials" -ForegroundColor "Yellow"
                       Write-Host "---------------------------------------------"
                       Write-Host " "
                       pause
           }   'q'   {
                       continue
           } default {
                       Write-Host "The input is not defined!" -ForegroundColor "Red"
                     }
           }
	pause
   }
    until ($input -eq 'q')
}

#<------------->#

# CLOSE REST-API SESSION
try{
  $token | Close-PASSession -ErrorAction Stop
}
catch{
  $errorMsg= $($_.Exception.Message)
  Write-Host "[ERROR] There was an error: $errorMsg" -ForegroundColor "Red"
  Write-Host " "
}

Write-Host " "
Write-Host "=============================================" -ForegroundColor "Yellow"
Write-Host "Session Closed, User $APIuser logged out" -ForegroundColor "Yellow"
Write-Host " "
