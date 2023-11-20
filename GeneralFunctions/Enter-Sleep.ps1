Function Enter-Sleep {
	<#
	.SYNOPSIS
		Puts the computer to sleep.
	.DESCRIPTION
		Puts the computer to sleep or hibernate, depending on the system configuration.

	.PARAMETER ComputerName
		The name of the computer(s) to get open files on.

	.PARAMETER MonitorOnly
		Puts only the monitor(s) to sleep.

	.EXAMPLE
		Enter-Sleep

		Puts the computer to sleep or hibernate, depending on system configuration.

	.NOTES
		Change Log:
		Date              Version      By                  Notes
		---------------------------------------------------------
		08 Oct 2021       1.0          Dallas K. Cecil     Initial release
		13 Oct 2021       1.0.1        Dallas K. Cecil     Fixed hang with MonitorOnly
	#>
	[CmdletBinding(
		SupportsShouldProcess = $true
	)]

	Param(
		[Parameter(Mandatory = $false,
			ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true,
			Position = 0)]
		[string[]]$ComputerName = $env:COMPUTERNAME,

		[switch]$MonitorOnly

	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Starting $($MyInvocation.MyCommand)"

		#Is there a better way of doing this?
		If ( $ComputerName -eq '.') {
			$ComputerName[[array]::IndexOf($ComputerName, '.')] = $env:computername
		}

		$myScriptBlockComputer = {
			$myPath = Join-Path -Path (Join-Path -Path $env:windir -ChildPath 'System32' ) -ChildPath 'rundll32.exe'

			Write-Verbose "Entering sleep at $(Get-Date)"
			& $myPath powrprof.dll, SetSuspendState Sleep
		}

		$myScriptBlockMonitor = {
			$HWND = -1
			$WM_SYSCOMMAND = 0x0112
			$SC_MONITORPOWER = 0xF170
			#$MONITOR_ON = -1
			$MONITOR_OFF = 2

			$Signature = '[DllImport("user32.dll")]public static extern IntPtr PostMessage(IntPtr hWnd, UInt32 hMsg, IntPtr wParam, Int32 lParam);'
			$PostMessage = Add-Type -MemberDefinition $signature -Name 'Win32PostMessage' -Namespace Win32Functions -PassThru

			Write-Verbose "Sleeping monitor(s) at $(Get-Date)"

			$PostMessage::PostMessage($HWND, $WM_SYSCOMMAND, $SC_MONITORPOWER, $MONITOR_OFF)

		}

		If ( $MonitorOnly ) {
			$myScriptBlock = $myScriptBlockMonitor
		} else {
			$myScriptBlock = $myScriptBlockComputer
		}

	}

	Process {
		Foreach ($c in $ComputerName) {
			Write-Verbose "Working on $c"

			If ($PSCmdlet.ShouldProcess("$env:ComputerName", 'Sleep')) {
				If ($c -like $env:COMPUTERNAME) {
					& $myScriptBlock
				} Else {
					Invoke-Command -ComputerName $c -ScriptBlock $myScriptBlock
				}
			}
		}
	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($MyInvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}
}
