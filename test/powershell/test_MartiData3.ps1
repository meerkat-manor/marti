
. .\source\powershell\New-Marti.ps1
. .\source\powershell\ConvertFrom-Ckan.ps1
. .\source\powershell\Compare-MartiResource.ps1


$covidFile = ".\test\powershell\results\data\covid-case-locations-20210920-1315.json"

$x = New-MartiItem -SourcePath $covidFile -UrlPath "" -ExcludeHash -LogPath ".\test\powershell\results\Logs"

[System.Collections.ArrayList] $attr = Set-MartiAttribute -Attributes $x.resources[0].attributes -ACategory "dataset" -AName "records" -AFunction "count" -comparison "EQ" -value 516
$attr = Set-MartiAttribute -Attributes $attr -ACategory "dataset" -AName "columns" -AFunction "count" -comparison "EQ" -value 12
$x.resources[0].attributes = Set-MartiAttribute -Attributes $attr -ACategory "format" -AName "list" -AFunction "offset" -comparison "EQ" -value "data.monitor"

$y = Compare-MartiResource -DataSource $covidFile -Resource $x.resources[0] -LogPath ".\test\powershell\results\Logs"  
$y

$attr | Get-Member