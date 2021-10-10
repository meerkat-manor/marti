
. C:\Users\meerkat\source\marti\source\powershell\New-Marti.ps1
. C:\Users\meerkat\source\marti\source\powershell\Add-MartiItem.ps1
. C:\Users\meerkat\source\marti\source\powershell\Get-Marti.ps1
. C:\Users\meerkat\source\marti\source\powershell\Compress-Marti.ps1
. C:\Users\meerkat\source\marti\source\powershell\Get-MartiFileAttributes.ps1



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
# Change local directory
$localDirectory = "./test/powershell/results/data"
$localDirectory = "./test"

Write-Host "First fetch the BSB files " -ForeGroundColor Green

$fileList = ListFtpDirectory -Username "anonymous" -Password "anon@merebox.com" -RemoteFile $remoteDirectory
Write-Host "File list size: $($fileList.count)"

$oMarti = New-MartiDefinition
ForEach ($item in $fileList) {
    if ($item -ne "" -and $item.startswith("BSBDirectory")) {
        #Write-Host "Pulling file: $item"
        PullFtpFile -Username "anonymous" -Password "anon@merebox.com" -RemoteFile ($remoteDirectory + $item) -OutputPath (Join-Path -Path $localDirectory -ChildPath $item)
        Write-Host "Add BSB $item file to Remote marti metadata sample " -ForeGroundColor Yellow
        $oResource = Add-MartiItem -SourcePath (Join-Path -Path $localDirectory -ChildPath $item) -UrlPath $remoteDirectory -LogPath ".\test\Logs" -ExtendAttributes
        $oMarti.resources += $oResource
    }
}

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBRemote.mri.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "Remote marti definition file is $fileJson " -ForeGroundColor Green

Write-Host "Now iterate through the local files and build ZIP " -ForeGroundColor Green

if ($fileList -lt 0) {
    $zipFile = Join-Path -Path $localDirectory -ChildPath "BSBDirectory.zip"
    if (Test-Path -Path $zipFile) {
        Remove-Item -Path $zipFile
    }
    foreach($file in Get-ChildItem $localDirectory)
    {
        if ($file.Name.startswith("BSBDirectory")) {
            Write-Host "Add BSB file $file to Local marti metadata sample " -ForeGroundColor Yellow
            Compress-Archive -Path $file.FullName -DestinationPath $zipFile -Update
        }
    }
}

$oMarti = New-MartiChildItem -SourceFolder $localDirectory -UrlPath "./test" -Filter "BSBDirectory*" -LogPath ".\test\Logs" -ExtendAttributes
$oMarti.title = "Local_BSB_data"
$oMarti.description = "This definition covers the local BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/main/docs/samples/asic_ckan_api.json"
$oMarti.theme = "payment"

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBLocal.mri.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "Local marti definition file is $fileJson " -ForeGroundColor Green

Write-Host "Sample execution completed" -ForeGroundColor Green
