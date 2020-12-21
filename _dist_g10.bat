for /F %%i in (_list.txt) do del \\%%i\c$\windows\memory.dmp

for /F %%i in (_list.txt) do mkdir \\%%i\c$\cpqsystem\\hpehw\DPs\G10

rem for /F %%i in (_list.txt) do xcopy .\sus.ps1 \\%%i\c$\cpqsystem\\hpehw\DPs /Y
for /F %%i in (_list.txt) do xcopy .\_gox.bat \\%%i\c$\cpqsystem\\hpehw\DPs /Y

rem for /F %%i in (_list.txt) do xcopy .\G10\* \\%%i\c$\cpqsystem\\hpehw\DPs\G10 /E /I
for /F %%i in (_list.txt) do xcopy .\G10\cp042810.* \\%%i\c$\cpqsystem\\hpehw\DPs\G10 /E /I




@pause
 
