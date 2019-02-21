<#
	My Function
#>
function Test-Module {
	Write-Host "All Systems GO!" -ForegroundColor Red
}

<#
	*
	* Misc
	*
#>

<#
	Clear the Saved Event logs folder so that next time the Event Viewer starts,
	no external logs will be present. 
#>
<#
function Clear-ActiveBatchEventLogs {
	[cmdletbinding()]
	param(
		[string]$ServerName = "localhost"
	)
	Clear-EventLog -ComputerName $ServerName -LogName
	Write-Verbose "Purging Saved Event Files: $TargetPath"
	Remove-Item $TargetPath
	Write-Verbose "Purge Completed."
}
#>

<#
	Clear the Saved Event logs folder so that next time the Event Viewer starts,
	no external logs will be present. 
#>
function Delete-SavedEventLogs {
	[cmdletbinding()]
	param(
		[string]$SavedEventPath = "C:\ProgramData\Microsoft\Event Viewer\ExternalLogs"
	)
	$TargetPath = [string]::Concat($SavedEventPath, "\*.xml")
	Write-Verbose "Purging Saved Event Files: $TargetPath"
	Remove-Item $TargetPath
	Write-Verbose "Purge Completed."
}

<#
	Sends a parameter change to the targeted service - either JSS or Agent.
#>
function Send-ParameterChange {
	[cmdletbinding()]
	param(
		[string]$ServerName = "localhost",
		[switch]$ExecutionAgent,
		[switch]$JobScheduler
	)
	# Trace
	Write-Debug "Send-ParameterChange started.."
	Write-Verbose "Target Server: $($ServerName)"
	if($ExecutionAgent)
	{
		$service = Get-Service abateagent -ComputerName $ServerName
	}
	elseif ($JobScheduler)
	{
		$service = Get-Service abatjss -ComputerName $ServerName
	}
	else
	{
		throw "No service specified."
	}
	$service.ExecuteCommand(128) 
	Write-Debug "Send-ParameterChange complete."
}

<#
	Causes the JSS log to roll over. 
#>
function Send-LogRollover {
	[cmdletbinding()]
	param(
		[string]$ServerName = "localhost",
		[switch]$ExecutionAgent,
		[switch]$JobScheduler
	)
	# Trace
	Write-Debug "Send-ParameterChange started.."
	Write-Verbose "Target Server: $($ServerName)"
	if($ExecutionAgent)
	{
		$service = Get-Service abateagent -ComputerName $ServerName
	}
	elseif ($JobScheduler)
	{
		$service = Get-Service abatjss -ComputerName $ServerName
	}
	else
	{
		throw "No service specified."
	}
	# Execute the Rollover
	$service.ExecuteCommand(129) 
	Write-Debug "Send-ParameterChange complete."
}

<#
	*
	* Package Publishing
	*
#>

<#
	Function is designed to call the BuildPackage.cmd and deploy a package to a JSS
#>
function Publish-AbatPackage {
	[cmdletbinding()]
	param(
		[string]$Root = $env:GitRoot,
		[string]$PackageName,
		[string]$SchedulerMachine = "localhost"
	)
	# Call the build package
	$Packager = $Root + "\ActiveBatch-Mirror\BuildPackage.cmd"
	$ProcessResult = Start-Process -FilePath $Packager -ArgumentList $PackageName,$SchedulerMachine -Wait -PassThru
	
	Write-Host $ProcessResult.StandardOutput.ToString()
}

<#
	Function is designed to copy Java Jar files from there build folders and update the live agent on the machine.
