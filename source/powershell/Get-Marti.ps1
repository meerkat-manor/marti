
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




function Get-MartChildResource
{
    Param( 
        [Parameter(Mandatory)][PSCustomObject] $Marti,
        [Parameter(Mandatory)][String] $Title,
        [String] $ResourceName,
        [String] $Format = "*",
        [String] $LogPath
    
    ) 

    $script:LogPathName = $LogPath

    Write-Debug "Parameter: LogPath   Value: $LogPath "
    Open-Log
    Write-Log "Function 'Get-MartiItem' parameters follow"
    Write-Log "Parameter: ResourceName   Value: $ResourceName "
    Write-Log "Parameter: Format   Value: $Format "
    Write-Log ""


    if ($null -eq $Marti) {
        $Global:MartiErrorId = "MRI2101"
        $message = "No Marti definition supplied"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }
        
    
    if ($null -eq $Marti.resources -or $Marti.resources.Count -lt 1) {
        $Global:MartiErrorId = "MRI2102"
        $message = "No documents listed"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }

    [System.Collections.ArrayList]$lresource = @()

    $Marti.resources | ForEach-Object {

        if ($Format -eq "*" -or $Format -eq $_.format ) {
            if ($Title -ne "*" -and $_.title -eq $Title) {
                $lresource += $_
            } else {
                if ($ResourceName -ne "*" -and $_.documentName -eq $ResourceName ) {
                    $lresource += $_
                }
            }
        }

    }

    Close-Log
    return $lresource
}


function Get-MartiResource {
    Param (
        # Marti definition
        [Parameter(Mandatory)] [PSCustomObject] $Marti,
        # Resource ID
        [Parameter(Mandatory)] [String] $ResourceName
    )

    $script:LogPathName = $LogPath

    Write-Debug "Parameter: LogPath   Value: $LogPath "
    Open-Log
    Write-Log "Function 'Get-MartiResource' parameters follow"
    Write-Log "Parameter: ResourceName   Value: $ResourceName "
    Write-Log ""

    foreach ($item in $oMarti.resources) {
        if ($item.uid -eq $ResourceName -or $item.documentName -eq $ResourceName){
            Close-Log
            return $item
        }
    }

    Close-Log
    return $null
}
