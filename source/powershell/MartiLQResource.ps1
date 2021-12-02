
function Get-MimeType {
Param( 
    [Parameter(Mandatory)][String] $Extension
)

    $mimeType = "application/unknown";
    if ( $null -ne $Extension )
    {
        Switch ($Extension)
        {
            ".json" { $mimetype = "application/json" ; break }
            ".md" { $mimetype = "text/markdown" ; break }
            ".yml" { $mimetype = "text/yaml" ; break }
            ".rst" { $mimetype = "text/x-rst" ; break }
            ".7z" { $mimetype = "application/x-7z-compressed" ; break }
            ".mti" { $mimetype = "application/vnd.martilq.json" ; break }
            ".ttf" { $mimetype = $null ; break }
            ".eot" { $mimetype = $null ; break }
            ".woff" { $mimetype = $null ; break }
            ".woff2" { $mimetype = $null ; break }
            ".csv" { $mimetype = "text/csv" ; break }
            ".tsv" { $mimetype = "text/csv" ; break }
            Default {
                $drive = Get-PSDrive HKCR -ErrorAction SilentlyContinue;
                if ( $null -eq $drive )
                {
                    $drive = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
                }
                $ext = Get-ItemProperty HKCR:$Extension -ErrorAction SilentlyContinue;
                if ( $null -ne $ext) {
                    $mimeType = $ext."Content Type";
                }
            }
        }
    }

    return $mimeType

}


