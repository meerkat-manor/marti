
function New-MartiResource {
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
    Write-Log "Function 'New-MartiResource' parameters follow"
    Write-Log "Parameter: UrlPath   Value: $UrlPath "
    Write-Log "Parameter: SourcePath   Value: $SourcePath "
    Write-Log "Parameter: ExcludeHash   Value: $ExcludeHash "
    Write-Log ""


    if (Test-Path -Path $SourcePath -PathType Leaf) {
       
        $item = Get-Item -Path $SourcePath -Force 

        Write-Log "Define file $($item.FullName) "

        if ($ExcludeHash) {
            $hash = $null
        } else {
            $hash = New-MartiHash -Algorithm "SHA256" -FilePath $item.FullName
        }

        $lattribute =  Set-MartiResourceAttributes -Path $item.FullName -FileType $item.Extension.Substring(1) -ExtendedAttributes:$ExtendAttributes

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

            description = ""
            url = ""
            version = $version
            format = $item.Extension.Substring(1)
            compression = $null
            encryption = $null

            attributes = $lattribute
        }

        if ($null -ne $UrlPath -and $UrlPath -ne "") {
            if ($UrlPath[$UrlPath.Length-1] -eq "/" -or $UrlPath[$UrlPath.Length-1] -eq "\\") {
                $oResource.url = $UrlPath.Replace("\\", "/") + $item.Name
            } else {
                $oResource.url = $UrlPath.Replace("\\", "/") + "/" + $item.Name
            }
        }
        
    } else {
        $Global:MartiErrorId = "MRI2001"
        $message = "Document '$SourcePath' not found or is a folder"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }
    Close-Log

    return $oResource

}

function New-MartiHash{
    Param( 
        [Parameter(Mandatory)][String] $Algorithm,
        [String] $FilePath
        [String] $Value = ""
    ) 

    if ($Value  -eq "" -and $FilePath -ne "") {
        $Value = (Get-FileHash -Path $FilePath -Algorithm $Algorithm).Hash
    }

    $oHash = [PSCustomObject]@{ 
        algo = $Algorithm
        value = $Value
    }

    return $oHash
}
    
function New-Encryption{
Param( 
    [Parameter(Mandatory)][String] $Algorithm,
    [String] $Value

) 
    
    $oEncryption = [PSCustomObject]@{ 
        algo = $Algorithm
        value = $Value
    }

    return $oEncryption
}
