strPath = Wscript.ScriptFullName
strFileName =  Left(strPath, Len(strPath) - 5) & "2.bat"
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & strFileName & Chr(34), 0
Set WinScriptHost = Nothing
