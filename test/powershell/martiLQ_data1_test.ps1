
. .\source\powershell\MartiLQ.ps1

if (!(Test-Path -Path ".\test\powershell\results\data")) {
    $null = New-Item -Path ".\test\powershell\results\data" -ItemType Directory
}

try {

    $bsbFile = ".\test\powershell\results\data\BSBDirectorySep21-306.csv"
    $data = Import-Csv -Path $bsbFile

    $columns = ($data | get-member -type NoteProperty).count
    $rows = @($data).count

    Write-Host "Rows: $rows  Columns: $columns"

    [System.Collections.ArrayList]$lattribute = @()

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "header"
        function = "count"
        comparison = "EQ"
        value = 0
    }

    $lattribute += $oAttribute

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "footer"
        function = "count"
        comparison = "EQ"
        value = 0
    }

    $lattribute += $oAttribute

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "rows"
        function = "count"
        comparison = "EQ"
        value = $rows
    }

    $lattribute += $oAttribute

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "columns"
        function = "count"
        comparison = "EQ"
        value = $columns
    }

    $lattribute += $oAttribute

    $oAttribute = [PSCustomObject]@{
        category = "data"
        name = "BSB"
        function = "sum"
        comparison = "EQ"
        value = 1032092
    }

    $lattribute += $oAttribute

    $oAttribute = [PSCustomObject]@{
        category = "data"
        name = "BSB"
        function = "unique"
        comparison = "EQ"
        value = $rows
    }

    $lattribute += $oAttribute



    $uq = Get-Content $bsbFile | ConvertFrom-Csv -Header "C1", "C2" | Select-Object "C2" | Sort-Object "C2" -Unique | Group-Object -Property "C2" 
    $oAttribute = [PSCustomObject]@{
        category = "data"
        name = "Institution"
        function = "unique"
        comparison = "EQ"
        value = $uq.Count
    }

    $lattribute += $oAttribute

    $x = ConvertTo-Json -InputObject $lattribute

}
catch {
    throw
}