
. ..\..\..\source\powershell\MartiLQ.ps1
. ..\..\..\source\powershell\MartiLQConfiguration.ps1
. ..\..\..\source\powershell\MartiLQResource.ps1
. ..\..\..\source\powershell\MartiLQAttribute.ps1


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

function New-RandomPassword {
    param(
        [int] $length = 30,
        [String] $characters = "abcdefghiklmnoprstuvwxyzABCDEFGHKLMNOPRSTUVWXYZ1234567890!()?}][{@#*+-",
        [switch] $ConvertToSecureString
    )
    $password = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }

    $private:ofs=""
    if ($ConvertToSecureString.IsPresent) {
        return ConvertTo-SecureString -String [String]$characters[$password] -AsPlainText -Force
    } else {
        return [String]$characters[$password]
    }
}
    



Write-Host "Please execute in the same directory as script" -ForeGroundColor Yellow

$recipientKey = "CN=PeterDocs"
$remoteDirectory = "ftp://bsb.hostedftp.com/~auspaynetftp/BSB/"

# Change local directory to suit
$localDirectory = "./test"
if (!(Test-Path -Path $localDirectory)) {
    New-Item -Path $localDirectory
}

Write-Host "First fetch the BSB files " -ForeGroundColor Green

$fileList = ListFtpDirectory -Username "anonymous" -Password "anon@merebox.com" -RemoteFile $remoteDirectory
Write-Host "File list size: $($fileList.count)" -ForegroundColor Gray

Write-Host "Now create an encrypted 7ZIP file with password " -ForeGroundColor Green

$oMarti = New-MartiDefinition
$oMarti.title = "7ZIP_BSB_data"
$oMarti.description = "This definition covers the 7ZIP BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/draft_specifications/docs/samples/powershell/Invoke-BSBSample.ps1"
$oMarti.theme = "payment"

$zipFileName = "BSBDirectoryPKI.7z"
$zipFile = Join-Path -Path $localDirectory -ChildPath $zipFileName
if (Test-Path -Path $zipFile) {
    Remove-Item -Path $zipFile
}
foreach($file in Get-ChildItem $localDirectory)
{
    if ($file.Name.startswith("BSBDirectory") -and $file.Name.EndsWith(".csv") ) {
        Write-Host "Add BSB file $file to 7ZIP martiLQ metadata sample " -ForeGroundColor Yellow
        if (Test-Path -Path $zipFile) {
            Compress-7Zip -Path $file.FullName -ArchiveFileName $zipFile -Format SevenZip -Append 
        } else {
            Compress-7Zip -Path $file.FullName -ArchiveFileName $zipFile -Format SevenZip 
        }
        $oResource = New-MartiResource -SourcePath $file.FullName -UrlPath $localDirectory -LogPath ".\test\Logs" -ExtendAttributes
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
$oResource = New-MartiResource -SourcePath $noticeFile -UrlPath $localDirectory -LogPath ".\test\Logs"
$oMarti.resources += $oResource

$secret = New-RandomPassword -Length 80
$encryptedSecret = Protect-CmsMessage -To $recipientKey -Content $secret 

Compress-7Zip -Path $noticeFile -ArchiveFileName $zipFile -Append -Password $secret -EncryptFilenames

$oResource = New-MartiResource -SourcePath $zipFile -UrlPath $localDirectory -LogPath ".\test\Logs" -ExtendAttributes
$oResource.compression = "7ZIP"
$oResource.encryption = New-Encryption -Algorithm "PKI" -Value $($encryptedSecret)

Write-Debug "Secret: $secret"

Set-AttributeValueString -Attributes $oResource.attributes -Key "compression" -Category "format" -Function "algo" -Value "7ZIP"
$oMarti.resources += $oResource

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSB7ZipPKI.json"
$oMarti | ConvertTo-Json -depth 50 | Out-File $fileJson
Write-Host "7ZIP martiLQ definition file is $fileJson " -ForeGroundColor Green

Write-Host "Sample secure execution completed" -ForeGroundColor Green
