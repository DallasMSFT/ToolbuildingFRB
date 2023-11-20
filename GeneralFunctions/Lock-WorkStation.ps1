Function Lock-WorkStation {
	<#
		.SYNOPSIS
			Locks the workstation.
		.DESCRIPTION
			Locks the workstation by using the Windows API.

			This only works interactively.

		.EXAMPLE
			Lock-WorkStation

			Locks the local workstation.

		.NOTES

			Change Log:
			Date              Version      By                  Notes
			--------------------------------------------------------
			13 Apr 2018       1.0          Dallas K. Cecil     Initial release
			28 Dec 2018       1.1          Dallas K. Cecil     Set code to test if function is running remote and, if so, reports a warning and exists.

	#>

	If ($null -ne $PSSenderInfo) {
		Write-Warning '$($MyInvocation.MyCommand) cannot be executed in a remote session; exiting.'
		Break # Exit the function
	}

	$signature = '[DllImport("user32.dll", SetLastError = true)] public static extern bool LockWorkStation();'

	$LockWorkStation = Add-Type -MemberDefinition $signature -Name 'Win32LockWorkStation' -Namespace Win32Functions -PassThru

	$LockWorkStation::LockWorkStation() | Out-Null

}
