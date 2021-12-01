
. .\source\powershell\MartiLQ.ps1
. .\source\powershell\MartiLQConfiguration.ps1
. .\source\powershell\MartiLQResource.ps1
. .\source\powershell\MartiLQAttribute.ps1


function PullFtpFile {
    param (
        [String] $RemoteFile,
        [String] $OutputPath,
        [String] $Username,
        [String] $Password,
        [int] $Buffersize = 1024
    )
  
    $FTPRequest = [System.Net.FtpWebRequest]::Create($RemoteFile)
    $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
    $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
    $FTPRequest.UseBinary = $true
    $FTPRequest.KeepAlive = $false

    $FTPResponse = $FTPRequest.GetResponse()
    $ResponseStream = $FTPResponse.GetResponseStream()
    $LocalFileStream = New-Object IO.FileStream ($OutputPath,[IO.FileMode]::Create)
    if ($null -eq $LocalFileStream) {
        Write-Host "Write failed to file $OutputPath"
        return
    }
    [byte[]]$ReadBuffer = New-Object byte[] $Buffersize

    # Loop through the download
    do {
        $ReadLength = $ResponseStream.Read($ReadBuffer,0,$Buffersize)
        $LocalFileStream.Write($ReadBuffer,0,$ReadLength)
    }
    while ($ReadLength -gt 0)
    $LocalFileStream.close()
}


function ListFtpDirectory {
    param (
        [String] $RemoteFile,
        [String] $Username,
        [String] $Password,
        [int] $Buffersize = 1024
    )
    
    $FTPRequest = [System.Net.FtpWebRequest]::Create($RemoteFile)
    $FTPRequest.Credentials = New-Object System.Net.NetworkCredential($Username,$Password)
    $FTPRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
    $FTPRequest.UseBinary = $false
    $FTPRequest.KeepAlive = $false

    $FTPResponse = $FTPRequest.GetResponse()
    $ResponseStream = $FTPResponse.GetResponseStream()

    $Encoding = new-object System.Text.AsciiEncoding
    $ListBuffer = ""
    [byte[]]$ReadBuffer = New-Object byte[] $Buffersize

    do {
        $ReadLength = $ResponseStream.Read($ReadBuffer,0,$Buffersize)
        $ListBuffer += ($Encoding.GetString($ReadBuffer, 0, $ReadLength))
    }
    while ($ReadLength -ne 0)

    $list = $ListBuffer.Split([Environment]::NewLine)
    return $list
}

$remoteDirectory = "ftp://bsb.hostedftp.com/~auspaynetftp/BSB/"
$logPath = "./docs/source/samples/powershell/test/logs"

# Create required directory
# Note that this assumes Windows environment
$localDirectory = ".\docs\source\samples\powershell\test"
if (!(Test-Path -Path $localDirectory)) {
    $x = New-Item -Path $localDirectory
}

Write-Host "First fetch the BSB files " -ForeGroundColor Green

$fileList = ListFtpDirectory -Username "anonymous" -Password "anon@merebox.com" -RemoteFile $remoteDirectory
Write-Host "File list size: $($fileList.count)" -ForegroundColor Gray

Write-Host "Now iterate through the remote files and build remote martiLQ list " -ForeGroundColor Green

$oMarti, $oConfig = New-MartiDefinition
$oMarti.title = "Remote_BSB_data"
$oMarti.description = "This definition covers the remote BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/draft_specifications/docs/samples/powershell/Invoke-SampleGenerateBSB.ps1"
$oMarti.theme = "payment"

ForEach ($item in $fileList) {
    if ($item -ne "" -and $item.startswith("BSBDirectory")) {
        PullFtpFile -Username "anonymous" -Password "anon@merebox.com" -RemoteFile ($remoteDirectory + $item) -OutputPath (Join-Path -Path $localDirectory -ChildPath $item)
        Write-Host "Add BSB $item file to Remote martiLQ metadata sample " -ForeGroundColor Yellow
        $oResource = New-MartiResource -SourcePath (Join-Path -Path $localDirectory -ChildPath $item) -UrlPath $remoteDirectory -LogPath $logPath -ExtendAttributes
        if ($item.endswith(".txt")) {
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "header" -Category "dataset" -Function "count" -Value 1
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "footer" -Category "dataset" -Function "count" -Value 1
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "columns" -Category "dataset" -Function "count" -Value 8
        }
        if ($item.endswith(".csv")) {
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "header" -Category "dataset" -Function "count" -Value 0
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "footer" -Category "dataset" -Function "count" -Value 0
        }
        $oMarti.resources += $oResource
    }
}

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBRemote.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "Remote martiLQ definition file is $fileJson " -ForeGroundColor Green


Write-Host "Now iterate through the local files and build martiLQ ZIP " -ForeGroundColor Green

$oMarti, $oConfig = New-MartiDefinition
$oMarti.title = "Zip_BSB_data"
$oMarti.description = "This definition covers the ZIP BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/draft_specifications/docs/samples/powershell/Invoke-SampleGenerateBSB.ps1"
$oMarti.theme = "payment"

