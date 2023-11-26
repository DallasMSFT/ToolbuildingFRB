

Function Get-FileList {
	<#
	.SYNOPSIS
		  Get-FileList returns a list of files in a directory
	.DESCRIPTION
		  Get-FileList returns a list of files in a directory. It can be used to return a list of files in a directory and all subdirectories. It can also be used to return a list of files in a directory and all subdirectories that match a specific file extension.
	.PARAMETER Path
		  The path to the directory to search.
	 .PARAMETER Filter
		  The file extension to search for. The default is *.*.
	 .EXAMPLE
		  Get-FileList -Path c:\temp
		  This example returns a list of all files in the c:\temp directory and all subdirectories.
	 .EXAMPLE
		  Get-FileList -Path c:\temp -Filter *.txt
		  This example returns a list of all files in the c:\temp directory and all subdirectories that have a .txt extension.

	 .NOTES
		Date              Version      By                   Notes
		----------------------------------------------------------
		18 Nov 2023       1.0          Dallas K. Cecil      Initial Release
	#>

	[cmdletbinding()]
	#[OutputType([boolean])]
	Param (
		[Parameter(Mandatory = $true,
			ValueFromPipeline = $true,
			ValueFromPipelineByPropertyName = $true,
			Position = 0)]
		[ValidateNotNullOrEmpty()]
		[string]$Path,
		[string]$Filter = '*.*'
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Beginning $($myinvocation.MyCommand)"
	}

	Process {
		$files = Get-ChildItem -Path $Path -Recurse -File

		$myEFiles = $files | Where-Object { $_.Extension -eq $filter }

		foreach ($f in $myEFiles) {
			$myCustomObject = [PSCustomObject]@{
				PSTypeName    = 'CustomerName.dkc.File'
				Name          = $f.Name
				FullName      = $f.FullName
				Length        = $f.Length
				LastWriteTime = $f.LastWriteTime
				Parent        = $f.DirectoryName
			}
			Write-Output $myCustomObject
		}

		$myEFiles
	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}

}
