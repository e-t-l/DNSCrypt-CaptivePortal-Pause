strPath = Wscript.ScriptFullName
strFileName =  Left(strPath, Len(strPath) - 3) & "bat"
Set WinScriptHost = CreateObject("WScript.Shell")
WinScriptHost.Run Chr(34) & strFileName & Chr(34), 0
Set WinScriptHost = Nothing
