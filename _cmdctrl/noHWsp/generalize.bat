mkdir c:\hp
copy unatt.xml C:\hp\unatt.xml
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
echo Are you sure?
echo Pressing any key will initiate Windows Hardware Installation process during next boot!
echo System shutdown will be initiated once setup completed.
echo !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
pause

C:\Windows\System32\Sysprep\sysprep.exe /oobe /shutdown /generalize /unattend:C:\hp\unatt.xml

