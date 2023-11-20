# WorkshopPLUS – Windows PowerShell: Tool Building for FRB

This GitHub repository contains sample code and code we developed during the class. Note that this is just example code and should not be used in any production environment. Instead, it should be used to illustrate the topics we discussed in class.

There are several different directories included in this repository; all are described in detail in their own section:

* GeneralNotes
* GeneralFunctions
* Snippet
* Samples
* FirstModule

## General Notes

Contains a single file, GeneralNotes.md, that has, well, general notes in it.

## GeneralFunctions

GeneralFunctions contains, well, general functions that illustrate one or more topics.

Notice how all the functions have comment-based help and use ```Write-Verbose``` (mostly) for comments. I really do practice what I preach.

* ```Enter-Sleep```: Puts the computer to sleep. Demonstrates calling the Windows API

* ```Get-ADComputerSite```: Gets the site an Active Directory computer object is in. Demonstrates writing C# / Visual Basic.Net code within a PowerShell function.

* ```Get-HostsFileEntry```: Gets hosts file entries. Demonstrates a more complex regular expression. This function has been very useful to me.

* ```Lock-Workstation```: Locks the workstation. Another demonstration of calling the Windows API. It also demonstrates one way to tell if the function is running in a remote session.

* ```New-Shortcut```: Creates a new shortcut. This may be useful to the application engineers in the class. It uses some old-school techniques (the Windows Script Host) to create a shortcut. It can also set the shortcut to _Run As Administrator_; it does this in a completely unsupported way but does illustrate reading and writing binary files.

* ```Set-HistoryToClipboard```: Copies history to the clipboard. One of, if not the first, function I wrote for myself. Not that interesting but very useful. Note how a a function alias is defined from _within_ the function.

* ```Show-WaitBar```: Displays a 'Knight Rider' type progress bar for operations with an unknown end time. Demonstrates several advanced topics, including runspaces (two different ways) and passing script blocks as parameters.

* ```Start-SleepWithProgress```: Sleeps while showing a progress bar. Demonstrates multiple parameter sets. I use this all the time.

## Snippet

Contains a json file with the Visual Studio Code format for a PowerShell function template using Dallas' best practices.

You can add this snippet to Visual Studio Code. Open the command pallet (Ctrl+Shift+P or F1) and search for snippet.

## Samples

Contains samples purpose-build for this class. They may be full functions or code fragments.

* ```Test-ArgumentCompleter```: Example of using Argument Completers.

* ```Test-Dynamic Parameter```: Example of using Dynamic Parameters.

## FirstModule

FirstModule shows how Dallas believes (most) modules should be set up. This module contains code (nearly) identical to the code we developed in class with some additional functionality. This code is not as polished as I typically write (less error handling, etc.) for clarity and brevity.
