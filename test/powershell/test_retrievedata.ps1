


. .\source\powershell\New-Marti.ps1
. .\source\powershell\ConvertFrom-Ckan.ps1


if (!(Test-Path -Path ".\test\powershell\results\data")) {
    $null = New-Item -Path ".\test\powershell\results\data" -ItemType Directory
}


$bsb = "ftp://bsb.hostedftp.com/~auspaynetftp/BSB"
$bsb = "http://apnedata.merebox.com.s3.ap-southeast-2.amazonaws.com/au/bsb/BSBDirectory.csv"
Invoke-WebRequest $bsb -Method GET -OutFile ".\test\powershell\results\data\bsb.csv"
#Set-Content -Path ".\test\results\data\bsb.csv" -Value $bsbList.Content
#$bsbList.Content


$covid19j =  "https://data.nsw.gov.au/data/api/3/action/package_show?id=3dc5dc39-40b4-4ee9-8ec6-2d862a916dcf"
Invoke-WebRequest $covid19j -Method GET -OutFile ".\test\powershell\results\nsw_covid19_age.json"

$covid19 =  "https://data.nsw.gov.au/data/dataset/3dc5dc39-40b4-4ee9-8ec6-2d862a916dcf/resource/24b34cb5-8b01-4008-9d93-d14cf5518aec/download/confirmed_cases_table2_age_group.csv"
Invoke-WebRequest $covid19 -Method GET -OutFile ".\test\powershell\results\data\COVID-19 cases by notification date and age range.csv"


$covid19j =  "https://data.nsw.gov.au/data/api/3/action/package_show?id=0a52e6c1-bc0b-48af-8b45-d791a6d8e289"
Invoke-WebRequest $covid19j -Method GET -OutFile ".\test\powershell\results\nsw_covid19_location.json"

$covid19 =  "https://data.nsw.gov.au/data/dataset/0a52e6c1-bc0b-48af-8b45-d791a6d8e289/resource/5200e552-0afb-4bde-b20f-f8dd4feff3d7/download/c19_location_09.24.csv"
Invoke-WebRequest $covid19 -Method GET -OutFile ".\test\powershell\results\data\c19_location_09.24.csv"

$covid19 =  "https://data.nsw.gov.au/data/dataset/0a52e6c1-bc0b-48af-8b45-d791a6d8e289/resource/f3a28eed-8c2a-437b-8ac1-2dab3cf760f9/download/covid-case-locations-20210920-1315.json"
Invoke-WebRequest $covid19 -Method GET -OutFile ".\test\powershell\results\data\covid-case-locations-20210920-1315.json"

$covid19 =  "https://data.vic.gov.au/data/dataset/890da9b3-0976-4de3-8028-e0c22b9a0e09#embed-28becc42-9616-4d60-ac8e-a3853dbddb55"
Invoke-WebRequest $covid19 -Method GET -OutFile ".\test\powershell\results\data\covid-case-locations-20210920-1315.json"

