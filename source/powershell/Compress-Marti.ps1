
$script:LogPathName = ""
$script:SoftwareVersion = "0.0.1"

$global:default_metaFile = "##marti##.mri"

function Get-LogName {

    $date = Get-Date -f "yyyy-MM-dd"
    
    if (($null -eq $script:LogPathName) -or ($script:LogPathName -eq ""))
    {
        return $null
    }

    if (!(Test-Path -Path $script:LogPathName)) {
        $null = New-Item -Path $script:LogPathName -ItemType Directory
    }

    $logName = $(Get-SoftwareName) + "_$date.log"

    return Join-Path -Path $script:LogPathName -ChildPath $logName 
}


function Write-Log {
    param(
        [String] $LogEntry
    )

    $sFullPath = Get-LogName 

    $dateTime = Get-Date -f "yyyy-MM-dd HH:mm:ss"
    if ($null -ne $sFullPath -and $sFullPath -ne "") {

        if (!(Test-Path -Path $sFullPath)) {
            Write-Host "Log path: $sFullPath"
            $null = New-Item -Path $sFullPath -ItemType File      
        }
        Add-Content -Path $sFullPath -Value "[$dateTime]. $LogEntry"
    }
    Write-Debug "[$dateTime]. $LogEntry"

}

function Open-Log {
    $dateTime = Get-Date -f "yyyy-MM-dd HH:mm:ss"
    Write-Log "***********************************************************************************"
    Write-Log "*   Start of processing: [$dateTime]"
    Write-Log "***********************************************************************************"
}

function Close-Log {
    $dateTime = Get-Date -f "yyyy-MM-dd HH:mm:ss"
    Write-Log "***********************************************************************************"
    Write-Log "*   End of processing: [$dateTime]"
    Write-Log "***********************************************************************************"
}

function Get-SoftwareName {
    return [String] "MARTIREFERENCE"
}


function Compress-Marti
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
    Write-Log "Function 'Compress-Marti' parameters follow"
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


