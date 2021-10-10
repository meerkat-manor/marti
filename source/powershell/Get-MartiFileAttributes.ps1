

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
        function = "algorithm"
        comparison = "NA"
        value = $CompressionType
    }
    $lattribute += $oAttribute    
    
    $oAttribute = [PSCustomObject]@{
        category = "format"
        name = "encryption"
        function = "algorithm"
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


function Set-MartiFileAttributes {
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


