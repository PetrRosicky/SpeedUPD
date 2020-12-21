net use W: \\xelpg-s-cms0001.ltd.com\dlpri
robocopy W:\DPs C:\cpqsystem\hpehw\DPs /Z /IPG:1

@echo.
@net statistics server |findstr since
@pause
