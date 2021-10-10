
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

        describedBy = ""
        landingPage = ""
        theme =""

        custom = $lCustom
    }

    return $oMarti
}




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
    Write-Log "Parameter: ExcludeHash   Value: $ExcludeHash "
    Write-Log ""

    if ($ExcludeHash) {
        $hashAlgo = ""
    }
    else {
        $hashAlgo = "SHA256"
    }
    $version = "1.1.0"

    $oMarti = New-MartiDefinition
    $lresource = $oMarti.resources

    $SourceFullName = (Get-Item -Path $SourceFolder).FullName

    Get-ChildItem $SourceFolder -Filter $Filter -Recurse:$Recurse -Force| Where-Object {!$_.PSIsContainer} | ForEach-Object {

        Write-Log "Define file $($_.FullName) "
        if ($ExcludeHash) {
            $hash = ""
        } else {
            $hash = (Get-FileHash -Path $_.FullName -Algorithm $hashAlgo).Hash
        }

        $lattribute =  Get-MartiFileAttributes -Path $_.FullName -FileType $_.Extension.Substring(1) -ExtendedAttributes:$ExtendAttributes

        $oResource = [PSCustomObject]@{
            title = $_.Name.Replace($_.Extension, "")
            uid = (New-Guid).ToString()
            documentName = $_.Name
            issuedDate = Get-Date -f "yyyy-MM-ddTHH:mm:ss"
            modified = $_.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ss")
            state = "active"
            author = ""
            length = $_.Length
            hash = $hash
            hashAlgo = $hashAlgo   

            description = ""
            url = ""
            version = $version
            format = $_.Extension.Substring(1)
            compression = ""
            encryption = ""

            attributes = $lattribute
        }

        if ($null -ne $UrlPath -and $UrlPath -ne "") {
            $postfixName = $_.FullName.Replace($SourceFullName, "")
            $oResource.url = Join-Path -Path $UrlPath -ChildPath $postfixName
        }

        $lresource += $oResource
        
    }
    Write-Log "Captured $($lresource.Count) items"
    $oMarti.resources = $lresource

    Close-Log

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

function New-MartiItem
{
Param( 
    [Parameter(Mandatory)][String] $SourcePath,
    [String] $UrlPath = "",
    [switch] $ExcludeHash,
    [switch] $ExtendAttributes,
    [String] $LogPath

) 
    $Global:MartiErrorId = ""
    $script:LogPathName = $LogPath

    Write-Debug "Parameter: LogPath   Value: $LogPath "
    Open-Log
    Write-Log "Function 'New-MartiItem' parameters follow"
    Write-Log "Parameter: SourcePath   Value: $SourcePath "
    Write-Log "Parameter: ExcludeHash   Value: $ExcludeHash "
    Write-Log ""


    if ($ExcludeHash) {
        $hashAlgo = ""
    }
    else {
        $hashAlgo = "SHA256"
    }
    $version = "1.1.0"

    $oMarti = New-MartiDefinition
    $lresource = $oMarti.resources

    if (Test-Path -Path $SourcePath -PathType Leaf) {

        $item = Get-Item -Path $SourcePath -Force 

        Write-Log "Define file $($item.FullName) "
        if ($ExcludeHash) {
            $hash = ""
        } else {
            $hash = (Get-FileHash -Path $item.FullName -Algorithm $hashAlgo).Hash
        }

        $lattribute =  Get-MartiFileAttributes -Path $item.FullName -FileType $item.Extension.Substring(1) -ExtendedAttributes:$ExtendAttributes

        $oResource = [PSCustomObject]@{ 
            title = $item.Name.Replace($item.Extension, "")
            uid = (New-Guid).ToString()
            documentName = $item.Name
            issuedDate = Get-Date -f "yyyy-MM-ddTHH:mm:ss"
            modified = $item.LastWriteTime.ToString("yyyy-MM-ddTHH:mm:ss")
            state = "active"
            author = ""
            length = $item.Length
            hash = $hash
            hashAlgo = $hashAlgo   

            description = ""
            url = ""
            version = $version
            format = $item.Extension.Substring(1)
            compression = ""
            encryption = ""

            attributes = $lattribute
        }

        if ($null -ne $UrlPath -and $UrlPath -ne "") {
            if ($UrlPath[$UrlPath.Length-1] -eq "/" -or $UrlPath[$UrlPath.Length-1] -eq "\\") {
                $oResource.url = $UrlPath.Replace("\\", "/") + "/" + $_.Name
            } else {
                $oResource.url = $UrlPath.Replace("\\", "/") + "/" + $_.Name
            }
        }

        $lresource += $oResource
        
    } else {
        $Global:MartiErrorId = "MRI2001"
        $message = "Document '$SourcePath' not found or is a folder"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }
    Write-Log "Captured $($lresource.Count) items"
    $oMarti.resources = $lresource
    Close-Log

    return $oMarti

}

