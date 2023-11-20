Function Get-HostsFileEntry {
	<#
	.SYNOPSIS
		Gets hosts file entries.
	.DESCRIPTION
		Gets hosts file entries.

		By default, gets the hosts file entries from the local systems default location. If the -Path parameter is used, any hosts file can be read.
	.PARAMETER ComputerName
		The name(s) of the computers.
	.PARAMETER Path
		The path to the hosts file (including file name).
	.PARAMETER ShowProgress
		A switch. If set, shows a progress bar.
	.PARAMETER HostName
		Only returns host file entries that match HostName.
	.PARAMETER IPAddress
		Only returns host file entries that match IPAddress.
	.EXAMPLE
		Get-HostsFileEntry

		Returns the entries in the system's hosts file
	.NOTES
		Change Log:
		Date              Version      By                  Notes
		--------------------------------------------------------
		23 Apr 2020       1.0          Dallas K. Cecil     Initial release
		27 Apr 2020       1.5          Dallas K. Cecil     Added support for remote computers (not tested with remote Linux, however)
		18 May 2020       1.6          Dallas K. Cecil     Added filter support for HostName and IPAddress
	#>
	[cmdletbinding(DefaultParameterSetName = 'DefaultParameterSet')]
	Param(
		[string[]]$ComputerName = $env:COMPUTERNAME,
		[string]$Path = '',
		[switch]$ShowProgress,
		[parameter(ParameterSetName = 'HostName')][string[]]$HostName,
		[parameter(ParameterSetName = 'IPAddress')][IPAddress[]]$IPAddress
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Starting $($MyInvocation.MyCommand)"

		#Region RegularExpressionInfo
		# Old Pattern only matches IPv4
		# $Pattern = '^(?<blankSpaceStart>\s*)(?<IP>\d{1,3}(\.\d{1,3}){3})\s+(?<Host>[\w.]+)(?<beforeComment>[\s]*)(?<CommentChar>[#]{0,56}\s*)(?<Comment>.*)'

		# Good luck figuring this out...here are some hints:
		# ^(?<blankSpaceStart>\s*)                              # Blank space at start of line
		# (?<IP>                                                # Open IP section
		# (                                                     # Open IPv6 section
		# (?:                                                   # Open IPv6 section
		# (?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}                    # Standard IPv6
		# |(?=(?:[A-F0-9]{0,4}:){0,7}[A-F0-9]{0,4})             # Compressed IPv6 with at most 7 colons
		# (([A-F0-9]{1,4}:){1,7}|:)((:[A-F0-9]{1,4}){1,7}|:)    # IPv6   and at most 1 double colon
		# |(?:[A-F0-9]{1,4}:){7}:|:(:[A-F0-9]{1,4}){7}          # IPv6 Compressed with 8 colons
		# )                                                     # Close IPv6 section
		# )                                                     # Close IPv6 section
		# |                                                     # or
		# (                                                     # Open IPv4 Section
		# (?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])
		# )                                                     # Close IPv4 Section
		# )                                                     # Close IP section
		# \s+                                                   # White space after IP address
		# (?<Host>[\w.]+)                                       # Host name
		# (?<beforeComment>[\s]*)                               # White space after host name
		# (?<CommentChar>[#]{0,56}\s*)                          # The '#' comment character; between 0 and 56 times. Why 56? Who knows.
		# (?<Comment>.*)                                        # The comment
		#EndRegion

		$mySB = {
			[cmdletbinding()]
			Param(
				[string]$Path
			)

			$Pattern = '^(?<blankSpaceStart>\s*)(?<IP>((?:(?:[A-F0-9]{1,4}:){7}[A-F0-9]{1,4}|(?=(?:[A-F0-9]{0,4}:){0,7}[A-F0-9]{0,4})(([A-F0-9]{1,4}:){1,7}|:)((:[A-F0-9]{1,4}){1,7}|:)|(?:[A-F0-9]{1,4}:){7}:|:(:[A-F0-9]{1,4}){7}))|((?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])))\s+(?<Host>[\w.]+)(?<beforeComment>[\s]*)(?<CommentChar>[#]{0,56}\s*)(?<Comment>.*)'

			If ($Path -eq '') {
				$Path = If ($PSEdition -eq 'Desktop' -or $IsWindows) {
					"$($env:SystemRoot)\System32\drivers\etc\hosts"
					Write-Verbose 'System is Windows.'
				} elseif ($PSEdition -eq 'Core' -and $IsLinux) {
					'/etc/hosts'
					Write-Verbose 'System is Linux'
				}
			}
			Write-Verbose "Using hosts file path: $Path"

			ForEach ($entry in (Get-Content -Path $Path)) {

				If ( $entry -match $Pattern ) {
					$HostEntry = [pscustomobject]@{
						PSTypeName = 'dkc.HostsFileEntry'
						Computer   = $env:COMPUTERNAME
						HostName   = $Matches.Host
						IPAddress  = [IPAddress]$Matches.IP
						Comment    = $Matches.Comment
					}
					$HostEntry
				}
			}
		}
	}

	Process {

		Write-Verbose "Getting ready to process"

		$iLoopCount = 0

		ForEach ($c in $ComputerName) {
			Write-Verbose "Working on: $c"

			If ($ShowProgress) {
				Write-Progress -Activity "Working on $c" -PercentComplete (($iLoopCount / $ComputerName.Count ) * 100)
			}

			If ($c.ToUpper() -eq $Env:ComputerName.ToUpper()) {
				$myOutput = Invoke-Command -ScriptBlock $mySB -ArgumentList $Path
			} Else {
				Try {
					$myOutput = Invoke-Command -ComputerName $c -ScriptBlock $mySB -ArgumentList $Path -ErrorAction Stop
				} Catch {
					Write-Warning "Error connecting to $c"
				}
			}

			If ($PSCmdlet.ParameterSetName -eq 'HostName') {
				$myOutput | Where-Object { $HostName -contains $_.HostName }
			} ElseIf ($PSCmdlet.ParameterSetName -eq 'IPAddress') {
				$myOutput | Where-Object { $IPAddress -contains $_.IPAddress }
			} Else {
				$myOutput
			}

			$iLoopCount += 1
		}
	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($MyInvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}
}
