
. .\source\powershell\MartiLQ.ps1
. .\source\powershell\MartiLQResource.ps1
. .\source\powershell\MartiLQAttribute.ps1
. .\source\powershell\MartiLQUtilities.ps1

try {

    $bsbFile = ".\test\powershell\results\data\BSBDirectorySep21-306.csv"

    Write-Host ">>>>>>Test case #1"
    $x = New-MartiResource -SourcePath $bsbFile -UrlPath "" -ExcludeHash -LogPath ".\test\powershell\results\Logs"

    Write-Host ">>>>>>Test case #2"
    $x

    [System.Collections.ArrayList] $Attr = Set-MartiAttribute -Attributes $x.attributes -ACategory "dataset" -AName "records" -AFunction "count" -comparison "EQ" -value 10
    $x.attributes = Set-MartiAttribute -Attributes $Attr -ACategory "dataset" -AName "columns" -AFunction "count" -comparison "EQ" -value 8

    Write-Host ">>>>>>Test case #3"
    $x.attributes

    Write-Host ">>>>>>Test case #4"
    $y = Compare-MartiResource -DataSource $bsbFile -Resource $x -LogPath ".\test\powershell\results\Logs"  
    $y

    $covidFile = ".\test\powershell\results\data\covid-case-locations-20210920-1315.json"

    Write-Host ">>>>>>Test case #5"
    $x = New-MartiResource -SourcePath $covidFile -UrlPath "" -ExcludeHash -LogPath ".\test\powershell\results\Logs"

    Write-Host ">>>>>>Test case #6"
    $x

    [System.Collections.ArrayList] $Attr = Set-MartiAttribute -Attributes $x.attributes -ACategory "dataset" -AName "records" -AFunction "count" -comparison "EQ" -value 10
    $x.attributes = Set-MartiAttribute -Attributes $Attr -ACategory "dataset" -AName "columns" -AFunction "count" -comparison "EQ" -value 8

    Write-Host ">>>>>>Test case #7"
    $x.attributes

    Write-Host ">>>>>>Test case #8"
    $y = Compare-MartiResource -DataSource $covidFile -Resource $x -LogPath ".\test\powershell\results\Logs"  
    $y

}
catch {
    throw 
}