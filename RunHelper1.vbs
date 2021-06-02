Dim objFSO
Set objFSO = CreateObject("Scripting.FileSystemObject")
Dim CurrentDirectory
CurrentDirectory = objFSO.GetAbsolutePathName(".")
strFileName = CurrentDirectory & "\RunHelper2.bat"

Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & strFileName & Chr(34), 0
Set WinScriptHost = Nothing
