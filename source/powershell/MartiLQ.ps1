
. .\source\powershell\MartiLQUtilities.ps1
. .\source\powershell\MartiLQConfiguration.ps1
. .\source\powershell\MartiLQResource.ps1
. .\source\powershell\MartiLQAttribute.ps1


function New-MartiDefinition
{
   
    $oSoftware = [PSCustomObject]@{
        extension = "software"
        softwareName = Get-SoftwareName
        author = "Meerkat@merebox.com"
        version = "$script:SoftwareVersion"
    }
   
    $oTemplate = [PSCustomObject]@{
        extension = "template"
        renderer =  "MARTILQREFERENCE:Mustache"
        url = ""
    }


    $oConfig = Get-DefaultConfiguration
    if ( $nulll -eq $oConfig.publisher -or $oConfig.publisher -eq "") {
        $publisher = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    } else {
        $publisher = $oConfig.publisher
    }

    [System.Collections.ArrayList]$lcustom = @()
    $lcustom += $oSoftware
    $lcustom += $oTemplate

    [System.Collections.ArrayList]$lresource = @()
    
    $expires = Set-DefaultExpiryDate -DocumentDate (Get-Date)  -Configuration $oConfig

    $oMarti = [PSCustomObject]@{
        contentType = "application/vnd.martilq.json"
        title = ""
        uid = (New-Guid).ToString()

        description = ""
        issued = Get-Date -f $oConfig.dateTimeFormat
        modified = Get-Date -f $oConfig.dateTimeFormat
        expires = $expires.Tostring($oConfig.dateTimeFormat)
        tags = $oConfig.tags
        publisher = $publisher
        contactPoint = $oConfig.contactPoint
        accessLevel = $oConfig.accessLevel
        rights = $oConfig.rights
        license = $oConfig.license
        state = $oConfig.state
        batch =  $oConfig.batch
        describedBy = ""
        landingPage = ""
        theme =$oConfig.theme

        resources = $lresource
        custom = $lCustom
    }

    return $oMarti, $oConfig
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



function Get-MartiChildResource
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
    Write-Log "Function 'Get-MartiChildResource' parameters follow"
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





function ConvertFrom-Ckan 
{
Param( 
    [Parameter(Mandatory)][String] $InputObject
) 

    $oCkan = ConvertFrom-Json -InputObject $InputObject

    $oMarti, $oConfig = New-MartiDefinition

    $oMarti.title = "Conversion from CKAN"
    $oMarti.state = $oCkan.result.state
    $oMarti.uid = $oCkan.result.id
    $oMarti.contactPoint = $oCkan.result.contact_point
    $oMarti.license = $oCkan.result.license_id
    $oMarti.description = $oCkan.result.notes
    
    $version = "1.1.0"
    
    [System.Collections.ArrayList]$lresource = @()

    $oCkan.result.resources | ForEach-Object {

        $idx = $_.url.LastIndexOf("/")
        if ($idx -gt 1) {
            $name = $_.url.Substring(($idx+1))
        } else {
            $name = ""
        }

        $hash = New-MartiHash -Algorithm "SHA256" -FilePath "" -Value $_.hash
        $expires = (Get-Date).AddYears(7)

        $oResource = [PSCustomObject]@{ 
            title = $_.name
            uid = $_.id
            documentName = $name
            issuedDate = $_.created.ToString("yyyy-MM-ddTHH:mm:ss")
            modified = $_.last_modified.ToString("yyyy-MM-ddTHH:mm:ss")
            expires = $expires.Tostring("yyyy-MM-ddTHH:mm:ss")
            state = $_.state
            author = $oCkan.result.author
            length = $_.size
            hash = $hash

            description = $_.description
            url = $_.url
            structure = $null
            version = $version
            contentType = Get-MimeType(("."+$_.format))
            compression = $null
            encryption = $null
        }
       
        $lresource += $oResource

    }

    $oMarti.resources = $lresource


    return $oMarti

}



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

    $martilq_mri = $global:default_metaFile

    $oMarti, $oConfig = New-MartiDefinition -SourceFolder $SourceFolder -Filter $Filter -LogPath $LogPath
    $oMarti.description = "Sample execution"
    
    $fullMetadatName = Join-Path -Path (Split-Path -Path $ArchiveFile -Parent) -ChildPath $martilq_mri
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




