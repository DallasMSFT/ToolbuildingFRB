Function Test-DynamicParameter {
	<#
	.SYNOPSIS
		Tests Dynamic Parameters
	.DESCRIPTION
		Demonstrates how to use Dynamic Parameters.

		Dynamic parameters can be used to create parameters that are not known until runtime.  This is useful when you want to create a parameter that has a ValidateSet that is not known until runtime. They can also be used to create parameters that are only available when certain conditions are met.

		To use a dynamic parameter, you must first create a dictionary of parameters.  Then you create a RuntimeDefinedParameterDictionary object and add the parameters to it.  Finally, you return the RuntimeDefinedParameterDictionary object.

		They can be used in conjunction with ValidateSet, but you must add the ValidateSet to the attributes collection of the parameter.

		You can also use them to create parameters that are only available when certain conditions are met.  For example, you could create a parameter that is only available when the user is a member of a certain group.

		Note: They can be very slow to load, so you should only use them when necessary. If you are using them to create a ValidateSet, you should consider using ArgumentCompleter instead.

		Note 2: They can be very difficult to debug.
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
		# Notice there are no parameters here--they are dynamically added below.
	)

	DynamicParam {
		# Create the dictionary
		$RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

		$ParameterName = 'ProcessName'

		$AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

		#$ParameterAttribute.ParameterSetName = 'Name' # This is where you would set the ParameterSetName if you wanted to use it.

		$ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
		$ParameterAttribute.Mandatory = $False

		$AttributeCollection.Add($ParameterAttribute)

		[string[]]$arrSet = (Get-Process -Name 'a*'  | Select-Object -ExpandProperty Name)
		$ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

		$AttributeCollection.Add($ValidateSetAttribute)  # Add the ValidateSet to the attributes collection

		# Create and return the dynamic parameter(s)
		$RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string[]], $AttributeCollection)

		$RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)

		Return $RuntimeParameterDictionary
	}


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
