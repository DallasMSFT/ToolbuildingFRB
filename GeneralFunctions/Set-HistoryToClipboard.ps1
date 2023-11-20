Function Set-HistoryToClipboard {
	<#
	 .Synopsis
		 Copies history to the clipboard
	 .DESCRIPTION
		 Copies the command line of a history item to the clipboard.
	 .PARAMETER ID
		  The history ID to copy to the clipboard.
	 .EXAMPLE
		 Set-HistoryToClipboard -ID 15

		 Sets the command line of the 15th history item to the clipboard.
	 #>
	[cmdletbinding()]
	[Alias('hc')]
	Param(
		[long[]]$ID = (Get-History -Count 1).ID
	)

	If ((Get-History).Count -le 0) {
		Write-Warning 'No clipboard history; nothing to do.'
	} Else {
		Get-History -Id $ID | Select-Object -ExpandProperty CommandLine | Set-Clipboard
	}
}
