
. .\source\powershell\MartiLQUtilities.ps1
. .\source\powershell\MartiLQConfiguration.ps1
. .\source\powershell\MartiLQResource.ps1
. .\source\powershell\MartiLQAttribute.ps1


function New-MartiLQDefinition
{
    Param( 
        [String] $ConfigPath = $null    
    ) 
   
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


    if ($null -eq $ConfigPath -or $ConfigPath -eq "") {
        $oConfig = Get-Configuration
    } else {
        $oConfig = Import-Configuration -ConfigPath $ConfigPath
    }

    if ( $nulll -eq $oConfig.publisher -or $oConfig.publisher -eq "") {
        $publisher = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    } else {
        $publisher = $oConfig.publisher
    }

    [System.Collections.ArrayList]$lcustom = @()
    $lcustom += $oSoftware
    $lcustom += $oTemplate

    [System.Collections.ArrayList]$lresource = @()
    [System.Collections.ArrayList]$lconsumer = @()
    
    $today = Get-Date
    $dateToday = $today.Tostring($oConfig.dateTimeFormat)
    $expires = Set-DefaultExpiryDate -DocumentDate (Get-Date)  -Configuration $oConfig

    $batch = $oConfig.batch
	if ($batch -ne "") {
		if ($batch[0] -eq "@") {
            if (!(Test-Path -Path $batch.Substring(1))) {

            }
#				// See if we can locate it in Config INI directory
#				_, fileb := filepath.Split(m.config.batch[1:])
#				dirc, _ := filepath.Split(ConfigPath)
#				_, err := os.Stat(dirc + fileb)
#				if err == nil {
#					m.config.batch = "@" + dirc + fileb
#				}
			

			if (Test-Path -Path $batch -PathType Leaf) {
				#readFile, err := os.Open(m.config.batch[1:])
				#reader := bufio.NewReader(readFile)
				#m.Batch, _ = strconv.ParseFloat(line, 10)
				#readFile.Close()
			} else {
				Write-Log ("Batch file '$oConfig.batch' does not exist")		
			}
		} else {
			$batch = 1
            #m.Batch, _ = strconv.ParseFloat(m.config.batch, 10)
		}
	}

    $oMarti = [PSCustomObject]@{
        contentType = "application/vnd.martilq.json"
        title = ""
        uid = (New-Guid).ToString()

        description = ""
        issued = $dateToday
        modified = $dateToday
        expires = $expires.Tostring($oConfig.dateTimeFormat)
        tags = $oConfig.tags
        publisher = $publisher
        contactPoint = $oConfig.contactPoint
        accessLevel = $oConfig.accessLevel
        consumers = $lconsumer
        rights = $oConfig.rights
        license = $oConfig.license
        state = $oConfig.state
        stateModified = $dateToday
        batch =  $batch
        describedBy = $oConfig.describedBy
        landingPage = $oConfig.landingPage
        theme =$oConfig.theme

        resources = $lresource
        acknowledge = Get-Acknowledgement
        custom = $lCustom
    }

    return $oMarti, $oConfig
}


function Save-MartiLQDefinition
{
    Param( 
        [Parameter(Mandatory)][PSCustomObject] $MartiLQ,
        [Parameter(Mandatory)][String] $FilePath
    ) 

    $fileJson = $FilePath
    $MartiLQ | ConvertTo-Json -depth 100 | Out-File $fileJson

    return $fileJson
}


function Restore-MartiLQDefinition
{
    Param( 
        [Parameter(Mandatory)][String] $FilePath
    ) 

    $oMartiLQ = [PSCustomObject](Get-Content -Raw $FilePath | Out-String | ConvertFrom-Json)
    
    $version = Get-DefinitionVersion -MartiLQ $oMartiLQ
    if ($version -lt "0.0.2") {
        if (![bool]($oMartiLQ.PSCustomObject.Properties.name -match "consumers")) {
            [System.Collections.ArrayList]$lconsumer = @()
            $oMartiLQ | Add-Member -Name "consumers" -Type NoteProperty -Value $lconsumer
        }

        if (![bool]($oMartiLQ.PSCustomobject.Properties.name -match "acknowledge")) {
            $oMartiLQ | Add-Member -Name "acknowledge" -Type NoteProperty -Value (Get-Acknowledgement)
        }

        Set-DefinitionVersion -MartiLQ $oMartiLQ -Version "0.0.2"
        $newVersion = Get-DefinitionVersion -MartiLQ $oMartiLQ
        Write-Host "Updating from version $version to $newVersion"
    }

    return $oMartiLQ
}

function Get-DefinitionVersion
{
param (
    [Parameter(Mandatory)][PSCustomObject] $MartiLQ
)
   
    $version = "0.0.1"
    $MartiLQ.custom | ForEach-Object {
        if ($_.extension -eq "software" -and $_.softwareName -eq (Get-SoftwareName)) {
            $version = $_.version
        }        
    }

    return $version
}

function Set-DefinitionVersion
{
param (
    [Parameter(Mandatory)][PSCustomObject] $MartiLQ,
    [Parameter(Mandatory)][String] $Version
)
   
    $MartiLQ.custom | ForEach-Object {

        if ($_.extension -eq "software" -and $_.softwareName -eq (Get-SoftwareName)) {
                $_.version = $Version
                #return $MartiLQ
        }
        
    }

    #return $MartiLQ
}

function Get-Acknowledgement{
   
    $oAcknowledgement = [PSCustomObject]@{
        url = ""
        algo = ""
        value = ""
        signed =  $false
    }

    return $oAcknowledgement
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
    [Parameter(Mandatory)][String] $InputObject,
    [Parameter(Mandatory=$false)][switch] $FetchResource,
    [Parameter(Mandatory=$false)][String] $DataPath
) 

    if ($InputObject.StartsWith("https://") -or $InputObject.StartsWith("http://") -or $InputObject.StartsWith("ftp://")) {
        $JsonFileName = Invoke-WebRequest $InputObject
    } else {
        $JsonFileName = $InputObject
    }

    $oCkan = ConvertFrom-Json -InputObject $JsonFileName

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

        $size = $_.size

        if ($FetchResource -and $_.url -ne "") {
            $localResource = New-LocalTempFile -UrlPath $_.url -Configuration $null -TempPath $DataPath
            if (Test-Path -Path $localResource -PathType Leaf) {
                Remove-Item -Path $localResource
            }
            Invoke-WebRequest -Uri $_.url -OutFile $localResource 
            if ($_.hash -eq "") {
                $hash = New-MartiHash -Algorithm "SHA256" -FilePath $localResource -Value $null
            } else {
                $hash = New-MartiHash -Algorithm "SHA256" -FilePath "" -Value $_.hash
            }
            if ($size -le 1) {
                $size = (Get-Item $localResource).length
            }
        } else {
            $hash = New-MartiHash -Algorithm "SHA256" -FilePath "" -Value $_.hash
        }


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
            length = $size
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