#>
function Publish-AbatJavaPackages {
	[cmdletbinding()]
	param(
		[string]$Root = $env:GitRoot,
		[string]$TargetPath = "C:\Program Files\ASCI\ActiveBatchV11\Java"
	)
	# Compute Source
	$SourcePath = $Root + "\ActiveBatch-Mirror\Java"
	Write-Verbose "The source path to locate files: $SourcePath"
	# Compute Target
	Write-Verbose "The target path to deploy files: $TargetPath"

	################
	##### Main #####
	################
	# Copy Files
	Write-Verbose "Start Time: $((Get-Date).ToString("MM-dd-yyyy HH:mm:ss"))"
	# AbatJWFH
	Write-Verbose "Copying AbatJWFH:"
	Copy-Item -Path "$SourcePath\AbatWFH\dist\AbatWFH.jar" -Destination $TargetPath -Force
	# AbatJavaCommands
	Write-Verbose "Copying AbatJavaCommands:"
	Copy-Item -Path "$SourcePath\AbatJavaCommands\dist\AbatJavaCommands.jar" -Destination "$TargetPath\Lib" -Force
	# ActiveBatchCommon
	Write-Verbose "Copying ActiveBatchCommon:"
	Copy-Item -Path "$SourcePath\ActiveBatchCommon\dist\ActiveBatchCommon.jar" -Destination "$TargetPath\Lib" -Force
	# AbatJobSteps
	Write-Verbose "Copying AbatJobSteps:"
	Copy-Item -Path "$SourcePath\AbatJobSteps\dist\AbatJobSteps.jar" -Destination "$TargetPath\Lib" -Force
	
	###############
	##### WEB #####
	###############
	# WebServiceProxies
	Write-Verbose "Copying WebServiceProxies:"
	Copy-Item -Path "$SourcePath\extlib\WebServiceProxies.jar" -Destination "$TargetPath\Lib" -Force
	# WebServiceProxies.ObjectFactory
	Write-Verbose "Copying WebServiceProxies.ObjectFactory:"
	Copy-Item -Path "$SourcePath\WebServiceProxies.ObjectFactory\dist\WebServiceProxies.ObjectFactory.jar" -Destination "$TargetPath\Lib" -Force
	# Copy Complete
	Write-Verbose "Copying Complete."
}

<#
	*
	* Installation
	*
