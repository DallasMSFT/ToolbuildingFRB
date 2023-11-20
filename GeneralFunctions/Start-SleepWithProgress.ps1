Function Start-SleepWithProgress {
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '', Scope='Function')]
	<#
	.SYNOPSIS
	Sleeps while showing a progress bar.
	.DESCRIPTION
	Replaces Start-Sleep.  This function sleeps for the specified number of minutes while showing a progress bar.  By default, the progress bar counts down.
	.PARAMETER SleepInMinutes
	The number of minutes to sleep.
	.PARAMETER UpdateIntervalInSeconds
	Updates the progress bar every UpdateIntervalInSeconds.
	.PARAMETER DoNotShowProgress
	Does not show the progress bar.
	.PARAMETER Activity
	Specifies the first line of text in the heading above the status bar. This text describes the activity whose progress is being reported.
	.PARAMETER Status
	Specifies the second line of text in the heading above the status bar. This text describes current state of the activity.
	.PARAMETER ProgressBarCountsUp
	Normally the progress bar, if displayed, counts down from 100% to 0%.  If set, then the progress bar starts at 0% and goes to 100%.

	Has no effect if DoNotShowProgress is set.
	.PARAMETER ScriptBlock
	If included, the ScriptBlock is executed after the timer is complete

	WARNING: The ScriptBlock executes under the context of the account running Start-SleepWithProgress and no validation is done on the ScriptBlock or Arguments.
	.PARAMETER ScriptBlockArgs
	The arguments, in string format, to the ScriptBlock.

	Only useful if ScriptBlock is included.
	.EXAMPLE
	Start-SleepWithProgress -Minutes 5 -UpdateIntervalInSeconds 1 -Activity 'Playing' -Status 'asdf'

	Sleeps for 5 minutes updating every second with an Activity of 'Playing' and a Status of 'asdf'

	.NOTES

	Version History

	Date              Version      By                  Notes
	----------------------------------------------------------
	07 Sep 2016       1.0          Dallas K. Cecil     Initial Release
	23 Sep 2016       1.0.1        Dallas K. Cecil     Fixed a write-progress bug
	20 Aug 2018       1.0.2        Dallas K. Cecil     Added Hours and "count down" progress bar
	14 Sep 2018       1.0.3        Dallas K. Cecil     Added ProgressBarCountsUp switch
	28 Apr 2020       1.5          Dallas K. Cecil     Added ScriptBlock and ScriptBlockArgs
	29 Apr 2020       1.5.1        Dallas K. Cecil     Fixed ScriptBlock bug
	18 May 2020       1.5.2        Dallas K. Cecil     Completely fixed the ScriptBlock bug

	#>
	[cmdletbinding(DefaultParameterSetName = 'Minute parameter group')]
	param(
		[parameter(ParameterSetName = 'Minute parameter group', Mandatory = $True)] [Alias('SleepInMinutes')][int]$Minutes,
		[parameter(ParameterSetName = 'Seconds parameter group', Mandatory = $True)][Alias('SleepInSeconds')][int]$Seconds,
		[parameter(ParameterSetName = 'Hour parameter group', Mandatory = $True)]   [Alias('SleepInHours')]  [int]$Hours,
		[int]$UpdateIntervalInSeconds = 1,
		[switch]$DoNotShowProgress,
		[string]$Activity = 'Sleeping',
		[string]$Status = '',
		[switch]$ProgressBarCountsUp,
		[scriptblock]$ScriptBlock,
		[string]$ScriptBlockArgs
	)

	switch ($PsCmdlet.ParameterSetName) {
		'Seconds parameter group'	{ Write-Verbose 'SleepInSeconds parameter block'; $SleepTime = 1 * $Seconds * 1 }
		'Minute parameter group'	{ Write-Verbose 'SleepInMinutes parameter block'; $SleepTime = $Minutes * 60 * 1 }
		'Hour parameter group'		{ Write-Verbose 'SleepInHours parameter block';   $SleepTime = 60 * 60 * $Hours }
		default { Write-Verbose 'Default'; $SleepTime = 60 }
	}

	[int32]$SecondsLeft = (($SleepTime ) - 0)
	for ($i = 1; $i -lt ($SleepTime) / $UpdateIntervalInSeconds; $i++) {
		$TotalTime = $UpdateIntervalInSeconds * $i

		If ($DoNotShowProgress) {
			# Do Nothing
		} Else {
			If ($Status -eq '') {
				$myPercentComplete = 0
				If ($ProgressBarCountsUp) {
					$myPercentComplete = ((($TotalTime / $SleepTime) * 100))
				} Else {
					$myPercentComplete = (100 - (($TotalTime / $SleepTime) * 100))
				}
				Write-Progress -SecondsRemaining $SecondsLeft -Activity $Activity -PercentComplete $myPercentComplete
			} Else {
				Write-Progress -SecondsRemaining $SecondsLeft -Activity $Activity -Status $Status
			}
		}
		Start-Sleep -Seconds $UpdateIntervalInSeconds
		$SecondsLeft = (($SleepTime) - $TotalTime)
	}

	If ($DoNotShowProgress) {
		# Do Nothing
	} Else {
		If ($Status -eq '') {
			Write-Progress -SecondsRemaining 0 -Activity $Activity
		} Else {
			Write-Progress -SecondsRemaining 0 -Activity $Activity -Status $Status
		}
	}

	If (($null -eq $ScriptBlock) -or ([System.String]::IsNullOrEmpty($ScriptBlock.ToString()))) {
		Write-Verbose 'ScriptBlock is empty.'
	} else {
		Write-Verbose 'Executing ScriptBlock'
		& $ScriptBlock $ScriptBlockArgs
	}
}
