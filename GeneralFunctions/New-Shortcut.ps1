Function New-Shortcut {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
	<#
	.SYNOPSIS
		Creates a new shortcut.
	.DESCRIPTION
		Creates a new Windows Shortcut (i.e., .lnk) using WScript.Shell.

		Note: No validation is done on the target path--or any other parameter.

	.PARAMETER Path
		The path where the shortcut will be saved
	.PARAMETER Name
		The name of the shortcut without an extension--that will be added later.
	.PARAMETER TargetPath
		The target location of the shortcut. For example, it could be an executable, document, or any other applicable target.
	.PARAMETER Arguments
		Any arguments.
	.PARAMETER Description
		The shortcut description.
	.PARAMETER IconLocation
		The location of the icon. If empty, Windows picks the default.

		The IconLocation can be either an ICO file, an executable, or DLL.
	.PARAMETER WindowStyle
		The window style.

		Possible values are Normal, Maximized, or Minimized.

		Normal is defined as what the application determines as 'normal'.
	.PARAMETER WorkingDirectory
		The working directory.
	.PARAMETER Force
		A switch. If Force is specified and the shortcut already exists, then the shortcut is overwritten.
	.PARAMETER RunAsAdministrator
		A switch. If set, then the shortcut is set to run as an administrator.

		Note: There is no supported way to do this, so the function directly edits the shortcut file and flips some bits. Your mileage may vary and it may corrupt the file.
	.EXAMPLE
		New-Shortcut -Path c:\temp -Name NewNotepadShortcut -TargetPath C:\Windows\Notepad.exe -Description "New Notepad shortcut" -IconLocation 'C:\Windows\System32\calc.exe'

		Creates a new shortcut named NewNotepadShortcut in c:\Temp that uses the icon from c:\Windows\System32\Calc.exe.
	.NOTES

		Change Log:
		Date              Version      By                  Notes
		--------------------------------------------------------
		26 Oct 2019       1.0          Dallas K. Cecil     Initial release
		26 Apr 2020       1.1          Dallas K. Cecil     Updated help; code formatting.
		17 Jan 2022       1.2          Dallas K. Cecil     Added -RunAsAdministrator

	#>

	[cmdletbinding()]
	Param(
		[ValidateNotNullOrEmpty()][string]$Path,
		[ValidateNotNullOrEmpty()][string]$Name,
		[ValidateNotNullOrEmpty()][string]$TargetPath,
		[string]$Arguments,
		[string]$Description,
		[string]$IconLocation,
		[ValidateSet('Normal', 'Maximized', 'Minimized')][string]$WindowStyle,
		[string]$WorkingDirectory,
		[switch]$Force,
		[switch]$RunAsAdministrator
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Starting $($MyInvocation.MyCommand)"

		$myWindowStyle = switch ($WindowStyle) {
			'Normal' { 1 }
			'Maximized' { 3 }
			'Minimized' { 7 }
			Default { 1 }
		}
	}

	Process {

		$myFileName = Join-Path -Path $Path -ChildPath "$Name.lnk"

		If (Test-Path $myFileName) {
			If ($Force) {
				Write-Verbose "$myFileName exists; overwriting because -Force was specified"
			} Else {
				Throw "$myFileName exits; use -Force to overwrite."
			}
		}

		Write-Verbose "Creating shortcut at $myFileName"

		$WshShell = New-Object -ComObject WScript.Shell

		$myShortCut = $WshShell.CreateShortcut($myFileName)

		$myShortCut.TargetPath = $TargetPath
		$myShortCut.Arguments = $Arguments
		$myShortCut.Description = $Description
		If ($IconLocation -ne '') {
			$myShortCut.IconLocation	= $IconLocation
		}
		$myShortCut.WindowStyle = $myWindowStyle
		$myShortCut.WorkingDirectory = $WorkingDirectory
		$myShortCut.Save()

		# Added -RunAsAdministrator

		If ($RunAsAdministrator -eq $true) {
			Write-Verbose 'Setting RunAsAdministrator'
			$bytes = [System.IO.File]::ReadAllBytes($myFileName)
			$bytes[0x15] = $bytes[0x15] -bor 0x20 #set byte 21 (0x15) bit 6 (0x20) ON
			[System.IO.File]::WriteAllBytes($myFileNew, $bytes)
		}
	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($MyInvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}
}
