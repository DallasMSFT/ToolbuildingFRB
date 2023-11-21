# Dot source all classes in all ps1 files located in the module Classes folder; classes should be first
$AllScripts = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Classes\*.ps1') -Exclude *.tests.ps1 -Recurse -ErrorAction SilentlyContinue

$AllScripts | ForEach-Object {
	Write-Verbose "Processing $($_.FullName)"
	. $_.FullName
}

# Dot source all functions in all ps1 files located in the module Functions folder
$AllScripts = Get-ChildItem -Path (Join-Path -Path $PSScriptRoot -ChildPath 'Functions\*.ps1') -Exclude *.tests.ps1 -Recurse -ErrorAction SilentlyContinue

$AllScripts | ForEach-Object {
	Write-Verbose "Processing $($_.FullName)"
	. $_.FullName
}
