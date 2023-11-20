Function Get-ADComputerSite {
	<#
	.SYNOPSIS
		Gets the site an Active Directory computer object is in.
	.DESCRIPTION
		Returns the Active Directory site of a computer.

	.PARAMETER ComputerName
		The name of the computer(s)

	.EXAMPLE
		Get-ADComputerSite -ComputerName TestComputerA

		Returns the Active Directory site of TestComputerA

	.NOTES

		Change Log:
		Date              Version      By                  Notes
		--------------------------------------------------------
		16 Mar 2018       1.0          Dallas K. Cecil     Initial release
		17 Aug 2018       1.0.1        Dallas K. Cecil     Updated parameter(s) to allow values from the pipeline.

#>
	[cmdletbinding(SupportsShouldProcess = $false)]
	Param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)][string[]]$ComputerName = $env:COMPUTERNAME
	)

	Begin {
		$ScriptStartTime = Get-Date; Write-Verbose -Message "$($ScriptStartTime) Starting $($MyInvocation.MyCommand)"

		If ($ComputerName -eq '.') {
			Write-Verbose "ComputerName contains a . (dot); substituting $($env:COMPUTERNAME)"
			$ComputerName[[array]::IndexOf($ComputerName, '.')] = $env:computername
		}


		# Following code is for reference only
		[Diagnostics.CodeAnalysis.SuppressMessageAttribute('UseDeclaredVarsMoreThanAssignments', '')]
		$CSharpCode = @'

using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public static class NetApi32 {

	private class unmanaged {

		[DllImport("NetApi32.dll", CharSet=CharSet.Auto, SetLastError=true)]
		internal static extern UInt32 DsGetSiteName([MarshalAs(UnmanagedType.LPTStr)]string ComputerName, out IntPtr SiteNameBuffer);

		[DllImport("Netapi32.dll", SetLastError=true)]
		internal static extern int NetApiBufferFree(IntPtr Buffer);
	}

	public static string DsGetSiteName(string ComputerName) {

		IntPtr siteNameBuffer = IntPtr.Zero;

		UInt32 hResult = unmanaged.DsGetSiteName(ComputerName, out siteNameBuffer);

		string siteName = Marshal.PtrToStringAuto(siteNameBuffer);

		unmanaged.NetApiBufferFree(siteNameBuffer);

		if(hResult == 0x6ba) {
			throw new Exception("ComputerName not found");
			}

		return siteName;
	}
}

'@

		# Visual Basic Code
		$code = @"
Imports System
Imports System.Collections.Generic
Imports System.Runtime.InteropServices

Public Module NetApi32

	Private Class Unmanaged

		<DllImport("NetApi32.dll", CharSet:=CharSet.Auto, SetLastError:=True)>
		Friend Shared Function DsGetSiteName(<MarshalAs(UnmanagedType.LPTStr)> ByVal ComputerName As String, ByRef SiteNameBuffer As IntPtr) As UInt32
		End Function

		<DllImport("Netapi32.dll", SetLastError:=True)>
		Friend Shared Function NetApiBufferFree(ByVal Buffer As IntPtr) As Integer
		End Function
	End Class

	Public Function DsGetSiteName(ByVal ComputerName As String) As String

		Dim siteNameBuffer As IntPtr = IntPtr.Zero

		Dim hResult As UInt32 = Unmanaged.DsGetSiteName(ComputerName, siteNameBuffer)

		Dim siteName As String = Marshal.PtrToStringAuto(siteNameBuffer)

		Unmanaged.NetApiBufferFree(siteNameBuffer)

		If hResult = &H6ba Then  ' $H6ba = 1722
			Throw New Exception("ComputerName not found")
		End If

		Return siteName
	End Function
End Module

"@

		If ($null -eq ([System.Management.Automation.PSTypeName]'NetApi32').Type) {
			Write-Verbose 'NetApi32 not loaded; getting ready to load it.'
			Add-Type -TypeDefinition $code -Language VisualBasic
		} Else {
			Write-Verbose 'NetApi32 is already loaded; no need to load it again.'
		}
	}

	Process {

		ForEach ($c in $ComputerName) {

			If ($c.ToUpper() -eq 'localhost'.ToUpper()) {
				$c = $env:COMPUTERNAME
			}

			Write-Verbose "Working on $($c)"
			$myOutput = [pscustomObject] @{
				PSTypeName   = 'dkc.ADComputerSite'
				ComputerName = $C
				SiteName     = [NetApi32]::DsGetSiteName($c)
			}

			$myOutput
		}
	}

	End {
		Write-Verbose -Message "$(Get-Date) Ending $($MyInvocation.MyCommand); it took $(((Get-Date) - $ScriptStartTime).TotalMilliseconds) milliseconds."
	}
}
