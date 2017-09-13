<#
.SYNOPSIS:
    Similar to Import-CSV but for Excel files

.Description:
    The function takes an Excel file (xls,xlsx) and returns array of objects, where each property name,
    represented by first row of the Excel spreadsheet.

    Import-Excel [-FileName]:Path [-WorksheetName:"Name"] [-DisplayProgress:$true|$false]

.INPUTS:
    -FileName – path to the Excel file. Since the code uses Excel Com-object, any format supported by local installation of Excel is compatible
    -WorksheetName – name of the spreadsheet to load. if not name declared, the first one will be loaded
    -DisplayProgress – switch $true or $false to display or not the progress of the load process

.OUTPUTS:
    The function returns array of objects, where each property name, represented by first row of the Excel spreadsheet.
    Reference:        https://podlisk.wordpress.com/2011/11/20/import-excel-spreadsheet-into-powershell/

.EXAMPLE:
    Usage examples:

    [PS] C:\>$reportLines = Import-Excel C:\Document\my-report.xls
        – will import the content of the first spreadsheet from the file, found at “C:\Document\my-report.xls” into $reportLines variable

    [PS] C:\>$users = Import-Excel C:\Document\users.xlsx -WorksheetName:"HQ"
        – will import the content of the first “HQ” spreadsheet from the “C:\Document\users.xlsx” file into $users variable
#>

function Import-Excel
{
  param (
    [string]$FileName,
    [string]$WorksheetName,
    [bool]$DisplayProgress = $true
  )

  if ($FileName -eq "") {
    throw "Please provide path to the Excel file"
    Exit
  }

  if (-not (Test-Path $FileName)) {
    throw "Path '$FileName' does not exist."
    exit
  }

  $FileName = Resolve-Path $FileName
  $excel = New-Object -com "Excel.Application"
  $excel.Visible = $false
  $workbook = $excel.workbooks.open($FileName)

  if (-not $WorksheetName) {
    Write-Warning "Defaulting to the first worksheet in workbook."
    $sheet = $workbook.ActiveSheet
  } else {
    $sheet = $workbook.Sheets.Item($WorksheetName)
  }

  if (-not $sheet)
  {
    throw "Unable to open worksheet $WorksheetName"
    exit
  }

  $sheetName = $sheet.Name
  $columns = $sheet.UsedRange.Columns.Count
  $lines = $sheet.UsedRange.Rows.Count

  Write-Warning "Worksheet $sheetName contains $columns columns and $lines lines of data"

  $fields = @()

  for ($column = 1; $column -le $columns; $column ++) {
    $fieldName = $sheet.Cells.Item.Invoke(1, $column).Value2
    if ($fieldName -eq $null) {
      $fieldName = "Column" + $column.ToString()
    }
    $fields += $fieldName
  }

  $line = 2


  for ($line = 2; $line -le $lines; $line ++) {
    $values = New-Object object[] $columns
    for ($column = 1; $column -le $columns; $column++) {
      $values[$column - 1] = $sheet.Cells.Item.Invoke($line, $column).Value2
    }

    $row = New-Object psobject
    $fields | foreach-object -begin {$i = 0} -process {
      $row | Add-Member -MemberType noteproperty -Name $fields[$i] -Value $values[$i]; $i++
    }
    $row
    $percents = [math]::round((($line/$lines) * 100), 0)
    if ($DisplayProgress) {
      Write-Progress -Activity:"Importing from Excel file $FileName" -Status:"Imported $line of total $lines lines ($percents%)" -PercentComplete:$percents
    }
  }
  $workbook.Close()
  $excel.Quit()
}
