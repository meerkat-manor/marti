
$script:LogPathName = ""
$script:SoftwareVersion = "0.0.1"

$global:default_metaFile = "##marti##.mti"

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



function New-MartiDefinition
{
   
    $oSoftware = [PSCustomObject]@{
        extension = "software"
        softwareName = "MartiReference"
        author = "Meerkat@merebox.com"
        version = "$script:SoftwareVersion"
    }

    $publisher = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

    [System.Collections.ArrayList]$lcustom = @()
    $lcustom += $oSoftware

    [System.Collections.ArrayList]$lresource = @()

    $oMarti = [PSCustomObject]@{
        title = ""
        uid = (New-Guid).ToString()
        resources = $lresource

        description = ""
        modified = Get-Date -f "yyyy-MM-ddTHH:mm:ss"
        tags = @( "document", "marti")
        publisher = $publisher
        contactPoint = ""
        accessLevel = "Confidential"
        rights = "Restricted"
        license = ""
        state = "active"
        batch = 1.0
        describedBy = ""
        landingPage = ""
        theme =""

        custom = $lCustom
    }

    return $oMarti
}


function Set-MartiAttribute
{
Param( 
    [System.Collections.ArrayList] $Attributes,
    [String] $ACategory,
    [String] $AName,
    [String] $AFunction,
    [String] $Comparison,
    [String] $Value
) 

    $matched = $false
   
    $Attributes | ForEach-Object {

        if ($_.category -eq $ACategory -and $_.name -eq $AName -and $_.function -eq $AFunction) {
                $matched = $true
                $_.comparison = $comparison
                $_.value = $value
        }
        
    }

    if (!($matched)) {
        
        $oAttribute = [PSCustomObject]@{
            category = $Acategory
            name = $AName
            function = $Afunction
            comparison = $comparison
            value = $value
        }

        $Attributes += $oAttribute
    }

    return $Attributes
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
        $message = "No definition supplied"
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
