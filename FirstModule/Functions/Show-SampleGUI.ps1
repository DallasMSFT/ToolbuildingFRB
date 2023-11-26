Function Show-SampleGUI {
	<#
	.SYNOPSIS
		Show a sample GUI using PowerShell and WPF.
	.DESCRIPTION
		Use this function to show a sample GUI using PowerShell and WPF. It is not a great example of a GUI, but it does show how to use a GUI.

		You can use this function as a template for creating your own GUIs.

		It allows you to search for users in Active Directory and then select a user and a group. It then returns a custom object with the user and group.

		Show-SampleGUI illustrates the following concepts:
		* How to create a GUI using PowerShell and WPF
		* How to use a GUI to get input from a user
		* How to use a GUI to display output to a user
		* How to use a GUI to display a list of items
		* How to use a GUI to select an item from a list
		* How to respond to events in a GUI
	.PARAMETER GUIPath
		The path to the XAML file that defines the GUI. The default is '..\WPF\frmMain.xaml'.
	.EXAMPLE
		Show-SampleGUI -Verbose

		Shows the sample GUI.
	.NOTES
		Date              Version      By                   Notes
		----------------------------------------------------------
		18 Nov 2023       1.0          Dallas K. Cecil      Initial Release
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

		$txtName.Text = 'd*'
		$txtName.SelectAll()

		Write-Verbose 'Setting control event handlers'

		<#
			If you want to see all of the events for a control, you can use the following code:

			$myControl = $frmMain.FindName('myControl')
			$myControl | Get-Member -MemberType Event
		#>

		<#
			If there are lots of event handlers, you may want to put them in a separate file.
		#>

		$btnCancel.Add_Click({
				Write-Verbose 'Cancel button clicked'
				$frmMain.DialogResult = $false
				$frmMain.Close()
			})

		$btnOK.Add_Click({
				Write-Verbose 'OK button clicked'
				#### Do something here

				If ($null -eq $lstUsers.SelectedItem) {
					[System.Windows.MessageBox]::Show('Please select a user.', 'Error', 'OK', 'Error')
					$lstUsers.Focus()
					Return
				}

				If ($null -eq $lstGroups.SelectedItem) {
					[System.Windows.MessageBox]::Show('Please select a group.', 'Error', 'OK', 'Error')
					$lstGroups.Focus()
					Return
				}

				$frmMain.DialogResult = $true
				$frmMain.Close()
			})

		$btnSearch.Add_Click({
				Write-Verbose 'Search button clicked'
				#### Do something here

				# Add files in c:\temp to list box; just for testing
				$lstUsers.Items.Clear()
				$lstGroups.Items.Clear()

				$lstUsers.DisplayMemberPath = 'Name'

				$myFilter = "$($txtName.Text)"
				$myItems = Get-ADUser  -Filter { SamAccountName -like $myFilter } -Properties MemberOF | Sort-Object -Property SamAccountName

				ForEach ($myItem in $myItems) {
					$lstUsers.Items.Add($myItem)
				}

				$lstUsers.IsEnabled = $true
			})

		$lstUsers.Add_SelectionChanged({
				Write-Verbose "User list selection changed to $($lstUsers.SelectedItem.ToString())"

				$lstGroups.IsEnabled = $true

				# Get groups for selected user
				$myItems = @()
				$myItems += $lstUsers.SelectedItem | Select-Object -ExpandProperty MemberOf | Sort-Object

				$lstGroups.DisplayMemberPath = 'Name'

				$myItemsTwo = [System.Collections.ArrayList]::new()

				ForEach ($g in $myItems) {
					Write-Verbose "Found group $g"
					$myGroup = Get-ADGroup -Identity $g # This is not the most efficient way to do this, but it is just an example.
					$null = $myItemsTwo.Add($myGroup)
				}

				Write-Verbose "Found $($myItemsTwo.Count) groups for $($lstUsers.SelectedItem.ToString())"

				# Instead of adding items individually, you can add the entire array at once.
				$lstGroups.ItemsSource = $myItemsTwo
			})

		$txtName.Add_KeyUp({
				[Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseDeclaredVarsMoreThanAssignments', '')]
				$Sender = $args[0] # This variable is not used. The above line suppresses the warning in VSCode.
				[System.Windows.Input.KeyEventArgs]$e = $args[1]

				If ($e.Key -eq 'd' -and $e.KeyboardDevice.Modifiers -eq 'Control') {
					Write-Verbose 'This is an easter egg!'

					Write-Verbose 'Loading System.Speech'
					[Reflection.Assembly]::LoadWithPartialName('System.Speech') | Out-Null
					$synth = New-Object System.Speech.Synthesis.SpeechSynthesizer

					$synth.Rate = 0
					$synth.Volume = 100

					$synth.SpeakAsync('This is an Easter egg that Dallas put in to illustrate capturing individual key presses (and speech).') | Out-Null
				}
			})

		$frmMain.add_SourceInitialized({

				# This is an example of how to add a timer to a GUI.
				# You can use this to update the GUI based on the status of run spaces or other long running processes.

				# This is a simple example of how to use a timer to update a label with the current time.

				#create timer object
				$timer = New-Object System.Windows.Threading.DispatcherTimer
				$timer.interval = [timespan]'0:0:1'

				#add event per tick
				$timer.add_tick({

						[int]$RunningTime = (New-TimeSpan -Start $ScriptStartTime -End (Get-Date)).Seconds
						$lblTimer.Content = ("Running for: $($RunningTime.ToString()) seconds" )
					})

				$timer.start()
			})
	}

	Process {

		If ($frmMain.ShowDialog()) {
			# This is where you would do something with the results

			$myOutputUser = [FRBUser]::new(($lstUsers.SelectedItem), ($lstGroups.SelectedItem))

			Write-Output -InputObject $myOutputUser # I don't normally use Write-Output, but it is good to know about it and be more explicit sometimes.

		} Else {
			# Nothing to do here
			Write-Verbose 'Canceled'
		}

	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($myinvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}

}
