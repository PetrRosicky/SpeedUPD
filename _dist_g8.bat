rem for /F %%i in (_list.txt) do del \\%%i\c$\windows\memory.dmp

for /F %%i in (_list.txt) do mkdir \\%%i\c$\cpqsystem\\hpehw\DPs\common
for /F %%i in (_list.txt) do mkdir \\%%i\c$\cpqsystem\\hpehw\DPs\G8

for /F %%i in (_list.txt) do xcopy .\sus.ps1 \\%%i\c$\cpqsystem\\hpehw\DPs /Y

for /F %%i in (_list.txt) do xcopy .\common\* \\%%i\c$\cpqsystem\\hpehw\DPs\common /E /I
for /F %%i in (_list.txt) do xcopy .\G8\* \\%%i\c$\cpqsystem\\hpehw\DPs\G8 /E /I


@pause
 
