$inputXML = @"
<Window x:Class="ReleaseApp.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:ReleaseApp"
        mc:Ignorable="d"
        Title="Release Checker"
        ResizeMode="CanMinimize"
        Height="500" Width="800" >
    <Window.Resources>
    </Window.Resources>
    <DockPanel LastChildFill="True">
        <Grid DockPanel.Dock="Top" Height="325">
            <Grid.ColumnDefinitions>
                <ColumnDefinition />
                <ColumnDefinition />
                <ColumnDefinition />
                <ColumnDefinition />
            </Grid.ColumnDefinitions>
            <Grid.RowDefinitions>
                <RowDefinition Height="1*" />
                <RowDefinition Height="2*"/>
            </Grid.RowDefinitions>
            <!-- Version ComboBox -->
            <StackPanel Orientation="Horizontal" Margin="10,5" HorizontalAlignment="Right" VerticalAlignment="Top"  Grid.Column="3" Grid.Row="0">
                <Label Content="Version: " />
                <ComboBox x:Name="VersionPicker" Height="20" Width="125"/>
            </StackPanel>
            <!-- Functions -->
            <StackPanel x:Name="FunctionPanel" Grid.Column="1" Grid.Row="1">
                <Label Content="Available Tests: " />
                <CheckBox x:Name="SigningTest" Content="Check Assembly Signing" Margin="10,6"/>
                <CheckBox Content="FunctionB" Margin="10,6"/>
                <CheckBox Content="FunctionC" Margin="10,6"/>
            </StackPanel>
            <!-- Status -->
            <StackPanel x:Name="StatusPanel" Grid.Column="2" Grid.Row="1">
                <Label Content="Test Status: " />
                <Border BorderThickness="1" BorderBrush="Black" Padding="5,0" Margin="10,5">
                    <TextBlock x:Name="SigningTestStatus" Text="Not Run"  />
                </Border>
                <Border BorderThickness="1" BorderBrush="Black" Padding="5,0" Margin="10,5">
                    <TextBlock x:Name="FunctionBStatus" Text="Not Run"  />
                </Border>
                <Border BorderThickness="1" BorderBrush="Black" Padding="5,0" Margin="10,5">
                    <TextBlock x:Name="FunctionCStatus" Text="Not Run"  />
                </Border>
            </StackPanel>
            <!-- Execute Button -->
            <Button Content="Execute Selected Tests" Width="140" Height="20" Margin="10,5" Grid.Column="3" Grid.Row="1" VerticalAlignment="Bottom" HorizontalAlignment="Right"/>
        </Grid>
        <StackPanel>
            <!-- Console -->
            <TextBox x:Name="ConsoleBox" Margin="10" ScrollViewer.VerticalScrollBarVisibility="Auto" TextWrapping="Wrap" Height="115" />
        </StackPanel>
    </DockPanel>
</Window>
"@ 
 
$inputXML = $inputXML -replace 'mc:Ignorable="d"','' -replace "x:N",'N' -replace '^<Win.*', '<Window'
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML
#Read XAML
 
$reader=(New-Object System.Xml.XmlNodeReader $xaml)
try{
    $Form=[Windows.Markup.XamlReader]::Load( $reader )
}
catch{
    Write-Warning "Unable to parse XML, with error: $($Error[0])`n Ensure that there are NO SelectionChanged or TextChanged properties in your textboxes (PowerShell cannot process them)"
    throw
}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
  
$xaml.SelectNodes("//*[@Name]") | %{"trying item $($_.Name)";
    try {Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name) -ErrorAction Stop}
    catch{throw}
    }
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-host "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
write-Debug "Found the following interactable elements from our form:"
get-variable WPF* | Write-Debug
}
 
Get-FormVariables
 
#===========================================================================
# Use this space to add code to the various form elements in your GUI
#===========================================================================
$WPFSigningTestStatus.Text = "Hello!"                                                               
     
#Reference 
 
#Adding items to a dropdown/combo box
    #$vmpicklistView.items.Add([pscustomobject]@{'VMName'=($_).Name;Status=$_.Status;Other="Yes"})
     
#Setting the text of a text box to the current PC name    
    #$WPFtextBox.Text = $env:COMPUTERNAME
     
#Adding code to a button, so that when clicked, it pings a system
# $WPFbutton.Add_Click({ Test-connection -count 1 -ComputerName $WPFtextBox.Text
# })

#===========================================================================
# Functions
#===========================================================================

function DetermineSignatureState 
{
    Param(
    [parameter(Mandatory=$true)]
    [String]
    $FullPath,
    [parameter(Mandatory=$true)]
    [Boolean]
    $Recurse 
    )

    if (!(Test-Path -Path $FullPath)) {
        $WPFConsoleBox.Text += "$FullPath is not a valid location."
    }
        



} 

#===========================================================================
# Shows the form
#===========================================================================
DetermineSignatureState "F:\" $true
$Form.ShowDialog() | out-null