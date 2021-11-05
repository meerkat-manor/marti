
. .\source\powershell\MartiLQ.ps1
. .\source\powershell\Compress-MartiLQ.ps1

try {
        
    Write-Host "Test case #1"
    $oMarti = New-MartiChildItem -SourceFolder ".\docs" -Recurse -UrlPath ".\docs" -Filter "*" -LogPath ".\test\powershell\results\Logs"
    $oMarti.description = "Sample execution"

    $x = ConvertTo-Json -InputObject $oMarti
    Set-Content -Path ".\test\powershell\results\marti_test01.json" -Value $x

    Write-Host "Test case #2"
    $ArchiveFile = ".\test\powershell\results\marti_test02.zip"
    Compress-MartiLQ  -SourceFolder ".\docs" -Filter "*" -LogPath ".\test\powershell\results\Logs" -ArchiveFile $ArchiveFile

    Write-Host "Test case #3"
    $y = Get-MartiItem -MartiDefintiion $oMarti -Title "ckan" -Format "txt" -LogPath ".\test\powershell\results\Logs"
    Write-Host "Get item Title: $($y.title)"
    Write-Host "Get item Url: $($y.url)"

    Write-Host "Test case #4"
    $oMarti = New-MartiResource -SourcePath ".\docs\ckan.md" -LogPath ".\test\powershell\results\Logs"
    $oMarti.description = "Sample execution for ckan"

    $x = ConvertTo-Json -InputObject $oMarti
    Set-Content -Path ".\test\powershell\results\marti_test02json.json" -Value $x

    $x = ConvertTo-Csv -InputObject $oMarti
    Set-Content -Path ".\test\powershell\results\marti_test02csv.json" -Value $x

    $x = ConvertTo-Xml -As String -InputObject $oMarti -Depth 6
    Set-Content -Path ".\test\powershell\results\marti_test02xml.json" -Value $x

    $x = ConvertTo-Html -InputObject $oMarti
    Set-Content -Path ".\test\powershell\results\marti_test02html.json" -Value $x

    Write-Host "Test case #5"
    $oMarti = New-MartiResource -SourcePath ".\docs\eror" -LogPath ".\test\powershell\results\Logs"
    $oMarti.description = "Sample execution with error"

    $x = ConvertTo-Json -InputObject $oMarti
    Set-Content -Path ".\test\powershell\results\marti_test03.json" -Value $x

}
catch {
    throw
}
