

$script:LogPathName = ""

function Get-SoftwareName {
    return [String] "MARTIREFERENCE"
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
