# General Notes

This file contains general notes, in no particular order.

## Event Args

Q: In a WPF PowerShell function, events, such as click, happen. How do you access the _sender_ and _eventargs_ passed in to most events?

A: Those parameters are passed in as unnamed arguments. Consider the following C# code:

```CSharp
private void Handler(object sender, SomeEventArgs e)
{
  //do something with sender and/or e...
}
```

and the equivalent PowerShell code:

```PowerShell
$WPFControl.Add_Handler({
  $sender = $args[0]
  $e      = $args[1]
  #do something with sender and/or e...
})
```

Use the debugger on ISE (or command line, if you wish) and ```Get-Type()``` or ```Get-Member``` to get the specific types so they can be strongly typed:

```PowerShell
$ScrollViewer.Add_PreviewMouseWheel({
  Write-Host $args[0] # Should be [System.Windows.Controls.ScrollViewer]$args[0]
  Write-Host $args[1] Should be [System.Windows.Input.MouseWheelEventArgs]$args[1]
})
```

## Cool PowerShell Modules

Q: What are some cool / useful PowerShell modules?

A: I do not use many external PowerShell modules, other than Azure, AWS, and other vendor-specific modules. However, I do think Profiler is really cool (and useful).

Find a discussion on the PowerShell profiler [https://blog.danskingdom.com/Easily-profile-your-PowerShell-code-with-the-Profiler-module/](https://blog.danskingdom.com/Easily-profile-your-PowerShell-code-with-the-Profiler-module/)

And the actual GitHub repo at [https://github.com/nohwnd/Profiler](https://github.com/nohwnd/Profiler)
