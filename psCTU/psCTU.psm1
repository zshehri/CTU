<#
.SYNOPSIS

.DESCRIPTION

.EXAMPLE

.INPUTS

.OUTPUTS

.NOTES

.LINK

#>
[CmdletBinding()]
param()

#Get function files
Get-ChildItem $PSScriptRoot\ -Recurse -Filter "*.ps1" |

    ForEach-Object {

        Try{

            #Dot Source each file
            . $_.fullname

        }

        Catch{

            Write-Error "Failed to import function $($_.fullname)"

        }


    }
