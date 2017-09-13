<#

.SYNOPSIS
CTU Headers

.DESCRIPTION
This function contains all headers that will be printed on screen when called

.INPUTS
None

.OUTPUTS
Prints CTU Headers

#>
function Show-CTUART
{
     param (
           [string] $Title = 'Main Menu'
     )

Write-Host " "
Write-Host "=============================================" -ForegroundColor "Yellow"
write-host @"

 _____       _                ___       _
/  __ \     | |              / _ \     | |
| /  \/_   _| |__   ___ _ __/ /_\ \_ __| | __
| |   | | | | '_ \ / _ \ '__|  _  | '__| |/ /
| \__/\ |_| | |_) |  __/ |  | | | | |  |   <
 \____/\__, |_.__/ \___|_|  \_| |_/_|  |_|\_\
        __/ |
       |___/
 _____                   _             _
|_   _|                 (_)           | |
  | | ___ _ __ _ __ ___  _ _ __   __ _| |
  | |/ _ \ '__| '_ ` _ \| | '_ \ / _` | |
  | |  __/ |  | | | | | | | | | | (_| | |
  \_/\___|_|  |_| |_| |_|_|_| |_|\__,_|_|


  _   _ _   _ _ _ _
 | | | | | (_) (_) |
 | | | | |_ _| |_| |_ _   _      CTU v1.0
 | | | | __| | | | __| | | |
 | |_| | |_| | | | |_| |_| |    > Website:
  \___/ \__|_|_|_|\__|\__, |    github.com/
                       __/ |    zshehri/CTU
                      |___/

"@
Write-Host "=============================================" -ForegroundColor "Yellow"
Write-Host " "

# https://github.com/zshehri/CTU

}

function Show-CTUHeader
{
     param (
           [string] $Title = 'Main Menu'
     )
    cls
    Write-Host " "
    Write-Host "       CyberArk Terminal Utility v1.0" -ForegroundColor "Cyan"
    Write-Host " "
    Write-Host "           " (Get-Date -Format g) -ForegroundColor "Cyan"
    Write-Host " "

}
