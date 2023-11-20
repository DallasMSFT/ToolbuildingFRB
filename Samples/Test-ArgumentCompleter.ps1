Function Test-ArgumentCompleter {
	<#
	.SYNOPSIS
		Tests ArgumentCompleter
	.DESCRIPTION
		Demonstrates how to use ArgumentCompleter.
	.PARAMETER ProcessName
		The name of the process to select.
	.EXAMPLE
		# After typing 'Test-ArgumentCompleter -ProcessName, press tab to see the list of processes that start with 'a'. You can also press Ctrl+Space to see the list.
		Test-ArgumentCompleter -ProcessName

		Tests ArgumentCompleter.

	.NOTES
		Date              Version      By                   Notes
		----------------------------------------------------------
		18 Nov 2023       1.0          Dallas K. Cecil      Initial Release
	#>

	[cmdletbinding()]
	#[OutputType([boolean])]
	Param (
		[ArgumentCompleter({
				param(
					$Command,
					$Parameter,
					$WordToComplete,
					$CommandAst,
					$FakeBoundParams)

				# There are, typically, over 100 processes running on a Windows system.  Picking processes that start with 'a' for performance reasons.
				$myObjects = (Get-Process -Name 'a*'  | Select-Object -ExpandProperty Name)

				ForEach ($myItem in $myObjects) {
					If ($myItem -NotLike "$WordToComplete*") {
						Continue
					}
					If ($myItem -match '\s') {
						$CompletionText = "'$myItem'"
					} Else {
						$CompletionText = $myItem
					}
					[System.Management.Automation.CompletionResult]::new($CompletionText, $myItem, [System.Management.Automation.CompletionResultType]::ParameterValue, "Select process $myItem")
				}
			}
		)]
		[string[]]$ProcessName
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Beginning $($myinvocation.MyCommand)"
	}

	Process {
		ForEach ($p in $ProcessName) {
			Write-Host "ProcessName: $p" -ForegroundColor Cyan
		}

	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}

}