$zipFileName = "BSBDirectory.zip"
$zipFile = Join-Path -Path $localDirectory -ChildPath $zipFileName
if (Test-Path -Path $zipFile) {
    Remove-Item -Path $zipFile
}
foreach($file in Get-ChildItem $localDirectory)
{
    if ($file.Name.startswith("BSBDirectory") -and !($file.Name.EndsWith(".zip")) -and !($file.Name.EndsWith(".7z")) ) {
        Write-Host "Add BSB file $file to ZIP martiLQ metadata sample " -ForeGroundColor Yellow
        Compress-Archive -Path $file.FullName -DestinationPath $zipFile -Update
        $oResource = New-MartiResource -SourcePath $file.FullName -UrlPath $localDirectory -LogPath $logPath -ExtendAttributes
        if ($file.Extension -eq ".txt") {
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "header" -Category "dataset" -Function "count" -Value 1
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "footer" -Category "dataset" -Function "count" -Value 1
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "columns" -Category "dataset" -Function "count" -Value 8
        }
        if ($file.Extension -eq ".csv") {
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "header" -Category "dataset" -Function "count" -Value 0
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "footer" -Category "dataset" -Function "count" -Value 0
        }
        $oResource.url = "@"+$zipFileName + "/" + $file.Name
        $oMarti.resources += $oResource
    }
}
$oResource = New-MartiResource -SourcePath $zipFile -UrlPath $localDirectory -LogPath $logPath -ExtendAttributes
Set-AttributeValueString -Attributes $oResource.attributes -Key "compression" -Category "format" -Function "algo" -Value "WINZIP"
$oMarti.resources += $oResource

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBZip.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "ZIP martiLQ definition file is $fileJson " -ForeGroundColor Green



Write-Host "Now iterate through the local files with ZIP " -ForeGroundColor Green

$oMarti = New-MartiChildItem -SourceFolder $localDirectory -UrlPath "./docs/source/samples/powershell/test" -Filter "BSBDirectory*" -LogPath $logPath -ExtendAttributes
$oMarti.title = "Local_BSB_data"
$oMarti.description = "This definition covers the local BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/draft_specifications/docs/samples/powershell/Invoke-SampleGenerateBSB.ps1"
$oMarti.theme = "payment"

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBLocal.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "Local martiLQ definition file is $fileJson " -ForeGroundColor Green


Write-Host "Now create an encrypted 7ZIP file with asymmetric password protection" -ForeGroundColor Green

$oMarti, $oConfig = New-MartiDefinition
$oMarti.title = "7ZIP_BSB_data"
$oMarti.description = "This definition covers the 7ZIP BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/draft_specifications/docs/samples/powershell/Invoke-SampleGenerateBSB.ps1"
$oMarti.theme = "payment"

$zipFileName = "BSBDirectorySecure.7z"
$zipFile = Join-Path -Path $localDirectory -ChildPath $zipFileName
if (Test-Path -Path $zipFile) {
    Remove-Item -Path $zipFile
}
foreach($file in Get-ChildItem $localDirectory)
{
    if ($file.Name.startswith("BSBDirectory") -and !($file.Name.EndsWith(".zip")) -and !($file.Name.EndsWith(".7z")) ) {
        Write-Host "Add BSB file $file to 7ZIP martiLQ metadata sample " -ForeGroundColor Yellow
        if (Test-Path -Path $zipFile) {
            Compress-7Zip -Path $file.FullName -ArchiveFileName $zipFile -Format SevenZip -Append 
        } else {
            Compress-7Zip -Path $file.FullName -ArchiveFileName $zipFile -Format SevenZip 
        }
        $oResource = New-MartiResource -SourcePath $file.FullName -UrlPath $localDirectory -LogPath $logPath -ExtendAttributes
        if ($file.Extension -eq ".txt") {
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "header" -Category "dataset" -Function "count" -Value 1
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "footer" -Category "dataset" -Function "count" -Value 1
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "columns" -Category "dataset" -Function "count" -Value 8
        }
        if ($file.Extension -eq ".csv") {
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "header" -Category "dataset" -Function "count" -Value 0
            Set-AttributeValueNumber -Attributes $oResource.attributes -Key "footer" -Category "dataset" -Function "count" -Value 0
        }
        $oResource.url = "@"+$zipFileName + "/" + $file.Name
        $oMarti.resources += $oResource
    }
}

$noticeFile = Join-Path -Path  $localDirectory -ChildPath "README.txt"
Set-Content -Path $noticeFile -Value "Generated by martiLQ Samples"
$oResource = New-MartiResource -SourcePath $noticeFile -UrlPath $localDirectory -LogPath $logPath
$oMarti.resources += $oResource

$secret = "change_me_to_secure"
Compress-7Zip -Path $noticeFile -ArchiveFileName $zipFile -Append -Password $secret -EncryptFilenames

$oResource = New-MartiResource -SourcePath $zipFile -UrlPath $localDirectory -LogPath $logPath -ExtendAttributes
$oResource.compression = "7ZIP"
$oResource.encryption = New-Encryption -Algorithm "Passphrase" -Value $secret
Set-AttributeValueString -Attributes $oResource.attributes -Key "compression" -Category "format" -Function "algo" -Value "7ZIP"
$oMarti.resources += $oResource

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBSecure.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "Secure 7ZIP martiLQ definition file is $fileJson " -ForeGroundColor Green


Write-Host "Sample execution completed" -ForeGroundColor Green
