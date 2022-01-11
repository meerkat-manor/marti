

$script:LogPathName = ""

function Get-SoftwareName {
    return [String] "MARTILQREFERENCE"
}


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


function New-LocalTempFile{
    Param (
        [Parameter(Mandatory)][String] $UrlPath, 
        $Configuration, 
        $TempPath
    )
    # Create temporary file on disk for cases
    # where file size, hashing and encryption are required
    # This is useful for (1) CKAN file fetch

    $parts = $UrlPath.split("/")
    $doc_name = $parts[$parts.Length-1]

    if ($null -eq $Configuration){
        $oConfig = Get-Configuration
    }

    if ($null -ne $TempPath){
        $temp_dir = $TempPath
    }
    else {
        $temp_dir = $oConfig.tempPath
    }

    if (!(Test-Path -Path $temp_dir)) {
        New-Item -Path $temp_dir -ItemType Directory
        Write-Log("Created temp folder : $temp_dir")
    }

    return Join-Path -Path $temp_dir -ChildPath $doc_name
}
