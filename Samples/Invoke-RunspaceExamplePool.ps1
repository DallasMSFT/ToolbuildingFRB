Function Invoke-RunspaceExamplePool {
	<#
  .SYNOPSIS
		This is an example of how to use a runspace pool to run a scriptblock asynchronously.
  .DESCRIPTION
		This is an example of how to use a runspace pool to run a scriptblock asynchronously.
  .PARAMETER Path
		The path to the folder to search. The default is 'C:\Temp'.
	.PARAMETER MinThreadCount
		The minimum number of threads to use. The default is 1.
	.PARAMETER MaxThreadCount
		The maximum number of threads to use. The default is 5.
	.EXAMPLE
		Invoke-RunspaceExamplePool -Verbose

		Runs the example.
  .NOTES
	  Date              Version      By                   Notes
	  ----------------------------------------------------------
	  18 Nov 2023       1.0          Dallas K. Cecil      Initial Release
  #>

	[cmdletbinding()]
	#[OutputType([boolean])]
	Param (
		[Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
		[string[]]$Path = 'C:\Temp',

		[ValidateRange(1, 10)]
		[int]$MinThreadCount = 1,

		[ValidateRange(1, 10)]
		[int]$MaxThreadCount = 5

	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Beginning $($myinvocation.MyCommand)"

		If ($MaxThreadCount -lt $MinThreadCount) {
			# OneWay
			# Throw 'MaxThreadCount is less than min.'
			$MinThreadCount = 1
			$MaxThreadCount = 5
			Write-Warning 'Thread count values incorrect; setting to default.'
		}

		$mySB = {
			[cmdletbinding()]
			Param(
				[string]$Path
			)
			Write-Verbose 'In the script block.'
			Write-Information 'Info in the sb'
			Get-ChildItem -Path $Path -Recurse
		}

		$RunspacePool = [RunSpaceFactory]::CreateRunspacePool($MinThreadCount, $MaxThreadCount)

		$RunspacePool.Open()

		[System.Collections.ArrayList]$RunspaceList = @()

	}

	Process {

		ForEach ($p in $Path) {
			Write-Verbose "Working on $p"
			$PowerShellInstance = [powershell]::Create()
			$PowerShellInstance.RunspacePool = $RunspacePool

			Write-Verbose 'Adding script to runspace.'
			$null = $PowerShellInstance.AddScript($mySB)

			$myParameterList = @{
				Path = $p
			}

			Write-Verbose 'Adding parameter to runspace'
			$null = $PowerShellInstance.AddParameters($myParameterList)

			$myRunspaceObject = [PSCustomObject]@{
				RunspaceInstance = $p
				PowerShell       = $PowerShellInstance
				AsyncResult      = $PowerShellInstance.BeginInvoke()
			}

			[void]$RunspaceList.Add($myRunspaceObject)

		}

		While ($true) {
			$myFinished = $RunspaceList.AsyncResult | Where-Object { $_.IsCompleted -eq $true }
			$myRunning = $RunspaceList.AsyncResult | Where-Object IsCompleted -EQ $false

			$myRunningCount = $myRunning.Count

			Write-Debug "Running Tasks: $myRunningCount       :: Finished tasks: $($myFinished.Count)"

			Write-Verbose 'Tasks still running.'

			Write-Progress -Activity 'Running tasks' -PercentComplete (($myFinished.Count / $RunspaceList.Count) * 100)

			Start-Sleep -Milliseconds 500

			If ($myRunning.Count -eq 0) {
				Break
			}
		}

		Write-Verbose 'Getting results.'
		ForEach ($j in $RunspaceList) {
			If ($j.AsyncResult.IsCompleted -eq $True) {
				Write-Verbose "Getting result for $($j.RunspaceInstance)"
				$myResult = $j.PowerShell.EndInvoke($j.AsyncResult)
				$myResult
			} Else {
				# This should never happen
			}
		}
	}

	End {

		$RunspacePool.Dispose()

		Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}

}
