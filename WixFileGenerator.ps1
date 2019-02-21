$FolderPath = "\\nas1\builds\ActiveBatch\V12\PrivateBuild\merge\12.0.0.1167\Java\lib"
$Files = Get-ChildItem $FolderPath
$Completed = @()

foreach ($file in $Files)
{
    if ($file.BaseName.Contains("-"))
    {
        $ComponentID = $file.BaseName.Replace('-', '')
    }
    else
    {
        $ComponentID = $file.BaseName
    }

    $Completed += "<File Id=`"$ComponentID`" Source=`"`$(var.BinariesDirectory)\Java\lib\$($file.Name)`"/>"
}