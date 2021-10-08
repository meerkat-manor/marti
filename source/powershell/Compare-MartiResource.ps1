
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
        $message = "No Marti resource definition supplied"
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

    if ($Resource.format -eq "CSV") {
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
    
    
    if ($Resource.format -eq "JSON") {
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
