################################################################################################################
####
##
## ORIGINAL PS SCRIPT FROM: MichaelMihalik
##
####

Param(
    [string]$HomeDirString,
    [string]$ServerName,
    [string]$DatabaseName
)
############globals############
$ErrorActionPreference = "continue"
$script:Exclusions = @("tests", "triggers","setup")
############FUNCTIONS############
function IterateDirectories($directory)
{
    $iHomeDir = Get-ChildItem $directory
    #
    foreach($iFile in $iHomeDir)
    {
       Write-Host "Executing Procedure: " $iFile
       InvokeCmd $iFile.FullName
    }
}
function InvokeCmd($inputFilePath)
{
    #Write-Host $inputFilePath
    Invoke-Sqlcmd -InputFile $inputFilePath -ServerInstance $ServerName -Database $DatabaseName
}
############MAIN############
##Validate##
if([string]::IsNullOrEmpty($HomeDirString)){
    $HomeDirString = "C:\asci\ActiveBatch\V10\Release\JobScheduler\Database\SqlServer"
}
if([string]::IsNullOrEmpty($ServerName)){
    $ServerName = "PRD3002SUPSQL"
}
if([string]::IsNullOrEmpty($DatabaseName)){
    $DatabaseName = "ASCICAS-00061299"
}
#Set HomeDir
Write-Host -ForegroundColor Yellow "Home Directory: " $HomeDirString
$HomeDir = Get-ChildItem $HomeDirString
#push
Push-Location
##Loop##
foreach($obj in $HomeDir)
{ 
    #If an exclusion list item is found -- skip it
    if($Exclusions.Contains($obj.Name))
    {
        continue
    }

    #Otherwise - detect this is a dir/file
    if($obj -is [System.IO.DirectoryInfo])
    {
        IterateDirectories $obj.FullName
    }
    elseif ($obj -is [System.IO.FileInfo])
    {
        Write-Host "Executing Procedure: " $obj
        InvokeCmd $obj.FullName
    }
}
#Add Triggers Later as to not overwrite them.
if($HomeDir.Length -eq 0){
    return
}
$triggersPath = $HomeDir.DirectoryName.Item(0) + "\triggers";
$triggersDir = Get-ChildItem $triggersPath
foreach($obj in $triggersDir)
{
    Write-Host "Executing Procedure: " $obj
    InvokeCmd $obj.FullName
}
#Pop
Pop-Location