mkdir c:\hp
copy unatt.xml C:\hp\unatt.xml
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo Are you sure?
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pause

C:\Windows\System32\Sysprep\sysprep.exe /oobe /shutdown /generalize /unattend:C:\hp\unatt.xml


