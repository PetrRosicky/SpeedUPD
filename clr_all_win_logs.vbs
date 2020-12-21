' Script clears Windows evet logs

On Error Resume Next
Set output = WScript.StdOut
Set wshShell = WScript.CreateObject("WScript.Shell")

strComputer = "."
XPromptList = ""
Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate, (Backup)}!\\" & strComputer & "\root\cimv2")
Set colLogFiles = objWMIService.ExecQuery ("Select * from Win32_NTEventLogFile")
For each objLogfile in colLogFiles
	XPromptList = XPromptList & " " & objLogFile.FileName
Next

XPrompt = "Following logs will be cleared: " & XPromptList & vbCrLf 
Mresult = MsgBox (XPrompt, vbYesNo, "OK to proceed?")
Select Case Mresult
Case vbYes
	For each objLogfile in colLogFiles
		objLogFile.ClearEventLog()
	Next
    	MsgBox("Event logs cleared.")
Case Else
    	MsgBox("Aborted, nothing changed.")
End Select
