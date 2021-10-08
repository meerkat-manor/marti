
. .\source\powershell\New-Marti.ps1
. .\source\powershell\ConvertFrom-Ckan.ps1
. .\source\powershell\Compare-MartiResource.ps1


$bsbFile = ".\test\powershell\results\data\bsb.csv"

Write-Host ">>>>>>Test case #1"
$x = New-MartiItem -SourcePath $bsbFile -UrlPath "" -ExcludeHash -LogPath ".\test\powershell\results\Logs"

Write-Host ">>>>>>Test case #2"
$x.resources

[System.Collections.ArrayList] $Attr = Set-MartiAttribute -Attributes $x.resources[0].attributes -ACategory "dataset" -AName "records" -AFunction "count" -comparison "EQ" -value 10
$x.resources[0].attributes = Set-MartiAttribute -Attributes $Attr -ACategory "dataset" -AName "columns" -AFunction "count" -comparison "EQ" -value 8

Write-Host ">>>>>>Test case #3"
$x.resources[0].attributes

Write-Host ">>>>>>Test case #4"
$y = Compare-MartiResource -DataSource $bsbFile -Resource $x.resources[0] -LogPath ".\test\powershell\results\Logs"  
$y

$covidFile = ".\test\powershell\results\data\covid-case-locations-20210920-1315.json"

Write-Host ">>>>>>Test case #5"
$x = New-MartiItem -SourcePath $covidFile -UrlPath "" -ExcludeHash -LogPath ".\test\powershell\results\Logs"

Write-Host ">>>>>>Test case #6"
$x.resources

[System.Collections.ArrayList] $Attr = Set-MartiAttribute -Attributes $x.resources[0].attributes -ACategory "dataset" -AName "records" -AFunction "count" -comparison "EQ" -value 10
$x.resources[0].attributes = Set-MartiAttribute -Attributes $Attr -ACategory "dataset" -AName "columns" -AFunction "count" -comparison "EQ" -value 8

Write-Host ">>>>>>Test case #7"
$x.resources[0].attributes

Write-Host ">>>>>>Test case #8"
$y = Compare-MartiResource -DataSource $covidFile -Resource $x.resources[0] -LogPath ".\test\powershell\results\Logs"  
$y
