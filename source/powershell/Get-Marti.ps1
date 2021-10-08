
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




function Get-MartiItem
{
    Param( 
        [Parameter(Mandatory)][PSCustomObject] $MartiDefintiion,
        [Parameter(Mandatory)][String] $Title,
        [String] $DocumentName,
        [String] $Format,
        [String] $LogPath
    
    ) 

    $script:LogPathName = $LogPath

    Write-Debug "Parameter: LogPath   Value: $LogPath "
    Open-Log
    Write-Log "Function 'Get-MartiItem' parameters follow"
    Write-Log "Parameter: DocumentName   Value: $DocumentName "
    Write-Log "Parameter: Filter   Value: $Filter "
    Write-Log ""


    if ($null -eq $MartiDefintiion) {
        $Global:MartiErrorId = "MRI2101"
        $message = "No Marti definition supplied"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }
        
    
    if ($null -eq $MartiDefintiion.resources -or $MartiDefintiion.resources.Count -lt 1) {
        $Global:MartiErrorId = "MRI2102"
        $message = "No documents listed"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }

    [System.Collections.ArrayList]$lresource = @()

    $MartiDefintiion.resources | ForEach-Object {

        if ($null -eq $Format -or $Format -eq "*" -or $Format -eq $_.format ) {
            if ($Title -ne "*" -and $_.title -eq $Title) {
                $lresource += $_
            } else {
                if ($DocumentName -ne "*" -and $_.documentName -eq $DocumentName) {
                    $lresource += $_
                }
            }
        }

    }

    Close-Log
    return $lresource
}

