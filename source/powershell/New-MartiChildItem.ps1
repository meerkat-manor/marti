
function New-MartiChildItem
{
Param( 
    [Parameter(Mandatory)][String] $SourceFolder,
    [String] $Filter ="*",
    [String] $UrlPath,
    [switch] $Recurse,
    [switch] $ExtendAttributes,
    [switch] $ExcludeHash,
    [String] $LogPath

) 
    $script:LogPathName = $LogPath

    Write-Debug "Parameter: LogPath   Value: $LogPath "
    Open-Log
    Write-Log "Function 'New-MartiDefinition' parameters follow"
    Write-Log "Parameter: SourceFolder   Value: $SourceFolder "
    Write-Log "Parameter: Filter   Value: $Filter "
    Write-Log "Parameter: Recurse   Value: $Recurse "
    Write-Log "Parameter: ExtendAttributes   Value: $ExtendAttributes "
    Write-Log "Parameter: ExcludeHash   Value: $ExcludeHash "
    Write-Log ""

    $oMarti = New-MartiDefinition
    $lresource = $oMarti.resources

    $SourceFullName = (Get-Item -Path $SourceFolder).FullName

    Get-ChildItem $SourceFolder -Filter $Filter -Recurse:$Recurse -Force| Where-Object {!$_.PSIsContainer} | ForEach-Object {

        $oResource = New-MartiResource -SourcePath $_.FullName -UrlPath $remoteDirectory -LogPath $LogPath -ExtendAttributes:$ExtendAttributes -ExcludeHash:$ExcludeHash

        if ($null -ne $UrlPath -and $UrlPath -ne "") {
            $postfixName = $_.FullName.Replace($SourceFullName, "")
            if ($postfixName[0] -eq "/" -or $postfixName[0] -eq "`\" ){
                $postfixName = $postfixName.Substring(1, ($postfixName.Length-1))
            }
            if ($UrlPath[$UrlPath.Length-1] -eq "/" -or $UrlPath[$UrlPath.Length-1] -eq "`\") {
                $oResource.url = $UrlPath.Replace("`\", "/") + $postfixName.Replace("`\", "/")
            } else {
                $oResource.url = $UrlPath.Replace("`\", "/") + "/" + $postfixName.Replace("`\", "/")
            }
        }

        $lresource += $oResource
        
    }
    Write-Log "Captured $($lresource.Count) items"
    $oMarti.resources = $lresource

    Close-Log

    return $oMarti

}

