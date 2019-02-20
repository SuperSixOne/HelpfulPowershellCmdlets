######################################################################################
Write-Host "Starting module load sequence..." -ForegroundColor Red

Write-Host "Loading ASCI PowerShell Extensions" -ForegroundColor Green
Import-Module "C:\Workspaces\PowerShell\Modules\ASCIPowershellExtensions\ASCIPowershellExtensions.psm1"

#Write-Host "Loading DeployKitsFramework" -ForegroundColor Green
#Import-Module "C:\Workspaces\Extensions\PowerShell\Modules\DeployKitsFramework"

Write-Host "Module load sequence complete!" -ForegroundColor Red
######################################################################################
# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
######################################################################################
# Load VSDEV Variables
Write-Host "`nBegin VSDEVCMD Load Sequence" -ForegroundColor Yellow
pushd "C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\Common7\Tools"
cmd /c "VsDevCmd.bat&set" |
foreach {
  if ($_ -match "=") {
    $v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
  }
}
popd