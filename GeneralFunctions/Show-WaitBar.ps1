Function Show-WaitBar {
	<#
	.SYNOPSIS
		Displays a 'Knight Rider' type progress bar for operations with an unknown end time.
	.DESCRIPTION
		For operations with a determinable length, a progress bar can be used (i.e., Write-Progress). Some processes, however, require an indeterminate amount of time. Users may need a visual indication that the process is still working (i.e., not hung). That is when Show-WaitBar is useful.

		Show-WaitBar is significantly different from Write-Progress, although, from a user perspective, it appears quite similar.

		First, Show-WaitBar cannot be used within a loop as Write-Progress is typically used. Instead, Show-WaitBar is, typically, called in a separate PowerShell runspace created within another script or function or the long-running process is created in a runspace and Show-WaitBar is the 'blocking' thread that provides status to the user. Show-WaitBar is passed a ScriptBlock parameter, MonitorScriptBlock, that 'monitors' something. When the MonitorScriptBlock returns $true, Show-WaitBar ends.

		Example 1 shows a simple, interactive example of Show-WaitBar while other examples are more complex. You should experiment with a simple example before attempting a more complex implementation.

		In addition to other parameters (discussed in the respective Parameter section), Show-WaitBar takes 1 to 4 script blocks as parameters: MonitorScriptBlock, StatusScriptBlock, ActivityScriptBlock, and CurrentOperationScriptBlock. Each are discussed in their respective Parameter sections.

		Only MonitorScriptBlock is required. The other ScriptBlocks can be used to provide additional information to the user.

		Each of these script blocks have access to three variables: $CurrentLoopCount, $CurrentPercentDisplay, and $ScriptStartTime.

		$CurrentLoopCount is the total number of 'loops' displayed. A loop is a complete up or down travel of the progress bar. For example, if the progress bar travels from 0% to 100% then back to 0%, that is two 'loops.' $CurrentLoopCount could be use, for example, to stop the Show-WaitBar function. To do this, in the MonitorScriptBlock, you could add code similar to this:

		{
			If ($CurrentLoopCount -eq 50) {
				$True
			}
		}

		Another example of $CurrentLoopCount could be used in the StatusScriptBlock:

		$myStatusScriptBlock = {
			"I have looped $CurrentLoopCount times."
		}

		Similarly, $CurrentPercentDisplay can be accessed by any of the ScriptBlock parameters. For example the StatusScriptBlock of:

		{
			If ($CurrentPercentDisplay % 10 -eq 0) {
			Write-Host 'Milestone'
		}

		would write 'Milestone' approximately every 10% to the host.

		$ScriptStartTime could be used in one of the ScriptBlock parameters to display the elapsed time. Consider this StatusScriptBlock:

		{
			"Running for $(((Get-Date) - $ScriptStartTime).TotalSeconds) seconds"
		}

		This ScriptBlock would update the Status to read "Running for XYZ seconds" where XYZ is the running time.

		Note that Show-WaitBar is not designed to be precise and is useful only for long running processes.

		Extra information:

		The following ScriptBlock--shown here used as a StatusScriptBlock--will create a 'tick' sound every UpdateInterval. Note that this will only work if the computer supports a hardware-based 'beep'.

		$myStatusSB = {
			 [console]::beep(500,5)
		}

	.PARAMETER UpdateInterval
		The number of milliseconds between bar updates and how frequently the MonitorScriptBlock is called. Low numbers make the bar go faster while higher numbers make it go slower. Use your best judgement on the value based on your knowledge of the underlying task.

		Note that small numbers will put a greater strain on the system since at least one, and up to four, ScriptBlocks will be called.

		If you do not need the functionality of the three optional ScriptBlocks, do not use them. If needed, keep them small as fast. All error handling is your responsibility.
	.PARAMETER Direction
		By default, the bar starts at '0%' and moves 'Up' toward '100%' and then back toward '0%'. Changing the parameter to 'Down' has the Show-WaitBar start at '100%' and move toward '0%' and then back toward '100%'.

		UpOnly and DownOnly starts at '0%' or '100%', respectively. When the bar reaches the opposite limit (100% and 0%, respectively), the bar resets.

		Random, at every UpdateInterval, selects a random number between 1 and 99 for the display. Because of the visual overhead, strongly consider using an UpdateInterval of at least 400ms.
	.PARAMETER MonitorScriptBlock
		A ScriptBlock that does something and returns either $True or $False.

		Return $True if you want Show-WaitBar to continue 'waiting'. Return $False for it to stop.

		Note that the MonitorScriptBlock ScriptBlock runs first and then every UpdateInterval. This can create an issue. Consider the following pseudocode:

		# Create long-running process
		# Call Show-WaitBar with appropriate parameters

		In this case, it is possible that Show-WaitBar will execute the MonitorScriptBlock, which, as in one of the examples below, checks to see if the process has ended. The MonitorScriptBlock could execute before the long-running process has started. It is incumbent on you to mitigate this. A simple way of doing this is to implement a short wait before calling Show-WaitBar.

		A slightly more elegant way of doing this is to modify the MonitorScriptBlock code to return $True for a certain amount of time. For example, the following code could be included at the beginning of the MonitorScriptBlock ScriptBlock:

		If( ((Get-Date) - $ScriptStartTime).TotalMilliseconds -le 2000) {
				$True
		}

	.PARAMETER StatusScriptBlock
		A ScriptBlock that returns a string that is displayed in the Write-Progress Status area. The script block can do other tasks but it must return a non-empty string.
	.PARAMETER ActivityScriptBlock
		A ScriptBlock that returns a string that is displayed in the Write-Progress Activity area. The script block can do other tasks but it must return a non-empty string.
	.PARAMETER CurrentOperationScriptBlock
		A ScriptBlock that returns a string that is displayed in the Write-Progress CurrentOperation area. The script block can do other tasks but it must return a non-empty string.
	.PARAMETER BreakAtLoop
		A hidden parameter that defaults to [int32]::MaxValue--a really big number. Once the CurrentLoopCount greater than or equal to BreakAtLoop, Show-WaitBar will end throwing a warning the WaitBar loop count exceeded the BreakAtLoop count.

		Useful in some circumstances when may want Show-WaitBar to stop after a certain number of loops--maybe because of a hung process.

		Using the default values, Show-WaitBar will run for 6.8 years before automatically ending.
	.EXAMPLE
		# First, run Calculator manually

		$myMonitorSB = {
			$myProcess = Get-Process 'Calculator*'

			If ($myProcess) {
				$True
			} Else {
				$False
			}
		}

		Show-WaitBar -MonitorScriptBlock $myMonitorSB

		Assuming you started Calculator first (and only have one instance of Calculator running), this example will show a Show-WaitBar until the Calculator process is closed.
	.EXAMPLE
		# First, run Calculator manually

		$myMonitorSB = {
			$myProcess = Get-Process 'Calculator*'

			If ($myProcess) {
				$True
			} Else {
				$False
			}
		}

		$myActivitySB = {
			"I have been waiting for $(((Get-Date) - $ScriptStartTime).TotalSeconds) seconds."
		}

		Show-WaitBar -MonitorScriptBlock $myMonitorSB -ActivityScriptBlock $myActivitySB

		Assuming you started Calculator first (and only have one instance of Calculator running), this example will show a Show-WaitBar until the Calculator process is closed displaying 'I have been waiting for XYZ seconds.' where XYZ is the number of elapsed seconds.
	.EXAMPLE
		Function New-LongRunningTask {

			Begin {
				# Create PowerShell runspace

				$myPowerShellRunspace = [powershell]::Create()

				# Add a script to the new runspace that will actually start the long running process
				[void]$myPowerShellRunspace.AddScript({

						# Starting Notepad for example. When the user closes Notepad, this script will return.
						# This script could be much more complex.
						# Start-Process notes:
						#   -PassThru will return a System.Diagnostics.Process; it has some important and interesting properties
						#   -Wait 'hangs' the runspace and waits for the process to complete; this is what we want.
						#   Check out https://docs.microsoft.com/en-us/dotnet/api/system.diagnostics.process for more information on the System.Diagnostics.Process object.
						$myProcess = Start-Process -FilePath Notepad -PassThru -Wait

						# This is the output; used for example only
						Write-Output "User closed Notepad at $($myProcess.ExitTime)"

					})

				# Create the MonitorScriptBlock. This script block does work to monitor whatever the above script is doing.
				# It is not magic--you have to write the code. Here, we are just waiting on Notepad to end. Technically, we are waiting on the $myPowerShellRunspace to end.

				$myMonitorScriptBlock = {
					If ($myInvoke.IsCompleted -eq $true) {
						$false # Is done, stop the wait bar.
					} Else {
						$true # Not done, continue the wait bar
					}
				}
			}

			Process {
				# We start the runspace using BeginInvoke() to start a background thread
				$myInvoke = $myPowerShellRunspace.BeginInvoke()

				# Calls Show-WaitBar with an update interval of 10ms using the $myMonitorScriptBlock created in the Begin block.
				# Show-WaitBar is a 'blocking' action here and does not return control back to the user. This is what we want.
				Show-WaitBar -UpdateInterval 10 -MonitorScriptBlock $myMonitorScriptBlock

				# After Notepad is closed, the $myMonitorScriptBlock will return $False. The $myMonitorScriptBlock is called first and then every UpdateInterval (10ms in this example). There will be a delay of at least UpdateInterval between when the Notepad process ends and the Show-WaitBar is complete.

				# Get the output from the Runspace.
				$myResults = $myPowerShellRunspace.EndInvoke($myInvoke)

				# Output the results to the default stream
				$myResults
			}

			End {
				# Dispose of the PowerShell runspace--we do not want a memory leak
				$myPowerShellRunspace.Dispose()
			}
		}

		# Run the new function we just created

		New-LongRunningTask

			This example creates a new function, New-LongRunningTask, that starts a long-running process (Notepad, in this example) and then waits for the process to end--the user would close it. The Show-WaitBar is displayed.

			Read the comments in the code above to get a thorough understanding of what it is doing.

	.NOTES
		Change Log:
		Date              Version      By                  Notes
		--------------------------------------------------------
		03 Aug 2022       1.0          Dallas K. Cecil     Initial release

	#>
	[cmdletbinding(SupportsShouldProcess = $false)]
	Param(
		[Alias('Milliseconds')]
		$UpdateInterval = 100,

		[ValidateSet('Up', 'Down', 'UpOnly', 'DownOnly', 'Random')]
		$Direction = 'Up',

		[Parameter(Mandatory = $true)]
		[ScriptBlock]$MonitorScriptBlock,

		[ScriptBlock]$StatusScriptBlock = {},
		[ScriptBlock]$ActivityScriptBlock = {},
		[ScriptBlock]$CurrentOperationScriptBlock = {},

		[Parameter(DontShow)]$BreakAtLoop = [int32]::MaxValue
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Starting $($MyInvocation.MyCommand)"

		If ($Direction -eq 'Down' -or $Direction -eq 'DownOnly') {
			$CurrentPercentDisplay = 100
		}
		Else {
			$CurrentPercentDisplay = 0
		}
	}

	Process {

		$CurrentLoopCount = 1

		While ( $true ) {

			$myCheck = Invoke-Command -ScriptBlock $MonitorScriptBlock
			If ($myCheck -ne $true) {
				Write-Verbose 'Breaking because the MonitorScriptBlock returned $True'
				Break
			}

			$myProgressParams = @{
				PercentComplete = $CurrentPercentDisplay
			}

			If ($ActivityScriptBlock.Ast.Extent.Text -eq '{}') {
				# There is no ActivityScriptBlock; Activity cannot be $null or empty.
				$myActivityResult = ' '
			}
			Else {
				$myActivityResult = Invoke-Command -ScriptBlock $ActivityScriptBlock

				If ([string]::IsNullOrEmpty($myActivityResult)) {
					$myActivityResult = 'Activity is either null or empty, which is not allowed.'
				}
			}
			$myProgressParams.Activity = $myActivityResult

			If ($StatusScriptBlock.Ast.Extent.Text -eq '{}') {
				# There is no StatusScriptBlock
			}
			Else {
				$myStatusResult = Invoke-Command -ScriptBlock $StatusScriptBlock
				If ([string]::IsNullOrEmpty($myStatusResult )) {
					$myStatusResult = 'Status is either null or empty, which is not allowed.'
				}
				$myProgressParams.Status = $myStatusResult
			}

			If ($CurrentOperationScriptBlock.Ast.Extent.Text -eq '{}') {
				# There is no CurrentOperationScriptBlock
			}
			Else {
				$myCurrentOperationResult = Invoke-Command -ScriptBlock $CurrentOperationScriptBlock
				If ([string]::IsNullOrEmpty($myCurrentOperationResult)) {
					$myCurrentOperationResult = 'CurrentOperation is either null or empty, which is not allowed.'
				}
				$myProgressParams.CurrentOperation = $myCurrentOperationResult
			}

			Write-Progress @myProgressParams

			Start-Sleep -Milliseconds $UpdateInterval

			If (($CurrentPercentDisplay -ge 100) -and ($Direction -eq 'Up')) {
				$Direction = 'Down'
				$CurrentLoopCount++
			}
			ElseIf (($CurrentPercentDisplay -le 1 ) -and ($Direction -eq 'Down')) {
				$Direction = 'Up'
				$CurrentLoopCount++
			}
			ElseIf (($CurrentPercentDisplay -ge 100) -and ($Direction -eq 'UpOnly')) {
				$Direction = 'UpOnly' # Didn't change, but here for documentation
				$CurrentLoopCount++
				$CurrentPercentDisplay = 0
			}
			ElseIf (($CurrentPercentDisplay -le 0) -and ($Direction -eq 'DownOnly')) {
				$Direction = 'DownOnly' # Didn't change, but here for documentation
				$CurrentLoopCount++
				$CurrentPercentDisplay = 100
			}

			If ($Direction -eq 'Down' -or $Direction -eq 'DownOnly') {
				$CurrentPercentDisplay--
			}
			ElseIf ($Direction -eq 'Random') {
				$CurrentPercentDisplay = Get-Random -Minimum 1 -Maximum 99
			}
			Else {
				$CurrentPercentDisplay++
			}

			If ($CurrentLoopCount -ge $BreakAtLoop) {
				Write-Warning "Breaking because the WaitBar exceeded the loop count of $BreakAtLoop"
				Break
			}
		}
	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($MyInvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}
}