function New-MartiResource {
Param( 
    [Parameter(Mandatory)][String] $SourcePath,
    [String] $UrlPath = "",
    [switch] $ExcludeHash,
    [switch] $ExtendAttributes,
    [PSCustomObject] $Configuration = $null,
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

    if ($null -eq $Configuration) {
        $Configuration = Get-Configuration
    }

    if (Test-Path -Path $SourcePath -PathType Leaf) {
       
        $item = Get-Item -Path $SourcePath -Force 

        Write-Log "Define file $($item.FullName) "

        if ($ExcludeHash) {
            $hash = $null
        } else {
            $hash = New-MartiHash -Algorithm $Configuration.hashAlgorithm -FilePath $item.FullName
        }

        $lattribute =  Set-MartiResourceAttributes -Path $item.FullName -FileType $item.Extension.Substring(1) -ExtendedAttributes:$ExtendAttributes
        $expires = Set-DefaultExpiryDate -DocumentDate $item.LastWriteTime  -Configuration $Configuration
        $version = $Configuration.version

        $oResource = [PSCustomObject]@{ 
            title = Set-DefaultTitle -Document $item.Name -Configuration $Configuration
            uid = (New-Guid).ToString()
            documentName = $item.Name
            issuedDate = Get-Date -f $Configuration.dateTimeFormat
            modified = $item.LastWriteTime.ToString($Configuration.dateTimeFormat)
            expires = $expires.ToString($Configuration.dateTimeFormat) 
            state = $Configuration.state
            author = $Configuration.author
            length = $item.Length
            hash = $hash

            description = $null
            url = $null
            structure = $null
            version = $version
            contentType = Get-MimeType($item.Extension)
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
        signed = $false
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
    [String] $ConfigPath,
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

    $oMarti, $oConfig = New-MartiDefinition -ConfigPath $ConfigPath
    if ($null -ne $LogPath -and $LogPath -ne "") {
        $oConfig.logPath = $LogPath
    }
    if ($null -ne $urlPath -and $urlPath -ne "") {
        $oConfig.urlPrefix = $urlPath
    } else {
        $urlPath = $oConfig.urlPrefix        
    }

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

    if ($FileType -eq "MD") {
        if ($ExtendedAttributes) {
            [System.Collections.ArrayList]$lattribute = @()
            $rowCount = (Get-Content $Path).Length                
            $oAttribute = [PSCustomObject]@{
                category = "dataset"
                name = "records"
                function = "count"
                comparison = "EQ"
                value = $rowCount
            }
            $lattribute += $oAttribute
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




function Compare-MartiResource {
    Param( 
        [Parameter(Mandatory)][String] $DataSource,
        [Parameter(Mandatory)][PSCustomObject] $Resource,
        [String] $LogPath   
    ) 


    $script:LogPathName = $LogPath

    Write-Debug "Parameter: LogPath   Value: $LogPath "
    Open-Log
    Write-Log "Function 'Compare-MartiResource' parameters follow"
    Write-Log ""
    
    if ($null -eq $Resource) {
        $Global:MartiErrorId = "MRI2201"
        $message = "No resource definition supplied"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }
        
    
    if ($null -eq $DataSource -or $DataSource -eq "") {
        $Global:MartiErrorId = "MRI2202"
        $message = "No document supplied"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }

    if ($DataSource.Length -le 1000) {
        # Check if the name is a file        
        if (Test-Path -Path $DataSource) {
            $inputData = Get-Content -Path $DataSource -Raw
            Write-Host "Loading file $DataSource"
        } else {
            $inputData = $DataSource
        }
    } else {
        $inputData = $DataSource
    }

    $formatProcessed = $false
    [System.Collections.ArrayList]$lerror = @()

    if ($Resource.contentType -eq "text/csv") {
        $formatProcessed = $true

        $data = $inputData | ConvertFrom-Csv -Delim ','

        $columns = ($data | get-member -type NoteProperty).count
        $rows = @($data).count
        
        $Resource.attributes | ForEach-Object {

            if ($_.category -eq "dataset" -and $_.name -eq "records" -and $_.function -eq "count" -and $_.comparison -eq "EQ") {
                
                if ($_.value -ne $rows) {
                    $oError = [PSCustomObject]@{
                        id = "MRI2203"
                        message = "Row count does not match"
                        found = "$rows"
                        expected = "$($_.value)"
                    }
                    $lerror += $oError
                }
            }

            if ($_.category -eq "dataset" -and $_.name -eq "columns" -and $_.function -eq "count" -and $_.comparison -eq "EQ") {

                if ($_.value -ne $columns) {
                    $oError = [PSCustomObject]@{
                        id = "MRI2204"
                        message = "Column count does not match"
                        found = "$columns"
                        expected = "$($_.value)"
                    }
                    $lerror += $oError
                }
            }
            
        }


    } 
    
    
    if ($Resource.contentType -eq "application/json") {
        $formatProcessed = $true

        $data = $inputData | ConvertFrom-Json
        
        $rows = @($data.data.monitor).count
        $item = $data.data.monitor[0]
        $columns = ($item | get-member -type NoteProperty).count

        $Resource.attributes | ForEach-Object {

            if ($_.category -eq "dataset" -and $_.name -eq "records" -and $_.function -eq "count" -and $_.comparison -eq "EQ") {
                
                if ($_.value -ne $rows) {
                    $oError = [PSCustomObject]@{
                        id = "MRI2203"
                        message = "Row count does not match"
                        found = "$rows"
                        expected = "$($_.value)"
                    }
                    $lerror += $oError
                }
            }

            if ($_.category -eq "dataset" -and $_.name -eq "columns" -and $_.function -eq "count" -and $_.comparison -eq "EQ") {

                if ($_.value -ne $columns) {
                    $oError = [PSCustomObject]@{
                        id = "MRI2204"
                        message = "Column count does not match"
                        found = "$columns"
                        expected = "$($_.value)"
                    }
                    $lerror += $oError
                }
            }
            
        }


    } 


    if (!$formatProcessed) {
        $Global:MartiErrorId = "MRI2203"
        $message = "Data format not supported"
        Write-Log ($message + " " + $Global:MartiErrorId) 
        Close-Log
        throw $message
    }
    
    $status = "OK"
    if ($lerror.Count -gt 0) {
        $status = "ERROR"
    }
    $oResult = [PSCustomObject]@{
        status = $status
        errors = $lerror
    }

    Close-Log
    return $oResult
}

function Set-DefaultExpiryDate{
    Param( 
        [Parameter(Mandatory)][PSCustomObject] $Configuration,
        [Parameter(Mandatory)][Datetime] $DocumentDate,
        [Parameter][Datetime] $RunDate
    ) 

    
    if ($null -eq $oConfig.expires -or $oConfig.expires -eq "") {
        $expires = $DocumentDate.AddYears(10)
    } else {
        $factors = $oConfig.expires.Split(":")
        if ($factors[0] -eq "m") {
            $expires = $DocumentDate
        } elseif ($factors[0] -eq "r") {
            if ($null -eq $RunDate) {
                $expires = Get-Date
            } else {
                $expires = $RunDate
            }
        } 
        else {
            $expires = Get-Date
        }
        $expires = $expires.AddYears($factors[1])
        $expires = $expires.AddMonths($factors[2])
        $expires = $expires.AddDays($factors[3])
    }

    return $expires

}


function Set-DefaultTitle{
    Param( 
        [Parameter(Mandatory)][String] $Document,
        [Parameter(Mandatory)][PSCustomObject] $Configuration
    ) 

    if ($null -eq $oConfig.title -or $oConfig.title -eq "") {
        $title = $Document.Replace($item.Extension, "")
    } else {
        $title = $oConfig.title.Replace("{{documentName}}", $Document.Replace($item.Extension, ""))
        $title = $title.Replace("{{documentName.ext}}", $Document)
    }

    return $title

}

