Function Invoke-RunspaceExample {
	<#
  .SYNOPSIS
	  This is an example of how to use a runspace to run a scriptblock asynchronously.
  .DESCRIPTION
	  This is an example of how to use a runspace to run a scriptblock asynchronously.
  .PARAMETER Path
	  The path to the folder to search. The default is 'C:\Temp'.
  .EXAMPLE
	Invoke-RunspaceExample -Verbose

	Runs the example.

  .NOTES
	  Date              Version      By                   Notes
	  ----------------------------------------------------------
	  18 Nov 2023       1.0          Dallas K. Cecil      Initial Release
  #>

	[cmdletbinding()]
	#[OutputType([boolean])]
	Param (
		 [string]$Path = 'C:\Temp'
	)

	Begin {
		 $ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Beginning $($myinvocation.MyCommand)"

		 $mySB = {
			  [cmdletbinding()]
			  Param(
					[string]$Path
			  )

			  Get-ChildItem -Path $Path

		 }

	}

	Process {

		 $myRunspace = [Powershell]::Create()

		 $null = $myRunspace.AddScript($mySB)

		 $myParameterList = @{
			  Path = $Path
		 }
		 $null = $myRunspace.AddParameters($myParameterList)

		 $myAsync = $myRunspace.BeginInvoke()

		 While ($true) {
			  If ($myAsync.IsCompleted -eq $True) {
					$myOutput = $myRunspace.EndInvoke($myAsync)
					Break
			  }
			  Else {
					Write-Verbose 'Still running'
			  }
		 }

		 $myOutput

	}

	End {
		 Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}

}
