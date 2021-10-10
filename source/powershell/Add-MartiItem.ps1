
function Add-MartiItem
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
    Write-Log "Function 'Add-MartiItem' parameters follow"
    Write-Log "Parameter: SourcePath   Value: $SourcePath "
    Write-Log "Parameter: ExcludeHash   Value: $ExcludeHash "
    Write-Log ""


    if (Test-Path -Path $SourcePath -PathType Leaf) {
       
        $item = Get-Item -Path $SourcePath -Force 

        Write-Log "Define file $($item.FullName) "

        if ($ExcludeHash) {
            $hashAlgo = ""
        }
        else {
            $hashAlgo = "SHA256"
        }
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

