


$script:SoftwareVersion = "0.0.1"
$global:default_metaFile = "##martilq##.json"

$global:martiLQ_configuration = $null

function Get-Configuration {

    if ($null -eq $global:martiLQ_configuration) {
        return Get-DefaultConfiguration
    } else {
        return $global:martiLQ_configuration
    }
}

function Get-DefaultConfiguration {

    $oConfiguration = [PSCustomObject]@{
        softwareName = Get-SoftwareName 
        softwareAuthor = "Meerkat@merebox.com"
        softwareVersion = $script:SoftwareVersion

        logPath = "./logs/"
        dateFormat = "yyyy-MM-dd"
        dateTimeFormat = "yyyy-MM-ddTHH:mm:ss"
        dataPath = ""
        tempPath =  "temp"

        tags = @( "default", "martiLQ")
        publisher = ""
        contactPoint = ""
        license = ""
        accessLevel = "Confidential"
        rights = "Restricted"
        batch = 1.0000
        batchInc = 0.0001
        theme = ""

        author = $null
        title = "{{documentName.ext}}"
        state = "active"
        expires = "m:10:0:0"
        version = "1.0"
        urlPrefix = ""
        encoding = ""
        compression = ""
        encryption = ""
        describedBy = ""
        landingPage = ""

        hashAlgorithm = "SHA256"
        signKey_File = $null
        signKey_Password = $null

        proxy = $null
        proxy_User = $null
        proxy_Credential = $null

        loaded = $false
    }

    return $oConfiguration
}

function Import-Configuration {
    Param( 
        [String] $ConfigPath = $null    
    ) 

    $oConfig = Get-DefaultConfiguration
    $iConfig = $null

    if ($null -eq $ConfigPath -or $ConfigPath -eq "") {

        $envPath = Get-ChildItem -Path Env:MARTILQ_MARTILQ_INI
        if ($envPath -ne "" -and (Test-Path -Path $envPath -PathType Leaf)) {
            $ConfigPath = $envPath
        } else { if (Test-Path "martilq.ini") { 
            $ConfigPath = "martilq.ini"
            } else {
                if (Test-Path -Path "conf/martilq.ini" -PathType Leaf) {
                    $ConfigPath = "conf/martilq.ini"
                } else { if (Test-Path -Path ".martilq/martilq.ini" -PathType Leaf) {
                        $ConfigPath = ".martilq/martilq.ini"
                    } else {
                        $homeDir = $env:USERPROFILE
                        if (Test-Path -Path (Join-Path -Path $homeDir -ChildPath ".martilq/martilq.ini") -PathType Leaf) {
                            $ConfigPath = Join-Path -Path $homeDir -ChildPath ".martilq/martilq.ini"
                        }
                    }
                }
            }
        }
        if ($null -ne $ConfigPath -and $ConfigPath -ne "") {
          Write-Log -LogEntry "Using configuration path '$ConfigPath'"
          $iConfig = Get-IniFile -Path $ConfigPath
        } else {
            Write-Log -LogEntry "Using default configuration settings"
        }
    } else {
        if (Test-Path $ConfigPath) { 
            Write-Log -LogEntry "Using configuration path '$ConfigPath'"
            $iConfig = Get-IniFile -Path $ConfigPath
        } else {
            Write-Log -LogEntry "Could not find configuration path '$ConfigPath' so using default configuration"
        }
    }

    # Now do mapping of values
    if ($null -ne $iConfig) {

        if ($null -ne $iConfig.General) {
        
            $oConfig.logPath = Set-ConfigurationValue $oConfig.logPath -Value $iConfig.General.logPath
            $oConfig.dateFormat = Set-ConfigurationValue $oConfig.dateFormat -Value $iConfig.General.dateFormat
            $oConfig.dateTimeFormat = Set-ConfigurationValue $oConfig.dateTimeFormat -Value $iConfig.General.dateTimeFormat
            $oConfig.dataPath = Set-ConfigurationValue $oConfig.dataPath -Value $iConfig.General.dataPath
            $oConfig.tempPath = Set-ConfigurationValue $oConfig.tempPath -Value $iConfig.General.tempPath
    
        }

        if ($null -ne $iConfig.martiLQ) {
            if ($null -ne $iConfig.martiLQ.tags -and $iConfig.martiLQ.tags -ne "" -and $iConfig.martiLQ.tags.Length -gt 0 ) {
                $oConfig.tags = $iConfig.martiLQ.tags.Split(",")
            }
        
            $oConfig.publisher = Set-ConfigurationValue $oConfig.publisher -Value $iConfig.martiLQ.publisher
            $oConfig.contactPoint = Set-ConfigurationValue $oConfig.contactPoint -Value $iConfig.martiLQ.contactPoint
            $oConfig.accessLevel = Set-ConfigurationValue $oConfig.accessLevel -Value $iConfig.martiLQ.accessLevel
            $oConfig.rights = Set-ConfigurationValue $oConfig.rights -Value $iConfig.martiLQ.rights
            $oConfig.license = Set-ConfigurationValue $oConfig.license -Value $iConfig.martiLQ.license
            $oConfig.batch = Set-ConfigurationValue $oConfig.batch -Value $iConfig.martiLQ.batch
            $oConfig.theme = Set-ConfigurationValue $oConfig.theme -Value $iConfig.martiLQ.theme

        }

        if ($null -ne $iConfig.Resources) {
            $oConfig.author = Set-ConfigurationValue $oConfig.author -Value $iConfig.Resources.author
            $oConfig.title = Set-ConfigurationValue $oConfig.title -Value $iConfig.Resources.title
            $oConfig.state = Set-ConfigurationValue $oConfig.state -Value $iConfig.Resources.state
            $oConfig.expires = Set-ConfigurationValue $oConfig.expires -Value $iConfig.Resources.expires
            $oConfig.urlPrefix = Set-ConfigurationValue $oConfig.urlPrefix -Value $iConfig.Resources.urlPrefix

            $oConfig.compression = Set-ConfigurationValue $oConfig.compression -Value $iConfig.Resources.compression
            $oConfig.encryption = Set-ConfigurationValue $oConfig.encryption -Value $iConfig.Resources.encryption
            $oConfig.describedBy = Set-ConfigurationValue $oConfig.describedBy -Value $iConfig.Resources.describedBy
            $oConfig.landingPage = Set-ConfigurationValue $oConfig.landingPage -Value $iConfig.Resources.landingPage

        }


        if ($null -ne $iConfig.Hash) {
            $oConfig.hashAlgorithm = Set-ConfigurationValue $oConfig.hashAlgorithm -Value $iConfig.Hash.hashAlgorithm
        }

    }

    $global:martiLQ_configuration = $oConfig
    return $oConfig
}

Function Set-ConfigurationValue {
    Param(
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$OriginalValue,
        [Parameter(Mandatory=$true)][AllowEmptyString()][String]$Value
    )
    
    if ($null -ne $Value -and $Value -ne "") {
        return $Value
    } else {
        return $OriginalValue
    }

}

Function Get-IniFile {
Param(
    [Parameter(mandatory=$true)][string]$Path
)

    $oIni = @{}

    Get-Content $Path | ForEach-Object {
        $_.Trim() } | Where-Object {
        $_ -notmatch '^(;|$)'
        } | ForEach-Object {
            if ($_ -match '^\[.*\]$') {
                $section = $_ -replace '\[|\]'
                $oIni[$section] = @{}
            } else {
                $key, $value = $_ -split '\s*=\s*', 2
                $oIni[$section][$key] = $value
            }
        }

    return $oIni
}