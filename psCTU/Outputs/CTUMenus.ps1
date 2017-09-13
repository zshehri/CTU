function Show-MainMenu
{
    <#
.SYNOPSIS
CTU MENU

.DESCRIPTION
This file contains all menus that will be printed on screen when called, including:
  - Main Menu
  - Safes Management Menu
  - Users Management Menu
  - Safe Permissions Management Menu
  - Vaulted Accounts Management Menu
  - Debug Information Screen

Inputs will be handeled through the main code.

.INPUTS
None

.OUTPUTS
Prints CTU Options

    #>

     param (
           [string] $Title = 'Main Menu'
     )
     cls
     Show-CTUHeader
     Write-Host " "
     Write-Host "================ $Title ================" -ForegroundColor "Yellow"
     Write-Host " "
     Write-Host " "
     Write-Host "1: Manage Safes (Add, Modify, Remove)"
     Write-Host " "
     Write-Host "2: Manage Users (Add, Modify, Remove)"
     Write-Host " "
     Write-Host "3: Manage Safe Permissions (Vault Ownership)"
     Write-Host " "
     Write-Host "4: Manage Vaulted Accounts (List, Add, Modify, Remove)"
     Write-Host " "
     Write-Host "D: Show debug information (Session ID, current user, etc...)"
     Write-Host " "
     Write-Host "Q: Press 'Q' to quit and logoff" -ForegroundColor "Yellow"
     Write-Host " "

}

function Show-SafesMenu
{
     param (
           [string] $Title = 'Safes Managment'
     )
     Write-Host " "
     Write-Host "================ $Title ================" -ForegroundColor "Yellow"
     Write-Host " "
     Write-Host " "
     Write-Host "1: Add a new safe"
     Write-Host " "
     Write-Host "2: Modify an existing safe"
     Write-Host " "
     Write-Host "3: Remove an existing safe"
     Write-Host " "
     Write-Host "Q: Press 'Q' to go back to main menu" -ForegroundColor "Yellow"
     Write-Host " "
}

function Show-UsersMenu
{
     param (
           [string] $Title = 'Users Managment'
     )
     Write-Host " "
     Write-Host "================ $Title ================" -ForegroundColor "Yellow"
     Write-Host " "
     Write-Host " "
     Write-Host "1: Add a new user"
     Write-Host " "
     Write-Host "2: Remove a user"
     Write-Host " "
     Write-Host "3: Modify user information"
     Write-Host " "
    # Write-Host "4: List all users who have access to a safe"
    # Write-Host " "
    # Write-Host "5: Change user's role or permissions (selecting from .\Templates\defined_roles.csv)"
    # Write-Host " "
    # Write-Host "6: (Bulk Change) Import users permissions from an Excel file (.csv/.xls/.xlsx are supported)" -ForegroundColor "Green"
    # Write-Host " "
     Write-Host "Q: Press 'Q' to go back to main menu" -ForegroundColor "Yellow"
     Write-Host " "
}

function Show-PermissionsMenu
{
     param (
           [string] $Title = 'Safe Permissions Managment'
     )
     Write-Host " "
     Write-Host "================ $Title ================" -ForegroundColor "Yellow"
     Write-Host " "
     Write-Host " "
     Write-Host "1: Assign owner to a safe"
     Write-Host " "
     Write-Host "2: Assign user to a safe"
     Write-Host " "
     Write-Host "3: Remove member from a safe"
     Write-Host " "
     Write-Host "4: List all users in a safe"
     Write-Host " "
     Write-Host "5: (Bulk Changes) Import users permissions from an Excel file (.csv/.xls/.xlsx are supported)" -ForegroundColor "Green"
     Write-Host " "
     Write-Host "Q: Press 'Q' to go back to main menu" -ForegroundColor "Yellow"
     Write-Host " "
}

function Show-AccountsMenu
{
     param (
           [string] $Title = 'Accounts Management'
     )
     Write-Host " "
     Write-Host "================ $Title ================" -ForegroundColor "Yellow"
     Write-Host " "
     Write-Host " "
     Write-Host "1: Add Account to an existing safe"
     Write-Host " "
     Write-Host "2: Modify Account Information"
     Write-Host " "
     Write-Host "3: Remove Account from a safe"
     Write-Host " "
     Write-Host "4: List Account information in a safe"
     Write-Host " "
     Write-Host "5: List all Accounts in a safe"
     Write-Host " "
     Write-Host "6: (Bulk Changes) Upload Accounts from an Excel file (.csv/.xls/.xlsx are supported)" -ForegroundColor "Green"
     Write-Host " "
     Write-Host "Q: Press 'Q' to go back to main menu" -ForegroundColor "Yellow"
     Write-Host " "
}
