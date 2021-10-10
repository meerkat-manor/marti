
. C:\Users\meerkat\source\marti\source\powershell\New-Marti.ps1
. C:\Users\meerkat\source\marti\source\powershell\New-MartiChildItem.ps1
. C:\Users\meerkat\source\marti\source\powershell\New-MartiItem.ps1
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


Write-Host "Now iterate through the remote files and build remote marti list " -ForeGroundColor Green

$oMarti = New-MartiDefinition
$oMarti.title = "Remote_BSB_data"
$oMarti.description = "This definition covers the remote BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/main/docs/samples/asic_ckan_api.json"
$oMarti.theme = "payment"

ForEach ($item in $fileList) {
    if ($item -ne "" -and $item.startswith("BSBDirectory")) {
        PullFtpFile -Username "anonymous" -Password "anon@merebox.com" -RemoteFile ($remoteDirectory + $item) -OutputPath (Join-Path -Path $localDirectory -ChildPath $item)
        Write-Host "Add BSB $item file to Remote marti metadata sample " -ForeGroundColor Yellow
        $oResource = New-MartiItem -SourcePath (Join-Path -Path $localDirectory -ChildPath $item) -UrlPath $remoteDirectory -LogPath ".\test\Logs" -ExtendAttributes
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

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBRemote.mri.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "Remote marti definition file is $fileJson " -ForeGroundColor Green


Write-Host "Now iterate through the local files and build marti ZIP " -ForeGroundColor Green

$oMarti = New-MartiDefinition
$oMarti.title = "Zip_BSB_data"
$oMarti.description = "This definition covers the ZIP BSB data files `r downloaded from the Australian Payment Network"
$oMarti.contactPoint = "meerkat@merebox.com"
$oMarti.landingPage = "https://github.com/meerkat-manor/marti/blob/main/docs/samples/asic_ckan_api.json"
$oMarti.theme = "payment"

$zipFileName = "BSBDirectory.zip"
$zipFile = Join-Path -Path $localDirectory -ChildPath $zipFileName
if (Test-Path -Path $zipFile) {
    Remove-Item -Path $zipFile
}
foreach($file in Get-ChildItem $localDirectory)
{
    if ($file.Name.startswith("BSBDirectory") -and $file.Name -ne $zipFileName) {
        Write-Host "Add BSB file $file to Local marti metadata sample " -ForeGroundColor Yellow
        Compress-Archive -Path $file.FullName -DestinationPath $zipFile -Update
        $oResource = New-MartiItem -SourcePath $file.FullName -UrlPath $localDirectory -LogPath ".\test\Logs" -ExtendAttributes
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
$oResource = New-MartiItem -SourcePath $zipFile -UrlPath $localDirectory -LogPath ".\test\Logs" -ExtendAttributes
Set-AttributeValueString -Attributes $oResource.attributes -Key "compression" -Category "format" -Function "algorithm" -Value "WINZIP"
$oMarti.resources += $oResource

$fileJson = Join-Path -Path $localDirectory -ChildPath "MartiBSBZip.mri.json"
$oMarti | ConvertTo-Json -depth 100 | Out-File $fileJson
Write-Host "ZIP marti definition file is $fileJson " -ForeGroundColor Green



Write-Host "Now iterate through the local files with ZIP " -ForeGroundColor Green

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
