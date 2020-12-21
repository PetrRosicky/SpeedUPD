rem for /F %%i in (_list.txt) do del \\%%i\c$\windows\memory.dmp

for /F %%i in (_list.txt) do mkdir \\%%i\c$\cpqsystem\\hpehw\DPs\G9

for /F %%i in (_list.txt) do xcopy .\sus.ps1 \\%%i\c$\cpqsystem\\hpehw\DPs /Y

for /F %%i in (_list.txt) do xcopy .\G9\* \\%%i\c$\cpqsystem\\hpehw\DPs\G9 /E /I
for /F %%i in (_list.txt) do xcopy .\cmdctrl\* \\%%i\c$\cpqsystem\\hpehw\DPs\cmdctrl /E /I


@pause
 