#>
<#
function Install-AbatKit {

	[cmdletbinding()]
	param(
		[string]$Branch = "Dev",
		[string]$Build = "Current",
		[switch]$FullInstall
	)

	###### INIT ######
	$ServiceUser = "abatservice@advsyscon.com"
	$ServicePassword = "ve@eY5+a"
	$SerialKeys = "1-1A001101-23AA-K16336-0001,1-44001101-54F7-K16336-0001,1-46001101-00BD-K16336-0001,1-45001101-CE20-K16336-0001,1-41001101-D978-K16336-0001,1-10001101-CB61-K16336-0001,1-42001101-85C3-K16336-0001,1-43001101-AEAF-K16336-0001,1-13001101-D790-K16336-0001,1-14001101-489B-K16336-0001,1-0C064101-88AE-K16336-0001,1-26064101-68B1-K16336-0001,1-17001101-0AD7-K16336-0001,1-16001101-BB0B-K16336-0001,1-47001101-B8FD-K16336-0001,1-15001101-774D-K16336-0001,1-18001101-7529-K16336-0001,1-1D001101-89CF-K16336-0001,1-24001101-576B-K16336-0001,1-34001101-0F52-K16336-0001,1-48001101-09E8-K16336-0001,1-30001101-1110-K16336-0001,1-31001101-11B3-K16336-0001,1-28001101-5167-K16336-0001,1-40001101-3440-K16336-0001,1-27001101-B4A4-K16336-0001,1-39001101-B741-K16336-0001,1-36001101-F8D7-K16336-0001,1-3A001101-668A-K16336-0001,1-1C001101-D291-K16336-0001,1-37001101-8D7A-K16336-0001,1-2A001101-111A-K16336-0001,1-29001101-2D6D-K16336-0001,1-32001101-A555-K16336-0001,1-35001101-4B79-K16336-0001,1-2B001101-6FD4-K16336-0001,1-25001101-538D-K16336-0001,1-33001101-5AD9-K16336-0001,1-2F001101-1F7B-K16336-0001,1-2D001101-8286-K16336-0001,1-22001101-C8C2-K16336-0001,1-38001101-4ACB-K16336-0001,1-2E001101-0825-K16336-0001,1-23001101-F5E2-K16336-0001,1-2C001101-1320-K16336-0001,1-0C07E101-E985-K17003-0001"
	$DBServer = "MMIHALIK"
	$DBName = "DEV_DB_V10"
	###### FUNCTIONS ######
	function TerminateProcesses {
		$AbatAdmin = Get-Process AbatAdmin -ErrorAction SilentlyContinue
		if($AbatAdmin)
		{
			$AbatAdmin.CloseMainWindow()
			Sleep 5
			if(!$AbatAdmin.HasExited){
				$AbatAdmin | Stop-Process -Force
			}
		}
		Write-Debug "Process termination sequence complete."
	}
	function ExecuteKitInstall {
		# Set Temp
		Set-Location -Path C:\Temp
		if($FullInstall)
		{
			Start-Process -FilePath "msiexec.exe" -ArgumentList "/qr /norestart /i C:\Temp\ActiveBatchX64.msi /lv* C:\Temp\ActiveBatchx64.msi.log `
			ADDLOCAL = `
			ABAT_DB_SETUP_TYPE=SetupExistingDatabase ABAT_DB_TYPE=SQLServer ABAT_DB_DATASOURCE=$DBServer ABAT_DB_AUTHENTICATION_TYPE=Windows ABAT_SQLSERVER_SCHEMA=$DBName `
			ABAT_JSS_USERNAME=$ServiceUser ABAT_JSS_PASSWORD=$ServicePassword ABAT_EA_USERNAME=$ServiceUser ABAT_EA_PASSWORD=$ServicePassword ABAT_SERIAL_KEY=$SerialKeys" -Wait -PassThru
		} else {
			Start-Process -FilePath "msiexec.exe" -ArgumentList "/qr /norestart /i C:\Temp\ActiveBatchX64.msi /lv* C:\Temp\ActiveBatchx64.msi.log REINSTALL=ALL REINSTALLMODE=vomus" -Wait -PassThru
		}
		#Pop
		Pop-Location
		Write-Debug "Installation execution sequence complete."
	}
	###### Main ######
	Write-Progress -Activity "Installing ActiveBatch" -Status "Preparing..." -PercentComplete 0
	# Compute Branch Main
	$SourceDir = "\\nas1\builds\ActiveBatch\" + $Branch + "\" + $Build
	Write-Verbose "Source Directory: $SourceDir"
	Write-Progress -Activity "Installing ActiveBatch" -Status "Copying Installation Media..." -PercentComplete 25
	# Copy Install Media
	Copy-Item -Path "$SourceDir\ActiveBatchx64.msi" -Destination "C:\Temp" -Force

	if($FullInstall){
		# Remove old version
		Write-Progress -Activity "Installing ActiveBatch" -Status "Uninstalling Older Version..." -PercentComplete 35
		$app = Get-WmiObject -Class Win32_Product -Filter "Name = 'ActiveBatch V11 (64-bit)'" -ErrorAction SilentlyContinue
		if ($app){
			$app.Uninstall()
		}
		Write-Debug "Uninstall sequence complete."
	}

	# Terminate Processes
	Write-Progress -Activity "Installing ActiveBatch" -Status "Terminating Open Processes..." -PercentComplete 50
	TerminateProcesses
	# Start Installation
	Write-Progress -Activity "Installing ActiveBatch" -Status "Starting Installation..." -PercentComplete 60
	ExecuteKitInstall
	# Installation Complete
	Write-Progress -Activity "Installing ActiveBatch" -Status "Installation Complete!" -PercentComplete 100
	Write-Verbose "Installation Complete!"
}
#>