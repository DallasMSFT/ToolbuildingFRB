Function Show-SampleGUI {
	<#
	.SYNOPSIS

	.DESCRIPTION

	.PARAMETER RootPath

	.EXAMPLE

	.NOTES
		Date              Version      By                   Notes
		----------------------------------------------------------
		29 Aug 2016       1.0          Dallas K. Cecil      Initial Release
	#>

	[cmdletbinding()]
	#[OutputType([boolean])]
	Param (

		[Parameter(DontShow = $true)]
		[string]$GUIPath = (Join-Path -Path $PSScriptRoot -ChildPath '..\WPF\frmMain.xaml')
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Beginning $($myinvocation.MyCommand)"

		Write-Verbose 'Adding types'
		Add-Type -AssemblyName PresentationFramework
		Add-Type -AssemblyName PresentationCore
		Add-Type -AssemblyName WindowsBase
		Add-Type -AssemblyName System.Windows.Forms

		# Sample common dialog box function; not used in this example but I threw it in here for reference
		Function Get-dkcFileName {
			[CmdletBinding()]
			Param (
				$InitialDirectory = (Get-Location),
				$Filter = 'All Files (*.*)|*.*',
				[switch]$AllowMultiSelect = $False,
				[string]$DialogTitle = 'Select file(s)'
			)

			$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
			$OpenFileDialog.InitialDirectory = $InitialDirectory
			$OpenFileDialog.Filter = $Filter
			$OpenFileDialog.Multiselect = $AllowMultiSelect
			$OpenFileDialog.Title = $DialogTitle
			$OpenFileDialog.AutoUpgradeEnabled = $true
			$OpenFileDialog.ShowDialog() | Out-Null
			$OpenFileDialog.FileNames
		}

		Write-Verbose 'Creating XAML windows GUI object'
		$inputXML = Get-Content $GUIPath -Raw
		$inputXML = $inputXML -replace 'mc:Ignorable="d"', '' -replace 'x:N', 'N' -replace '^<Win.*', '<Window'
		[XML]$XAML = $inputXML

		$myReader = (New-Object System.Xml.XmlNodeReader $xaml)
		Try {
			$frmMain = [Windows.Markup.XamlReader]::Load( $myReader )
			$frmMain.WindowStartupLocation = 'CenterScreen'
		} Catch {
			Throw $_.Exception
		}

		# Store Form Objects in PowerShell variables; this is a really cool way to doing it.
		$xaml.SelectNodes('//*[@Name]') | ForEach-Object {
			Write-Verbose "Creating $($frmMain.FindName($_.Name).GetType().Name) object for $($_.Name) named $($_.Name)."
			New-Variable -Name ($_.Name) -Value $frmMain.FindName($_.Name) -Force
		}

		Write-Verbose 'Setting control properties'
		$frmMain.Title = 'Sample GUI using PowerShell and WPF'
		$frmMain.WindowStartupLocation = 'CenterScreen' # Bad design, but it is sometimes good when writing for support staff
		$frmMain.ResizeMode = 'NoResize'
		$frmMain.Topmost = $true # Bad design, but it is sometimes good when writing for support staff
		$frmMain.ShowInTaskbar = $true
		$frmMain.WindowStyle = 'SingleBorderWindow'

		[void]$txtName.Focus() # Bad design, but it is sometimes good when writing for support staff; better to use tab order most of the time

		$btnCancel.IsCancel = $true

		$lstUsers.IsEnabled = $false

		$lstGroups.IsEnabled = $false

		Write-Verbose 'Setting control event handlers'
		$btnCancel.Add_Click({
				Write-Verbose 'Cancel button clicked'
				$frmMain.DialogResult = $false
				$frmMain.Close()
			})

		$btnOK.Add_Click({
				Write-Verbose 'OK button clicked'
				#### Do something here
				$frmMain.DialogResult = $true
				$frmMain.Close()
			})

		$btnSearch.Add_Click({
				Write-Verbose 'Search button clicked'
				#### Do something here

				# Add files in c:\temp to list box; just for testing
				$lstGroups.Items.Clear()

				$myItems = Get-ChildItem -Path 'c:\temp' | Select-Object -ExpandProperty Name | Sort-Object

				ForEach ($mmyItem in $myItems) {
					$lstUsers.Items.Add($mmyItem)
				}

				$lstUsers.IsEnabled = $true
			})

		$lstUsers.Add_SelectionChanged({
				Write-Verbose "User list selection changed to $($lstUsers.SelectedItem.ToString())"

				$lstGroups.IsEnabled = $true

				# Get groups for selected user

				$myItems = Get-ChildItem -Path 'c:\temp' | Select-Object -ExpandProperty FullName | Sort-Object
				Write-Verbose "Found $($myItems.Count) groups for $($lstUsers.SelectedItem.ToString())"

				$lstGroups.ItemsSource = $myItems
			})

		$txtName.Add_KeyUp({
				[Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseDeclaredVarsMoreThanAssignments', '')]
				$Sender = $args[0] # This variable is not used. The above line suppresses the warning in VSCode.
				[System.Windows.Input.KeyEventArgs]$e = $args[1]

				If ($e.Key -eq 'd' -and $e.KeyboardDevice.Modifiers -eq 'Control') {
					Write-Host 'This is an easter egg!' -ForegroundColor Magenta
				}
			})
	}

	Process {

		If ($frmMain.ShowDialog()) {
			'OK was clicked'
		} Else {
			# Nothing to do here
			'Cancel was clicked'
			Write-Verbose 'Canceled'
		}

	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}

}

#Show-SampleGUI -Verbose

