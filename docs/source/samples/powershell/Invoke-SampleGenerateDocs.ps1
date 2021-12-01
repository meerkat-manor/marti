
. .\source\powershell\MartiLQ.ps1

try {
       
    $describe = "Generate martiLQ definition for DOCS folder " 
    Write-Host $describe
    $oMarti = New-MartiChildItem -SourceFolder "./docs/source" -UrlPath "/docs" -Filter "*.md" -LogPath "./docs/source/samples/powershell/test/Logs" -ExtendAttributes:$true
    $oMarti.description = $describe

    $jsonFile = "./docs/source/samples/powershell/test/martilq_docs.json"
    $x = ConvertTo-Json -InputObject $oMarti -Depth 6
    Set-Content -Path $jsonFile -Value $x
 
    Write-Host "martiLQ definition written to '$jsonFile' "

}
catch {
    throw
}
