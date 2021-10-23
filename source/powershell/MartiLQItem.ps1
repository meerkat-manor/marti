
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
        [String] $FilePath,
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
    Write-Log "Parameter: ExtendAttributes   Value: $ExtendAttributes "
    Write-Log "Parameter: ExcludeHash   Value: $ExcludeHash "
    Write-Log ""

    $oMarti = New-MartiDefinition
    $lresource = $oMarti.resources

    $SourceFullName = (Get-Item -Path $SourceFolder).FullName

    Get-ChildItem $SourceFolder -Filter $Filter -Recurse:$Recurse -Force| Where-Object {!$_.PSIsContainer} | ForEach-Object {

        $oResource = New-MartiResource -SourcePath $_.FullName -UrlPath $UrlPath -LogPath $LogPath -ExtendAttributes:$ExtendAttributes -ExcludeHash:$ExcludeHash

        if ($null -ne $UrlPath -and $UrlPath -ne "") {
            $postfixName = $_.FullName.Replace($SourceFullName, "")
            if ($postfixName[0] -eq "/" -or $postfixName[0] -eq "`\" ){
                $postfixName = $postfixName.Substring(1, ($postfixName.Length-1))
            }
            if ($UrlPath[$UrlPath.Length-1] -eq "/" -or $UrlPath[$UrlPath.Length-1] -eq "`\") {
                $oResource.url = $UrlPath.Replace("`\", "/") + $postfixName.Replace("`\", "/")
            } else {
                $oResource.url = $UrlPath.Replace("`\", "/") + "/" + $postfixName.Replace("`\", "/")
            }
        }

        $lresource += $oResource
        
    }
    Write-Log "Captured $($lresource.Count) items"
    $oMarti.resources = $lresource

    Close-Log

    return $oMarti

}



function New-DefaultCsvAttributes {
       
    [System.Collections.ArrayList]$lattribute = @()

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "header"
        function = "count"
        comparison = "NA"
        value = 1
    }
    $lattribute += $oAttribute
    
    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "footer"
        function = "count"
        comparison = "NA"
        value = 0
    }
    $lattribute += $oAttribute
    
    $oAttribute = [PSCustomObject]@{
        category = "format"
        name = "separator"
        function = "value"
        comparison = "NA"
        value = ","
    }
    $lattribute += $oAttribute
    
    $oAttribute = [PSCustomObject]@{
        category = "format"
        name = "columns"
        function = "value"
        comparison = "NA"
        value = ","
    }
    $lattribute += $oAttribute

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "records"
        function = "count"
        comparison = "NA"
        value = 0
    }
    $lattribute += $oAttribute
    
    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "columns"
        function = "count"
        comparison = "NA"
        value = 0
    }
    $lattribute += $oAttribute
    
    return $lattribute
}


function New-DefaultJsonAttributes {
       
    [System.Collections.ArrayList]$lattribute = @()
    
    $oAttribute = [PSCustomObject]@{
        category = "format"
        name = "list"
        function = "offset"
        comparison = "NA"
        value = ","
    }
    $lattribute += $oAttribute
    
    $oAttribute = [PSCustomObject]@{
        category = "format"
        name = "columns"
        function = "value"
        comparison = "NA"
        value = ","
    }
    $lattribute += $oAttribute    

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "records"
        function = "count"
        comparison = "NA"
        value = 0
    }    
    $lattribute += $oAttribute
    
    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "columns"
        function = "count"
        comparison = "NA"
        value = 0
    }
    $lattribute += $oAttribute
    
    return $lattribute
}

function New-DefaultZipAttributes {
    Param (
        [String] $CompressionType = "ZIP",
        [String] $Encryption = ""
    )
       
    [System.Collections.ArrayList]$lattribute = @()
    
    
    $oAttribute = [PSCustomObject]@{
        category = "format"
        name = "compression"
        function = "algo"
        comparison = "NA"
        value = $CompressionType
    }
    $lattribute += $oAttribute    
    
    $oAttribute = [PSCustomObject]@{
        category = "format"
        name = "encryption"
        function = "algo"
        comparison = "NA"
        value = $Encryption
    }
    $lattribute += $oAttribute    

    $oAttribute = [PSCustomObject]@{
        category = "dataset"
        name = "files"
        function = "count"
        comparison = "NA"
        value = 0
    }    
    $lattribute += $oAttribute
    
    
    return $lattribute
}

function Set-AttributeValueString {
    Param (
        # Attribute List
        [Parameter(Mandatory)]  [System.Collections.ArrayList] $Attributes,
        # Attribute Category
        [Parameter(Mandatory)] [String] $Category,
        # Attribute Key Name
        [Parameter(Mandatory)] [String] $Key,
        # Attribute Function
        [Parameter(Mandatory)] [String] $Function,
        # Attribute Value
        [Parameter(Mandatory)] [String] $Value,
        # Attribute Comparison
        [String] $Comparison = "EQ"
    )

    foreach ($item in $Attributes)
    {
        if ($item.category -eq $Category -and $item.name -eq $Key -and $item.function -eq $Function)
        {
            if ($item.comparison -eq "NA" -or $item.comparison -eq $Comparison) {
                $item.comparison = $Comparison
                $item.value = $Value
                return
            }
        }
    }

    # Add the attribute    
    $oAttribute = [PSCustomObject]@{
        category = $Category
        name = $Key
        function = $Function
        comparison = $Comparison
        value = $Value
    }    
    $Attributes += $oAttribute
    return
}


function Set-AttributeValueNumber {
    Param (
        # Attribute List
        [Parameter(Mandatory)]  [System.Collections.ArrayList] $Attributes,
        # Attribute Category
        [Parameter(Mandatory)] [String] $Category,
        # Attribute Key Name
        [Parameter(Mandatory)] [String] $Key,
        # Attribute Function
        [Parameter(Mandatory)] [String] $Function,
        # Attribute Value
        [Parameter(Mandatory)] [Decimal] $Value,
        # Attribute Comparison
        [String] $Comparison = "EQ"
    )

    foreach ($item in $Attributes)
    {
        if ($item.category -eq $Category -and $item.name -eq $Key -and $item.function -eq $Function)
        {
            if ($item.comparison -eq "NA" -or $item.comparison -eq $Comparison) {
                $item.comparison = $Comparison
                $item.value = $Value
                return
            }
        }
    }


    # Add the attribute    
    $oAttribute = [PSCustomObject]@{
        category = $Category
        name = $Key
        function = $Function
        comparison = $Comparison
        value = $Value
    }    
    $Attributes += $oAttribute
    return
}


function Set-MartiResourceAttributes {
    Param (
        # File path
        [Parameter(Mandatory)] [String] $Path,
        # File type
        [Parameter(Mandatory)] [String] $FileType,
        # Process the file for attributes
        [Switch] $ExtendedAttributes
    )


    if ($FileType -eq "CSV") {
        $lattribute = New-DefaultCsvAttributes

        if ($ExtendedAttributes) {
            $delimiter = ","
            $rowCount = 0
            $colCount = 0
            $csvData = Import-Csv $Path -Delimiter $delimiter 
            foreach ($datum in $csvData) {
                $cc = (Get-Member -InputObject $datum -type NoteProperty).count
                if ($colCount -lt $cc) {
                    $colCount = $cc
                }
                $rowCount += 1
            }
            Set-AttributeValueNumber -Attributes $lattribute -Key "records" -Category "dataset" -Function "count" -Value $rowCount
            Set-AttributeValueNumber -Attributes $lattribute -Key "columns" -Category "dataset" -Function "count" -Value $colCount
        }
    }


    if ($FileType -eq "TXT") {
        $lattribute = New-DefaultCsvAttributes

        if ($ExtendedAttributes) {
            $delimiter = "`t"
            $rowCount = 0
            $colCount = 0
            $csvData = Import-Csv $Path -Delimiter $delimiter 
            foreach ($datum in $csvData) {
                $cc = (Get-Member -InputObject $datum -type NoteProperty).count
                if ($colCount -lt $cc) {
                    $colCount = $cc
                }
                $rowCount += 1
            }
            Set-AttributeValueNumber -Attributes $lattribute -Key "records" -Category "dataset" -Function "count" -Value $rowCount
            Set-AttributeValueNumber -Attributes $lattribute -Key "columns" -Category "dataset" -Function "count" -Value $colCount
        }
    }

    if ($FileType -eq "JSON") {
        $lattribute = New-DefaultJsonAttributes
    }

    if ($FileType -eq "ZIP") {
        $lattribute = New-DefaultZipAttributes -CompressionType "ZIP"
        if ($ExtendedAttributes) {
            $shell = New-Object -Com Shell.Application
            $zipFile = $shell.NameSpace($Path)
            $items = $zipFile.Items()
            Set-AttributeValueNumber -Attributes $lattribute -Key "files" -Category "dataset" -Function "count" -Value $items.Count
        }
    }

    if ($FileType -eq "7Z") {
        $lattribute = New-DefaultZipAttributes -CompressionType "7Z"
    }

    if ($null -eq $lattribute) {
        [System.Collections.ArrayList]$lattribute = @()
    }

    return $lattribute
}



