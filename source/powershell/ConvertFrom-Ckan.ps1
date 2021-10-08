

function ConvertFrom-Ckan 
{
Param( 
    [Parameter(Mandatory)][String] $InputObject
) 

    $oCkan = ConvertFrom-Json -InputObject $InputObject

    $oMarti = New-MartiDefinition

    $oMarti.title = "Conversion from CKAN"
    $oMarti.state = $oCkan.result.state
    $oMarti.uid = $oCkan.result.id
    $oMarti.contactPoint = $oCkan.result.contact_point
    $oMarti.license = $oCkan.result.license_id
    $oMarti.description = $oCkan.result.notes
    
    $hashAlgo = "SHA256"
    $version = "1.1.0"
    
    [System.Collections.ArrayList]$lresource = @()

    $oCkan.result.resources | ForEach-Object {

        $idx = $_.url.LastIndexOf("/")
        if ($idx -gt 1) {
            $name = $_.url.Substring(($idx+1))
        } else {
            $name = ""
        }

        $oResource = [PSCustomObject]@{ 
            title = $_.name
            uid = $_.id
            documentName = $name
            issuedDate = $_.created
            modified = $_.last_modified
            state = $_.state
            author = $oCkan.result.author
            length = $_.size
            hash = $_.hash
            hashAlgo = $hashAlgo   

            description = $_.description
            url = $_.url
            version = $version
            format = $_.format
            compression = ""
            encryption = ""
        }
       
        $lresource += $oResource

    }

    $oMarti.resources = $lresource


    return $oMarti

}
