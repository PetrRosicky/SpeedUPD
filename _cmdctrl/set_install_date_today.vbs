' Script sets Windows installation date to the time when its executed

On Error Resume Next
Const HKEY_LOCAL_MACHINE = &H80000002
Set output = WScript.StdOut
Set wshShell = WScript.CreateObject("WScript.Shell")
Set objArgs = WScript.Arguments
strArg = "."

DriftShift = 28800

' -------------------------------------------------------------------------------------------------
Function ConvertUnixTimeStampToDateTime(input_unix_timestamp) 'As String [regular datetime]
    ConvertUnixTimeStampToDateTime = CStr(DateAdd("s", input_unix_timestamp, "01/01/1970 00:00:00"))
End Function
' -------------------------------------------------------------------------------------------------
Set objReg = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & strArg & "\root\default:StdRegProv")
objReg.GetDWORDValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallDate", OSRegInstallDate
OSRegInstallDate = OSRegInstallDate - DriftShift
UnixTimeNow = DateDiff("S", "1/1/1970", Now()) 

OSRegInstallDateWMI = ConvertUnixTimeStampToDateTime(OSRegInstallDate)
UnixTimeNowWMI = ConvertUnixTimeStampToDateTime(UnixTimeNow)

XPrompt = "OS installation date is " & OSRegInstallDateWMI & vbCrLf & "and it will be set to " & UnixTimeNowWMI & vbCrLf
Mresult = MsgBox (XPrompt, vbYesNo, "Set installation date to NOW?")

Select Case Mresult
Case vbYes
	UnixTimeNow = UnixTimeNow + DriftShift
	objReg.SetDWORDValue HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVersion", "InstallDate", UnixTimeNow
    	MsgBox("Installation date set to NOW.")
Case Else
    	MsgBox("Aborted, date not set.")
End Select

