

function Compress-MartiLQ
{
Param( 
    [Parameter(Mandatory)][String] $SourceFolder,
    [Parameter(Mandatory)][String] $ArchiveFile,
    [String] $Filter ="*",
    [switch] $ExcludeHash,
    [String] $LogPath

) 
    $script:LogPathName = $LogPath

    Write-Debug "Parameter: LogPath   Value: $LogPath "
    Open-Log
    Write-Log "Function 'Compress-MartiLQ' parameters follow"
    Write-Log "Parameter: SourceFolder   Value: $SourceFolder "
    Write-Log "Parameter: ArchiveFile   Value: $ArchiveFile "
    Write-Log "Parameter: Filter   Value: $Filter "
    Write-Log ""

    $marti_mri = $global:default_metaFile

    $oMarti = New-MartiDefinition -SourceFolder $SourceFolder -Filter $Filter -LogPath $LogPath
    $oMarti.description = "Sample execution"
    
    $fullMetadatName = Join-Path -Path (Split-Path -Path $ArchiveFile -Parent) -ChildPath $marti_mri
    $x = ConvertTo-Json -InputObject $oMarti
    Add-Content -Path $fullMetadatName -Value $x
 
    $getEnvName = $(Get-SoftwareName) + "_7ZIPLEVEL"
    if ([System.Environment]::GetEnvironmentVariable($getEnvName) -ne "" -and $null -ne [System.Environment]::GetEnvironmentVariable($getEnvName)) {
        $7zipLevel = [System.Environment]::GetEnvironmentVariable($getEnvName)
        Write-Log "Compression level set to '$7zipLevel'"
    } else {
        $7zipLevel = "Normal"
    }

    $getEnvName = $(Get-SoftwareName) + "_ZIPFORMAT"
    if ([System.Environment]::GetEnvironmentVariable($getEnvName) -ne "" -and $null -ne [System.Environment]::GetEnvironmentVariable($getEnvName)) {
        $7zipFormat = [System.Environment]::GetEnvironmentVariable($getEnvName)
        Write-Log "Compression format set to '$7zipFormat'"
    } else {
        $7zipFormat= "SevenZip"
        $7zipFormat= "Zip"
    }

    Compress-7Zip -Path $SourceFolder -ArchiveFileName $ArchiveFile  -Format $7zipFormat -CompressionLevel $7zipLevel -Filter $Filter 
    
    Compress-7Zip -Path $fullMetadatName -ArchiveFileName $ArchiveFile -PreserveDirectoryRoot -Format $7zipFormat  -CompressionLevel $7zipLevel -Append 

    Remove-Item -Path $fullMetadatName

    Close-Log
}


