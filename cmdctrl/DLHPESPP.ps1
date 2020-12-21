<#
- downloads selected SPP
#>

If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  Write-Host "Mount-ISO must run as Admin - child process launched" -ForegroundColor Yellow
  Start-Sleep -Seconds 10
  exit
}
# Now running elevated 

$host.ui.RawUI.WindowTitle = "HEP SPP Download"
Write-Host "----------------------------------------------------------------------" "`r" -ForegroundColor Black -BackgroundColor Cyan
Write-Host "IBM CZ / CIC Brno HPE HW Team SW Property - Company Internal Use Only " "`r" -ForegroundColor Black -BackgroundColor Cyan
Write-Host "----------------------------------------------------------------------" "`r" -ForegroundColor Black -BackgroundColor Cyan
Write-Host "2: 201811_G9R" -ForegroundColor Gray
Write-Host "C: 201811_G9" -ForegroundColor Gray
Write-Host "3: 201909_G9R" -ForegroundColor Gray
Write-Host "D: 201909_G9" -ForegroundColor Gray
Write-Host "4: 201912_G8" -ForegroundColor Gray
Write-Host "5: 201912_G9" -ForegroundColor Gray
Write-Host "6: 201912_G10" -ForegroundColor Gray
Write-Host "X: eXit" -ForegroundColor Gray
Write-Host "---------------------------------------------------------------------"
$ActionCap = "Select:"
$Act2 = new-Object System.Management.Automation.Host.ChoiceDescription "&2_201811_G9Rv1","201811_G9v1R";
$ActC = new-Object System.Management.Automation.Host.ChoiceDescription "&C_201811_G9","201811_G9";
$Act3 = new-Object System.Management.Automation.Host.ChoiceDescription "&3_201909_G9R","201909_G9R";
$ActD = new-Object System.Management.Automation.Host.ChoiceDescription "&D_201909_G9","201909_G9";
$ActX = new-Object System.Management.Automation.Host.ChoiceDescription "&4_201912_G8","201912_G8";
$ActY = new-Object System.Management.Automation.Host.ChoiceDescription "&5_201912_G9","201912_G9";
$ActZ = new-Object System.Management.Automation.Host.ChoiceDescription "&6_201912_G10","201912_G10";
$ActEx = new-Object System.Management.Automation.Host.ChoiceDescription "E&xit","Exit";
$ActChoices = [System.Management.Automation.Host.ChoiceDescription[]]($Act2,$ActC,$Act3,$ActD,$ActX,$ActY,$ActZ,$ActEx);
$ActAnswer = $host.ui.PromptForChoice($ActionCap,$ActionMsg,$ActChoices,-1)
switch ($ActAnswer) {
    0 {$ActType = '201811\sut201811_G9Rv1'}
    1 {$ActType = '201811\sut201811_G9'}
    2 {$ActType = '201909\sut201909_G9R'}
    3 {$ActType = '201909\sut201909_G9'}
    4 {$ActType = '201912\sut201912_G8'}
    5 {$ActType = '201912\sut201912_G9'}
    6 {$ActType = '201912\sut201912_G10'}
    default { Exit } 
}
Write-Host "---------------------------------------------------------------------"
$ImaPath = "\\xelpg-s-cms0001.xe.abb.com\spp\" + $ActType + ".iso"
Write-Host "Selected $ActType, mounting image $ImaPath" -ForegroundColor Green
Mount-DiskImage -ImagePath $ImaPath 

Write-Host "Searching for source disk letter ..." -ForegroundColor Green
$MyVols = Get-Volume
Foreach ($ThisVol in $MyVols) {
    If (($ThisVol.DriveType -eq "CD-ROM") -AND ($ThisVol.FileSystemLabel.Length -gt 1)) {
        $Path2Chk = $ThisVol.DriveLetter + ":\launch_sum.bat"
        If (Test-Path -Path $Path2Chk) {
            Write-Host $ThisVol.DriveLetter $ThisVol.FileSystemLabel "*" -ForegroundColor Yellow
            $MySrcFnd = $ThisVol.DriveLetter
        } else {
            Write-Host $ThisVol.DriveLetter $ThisVol.FileSystemLabel -ForegroundColor Gray
        }
    }
     

} 

If ($MySrcFnd.Length -gt 0) {
    $YConfirm = Read-Host "Press Y to start fast copy from $MySrcFnd , s for slow copy"
    If (($YConfirm.ToUpper() -eq "Y") -OR ($YConfirm.ToUpper() -eq "S")) {
        $MyRCmd = "robocopy " + $MySrcFnd + ":\ C:\cpqsystem\hpehw\" + $ActType + " *.compsig *.bat *.htm* /E /Z /MT:8"
        iex $MyRCmd
        If ($YConfirm.ToUpper() -eq "S") {
            $MyRCmd = "robocopy " + $MySrcFnd + ":\ C:\cpqsystem\hpehw\" + $ActType + " *.* /E /Z /IPG:4"
            iex $MyRCmd
        } else {
            $MyRCmd = "robocopy " + $MySrcFnd + ":\ C:\cpqsystem\hpehw\" + $ActType + " *.* /E /Z /MT:8"
            iex $MyRCmd
        }
        Write-Host "Completed" -ForegroundColor Green
        Dismount-DiskImage -ImagePath $ImaPath
        $YConfirm = Read-Host "Press Enter to exit "
    } else {
        Write-Host "Sorry, cancelled" -ForegroundColor Red
        Dismount-DiskImage -ImagePath $ImaPath
    }
} else {
    Write-Host "Sorry, no copy source found" -ForegroundColor Red
}
