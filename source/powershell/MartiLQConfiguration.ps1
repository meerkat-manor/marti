


$script:SoftwareVersion = "0.0.1"
$global:default_metaFile = "##martilq##.json"


function Get-DefaultConfiguration {

    $oConfiguration = [PSCustomObject]@{
        softwareName = Get-SoftwareName 
        softwareAuthor = "Meerkat@merebox.com"
        softwareVersion = $script:SoftwareVersion

        logPath = "./logs/"
        dateFormat = "yyyy-MM-dd"
        dateTimeFormat = "yyyy-MM-ddTHH:mm:ss"
        dataPath = ""
        tempPath =  ""

        tags = @( "default", "martiLQ")
        publisher = ""
        contactPoint = ""
        license = ""
        accessLevel = "Confidential"
        rights = "Restricted"
        batch = 1.0000
        batchInc = 0.0001
        theme = ""

        author = $null
        title = "{{documentName.ext}}"
        state = "active"
        expires = "m:10:0:0"
        version = "1.0"
        urlPrefix = ""
        encoding = ""
        compression = ""
        encryption = ""
        describedBy = ""
        landingPage = ""

        hashAlgorithm = "SHA256"
        signKey_File = $null
        signKey_Password = $null

        proxy = $null
        proxy_User = $null
        proxy_Credential = $null

        loaded = $false
    }

#self._Log = mLogging()
#self._Log.SetConfig(self._oConfiguration["logPath"], self.GetSoftwareName())

    return $oConfiguration
}

function Get-Title {

}
