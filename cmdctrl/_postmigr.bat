del C:\smh_installer.log
del "C:\Users\Public\Desktop\HPE System Management Homepage.lnk"

set devmgr_show_nonpresent_devices=1
start devmgmt.msc


rem netsh interface ip reset "c:\ipreslog.txt"