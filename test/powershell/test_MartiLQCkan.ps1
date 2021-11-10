
# .\test\powershell\test_MartiLQCkan.ps1 from project root

. .\source\powershell\MartiLQ.ps1
. .\source\powershell\MartiLQItem.ps1
. .\source\powershell\ConvertFrom-Ckan.ps1

$outFile = ".\test\powershell\results\marti_test_asic.json"
$ckan = Get-Content -Path ".\docs\source\samples\json\asic_ckan_api.json" -Raw
$oMarti = ConvertFrom-Ckan -InputObject $ckan
$x = ConvertTo-Json -InputObject $oMarti  -Depth 5
Set-Content -Path $outFile -Value $x
Write-Host "Wrote converted definition to: $outFile"

$outFile = ".\test\powershell\results\marti_test_covid.json"
$covid_1 = Invoke-WebRequest "https://data.nsw.gov.au/data/api/3/action/package_show?id=793ac07d-a5f4-4851-835c-3f7158c19d15"
$oMarti = ConvertFrom-Ckan -InputObject $covid_1
$oMarti.description = "This data has been converted from NSW CKAN data source with URL 'https://data.nsw.gov.au/data/api/3/action/package_show?id=793ac07d-a5f4-4851-835c-3f7158c19d15'"
$oMarti.tags += "ckan"
$oMarti.tags += "gov"
$oMarti.tags += "nsw"
$oMarti.publisher = "NSW government (Australia)"
$x = ConvertTo-Json -InputObject $oMarti  -Depth 5
Set-Content -Path $outFile -Value $x
Write-Host "Wrote converted definition to: $outFile"


# cases
$outFile = ".\test\powershell\results\marti_test_covidcases.json"
$covid19 =  "https://data.nsw.gov.au/data/api/3/action/package_show?id=3dc5dc39-40b4-4ee9-8ec6-2d862a916dcf"
$covid_2 = Invoke-WebRequest $covid19
$oMarti = ConvertFrom-Ckan -InputObject $covid_2
$oMarti.description = "This data has been converted from NSW CKAN data source with URL '$covid19'"
$oMarti.tags += "ckan"
$oMarti.tags += "gov"
$oMarti.tags += "nsw"
$oMarti.publisher = "NSW government (Australia)"
$x = ConvertTo-Json -InputObject $oMarti  -Depth 5
Set-Content -Path $outFile -Value $x
Write-Host "Wrote converted definition to: $outFile"


# AFSL
$outFile = ".\test\powershell\results\marti_test_afsl.json"
$afsl =  "https://data.gov.au/api/3/action/package_show?id=ab7eddce-84df-4098-bc8f-500d0d9776d1"
$afsl_2 = Invoke-WebRequest $afsl
$oMarti = ConvertFrom-Ckan -InputObject $afsl_2
$oMarti.description = "This data has been converted from DATA GOV AU CKAN data source with URL '$afsl'"
$oMarti.tags += "ckan"
$oMarti.tags += "gov"
$oMarti.tags += "au"
$oMarti.publisher = "Australian Securities and Investments Commission (ASIC)"
$x = ConvertTo-Json -InputObject $oMarti -Depth 5
Set-Content -Path $outFile -Value $x
Write-Host "Wrote converted definition to: $outFile"

Write-Host "Execution completed"