
. .\source\powershell\MartiLQ.ps1
. .\source\powershell\MartiLQResource.ps1
. .\source\powershell\MartiLQAttribute.ps1
. .\source\powershell\MartiLQUtilities.ps1


try {
        
    $covidFile = ".\test\powershell\results\data\covid-case-locations-20210920-1315.json"

    $x = New-MartiResource -SourcePath $covidFile -UrlPath "" -ExcludeHash -LogPath ".\test\powershell\results\Logs"

    [System.Collections.ArrayList] $attr = Set-MartiAttribute -Attributes $x.attributes -ACategory "dataset" -AName "records" -AFunction "count" -comparison "EQ" -value 516
    $attr = Set-MartiAttribute -Attributes $attr -ACategory "dataset" -AName "columns" -AFunction "count" -comparison "EQ" -value 12
    $x.attributes = Set-MartiAttribute -Attributes $attr -ACategory "format" -AName "list" -AFunction "offset" -comparison "EQ" -value "data.monitor"

    $y = Compare-MartiResource -DataSource $covidFile -Resource $x -LogPath ".\test\powershell\results\Logs"  
    $y

    $attr | Get-Member

} 
catch {
    throw
}