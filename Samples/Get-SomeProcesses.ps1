Function Get-SomeProcesses {
	<#
  .SYNOPSIS
		 Returns a subset of processes
  .DESCRIPTION
		 Simple implementation of Get-Process.
  .PARAMETER ProcessName
		 The Process name; accepts wildcards.
  .EXAMPLE
		 Get-SomeProcess

		 Returns all e* processes
	.EXAMPLE
		 Get-SomeProcess -ProcessName Explorer

		 Returns all explorer processes.
  .NOTES
	  Date              Version      By                   Notes
	  ----------------------------------------------------------
	  18 Nov 2023       1.0          Dallas K. Cecil      Initial Release
  #>

	[cmdletbinding()]
	#[OutputType([boolean])]
	Param (
		[string]$ProcessName = 'e*'
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Beginning $($myinvocation.MyCommand)"
	}

	Process {

		Try {
			Get-Process -Name $ProcessName -ErrorAction Stop
		} Catch {
			Write-Verbose 'No processes found.'
		}

	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}

}
