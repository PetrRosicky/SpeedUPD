# Set-ExecutionPolicy Unrestricted
<#
20-04-24 201912 Firmware: cp039561 replaced by cp043370 / driver same / firmware HPE Smart Array P408i-p, P408e-p, P408i-a, P408i-c, E208i-p, E208e-p, E208i-c, E208i-a, P408i-sb, P408e-m, P204i-c, P204i-b, P816i-a and P416ie-m SR Gen10
20-04-24 201912 Firmware SN1100Q:  2019.12.01/01.73.07 (cp039710 -> hotfixed cp043694-1.73.08) 
20-04-24 201912 Driver SN1100Q 2K12R2 -cp039716 ?
20-04-24 201912 Driver SN1100Q 2K16 same

20-05-02 Unconditional HPE SUT 1.6.5 removal (201704, cp029625)
 
#>

# -----------------------------------------------------------
function Log-HPSUMET([string]$argET) {
    $XXThisCPPath = "eventcreate"
    $XXThisCPArgs = "/T INFORMATION /ID 2 /L SYSTEM /SO HPSUMET /D " + $([char]0x0022) + $argET + $([char]0x0022)
    Write-Host Logging event: $argET
    $XXCPprocess = (Start-Process -Verb runAs -FilePath $XXThisCPPath -ArgumentList $XXThisCPArgs -PassThru -Wait)
}
function FldrPreSet([string]$argXX) {  
  If ($argXX.Length -gt 2) {  
    If (!(Test-Path $argXX)) {
        New-Item -Path $argXX -ItemType "directory" | Out-Null
        Write-Host "..." $argXX "created" "`r"            
    }
    If (!((get-item $argXX -force).Attributes -match 'Hidden')) { 
        $frfldr=get-item $argXX -Force
        $frfldr.attributes="Hidden"       
        Write-Host "... Setting root hidden" "`r" 
    }
    $FSutSDFldr = $argXX + "\hpehw"
    If (!(Test-Path $FSutSDFldr)) {
        New-Item -Path $FSutSDFldr -ItemType "directory" | Out-Null
        Write-Host "..." $FSutSDFldr "created" "`r" 
    }
    $FSutSDFldr = $argXX + "\SUTstage"
    If (!(Test-Path $FSutSDFldr)) {
        New-Item -Path $FSutSDFldr -ItemType "directory" | Out-Null
        Write-Host "..." $FSutSDFldr "created" "`r" 
        $FThisCPPath = "C:\Windows\system32\compact.exe"
        $FThisCPArgs = "/c " + $FSutSDFldr
        $CPprocess = (Start-Process -Verb runAs -FilePath $FThisCPPath -ArgumentList $FThisCPArgs -PassThru -Wait)
        $FThisCPArgs = "/c /s /i " + $argXX + "\*.log"
        $CPprocess = (Start-Process -Verb runAs -FilePath $FThisCPPath -ArgumentList $FThisCPArgs -PassThru -Wait)
    }
  }
  foreach ($numX in "G7","G8","G9","G10") {
    $PargXX = ".\"+$numX
    If (!(Test-Path $PargXX)) { New-Item -Path $PargXX -ItemType "directory" | Out-Null }
  }
}
function GetMisFile([string]$argXX, [string]$argFile) { 
    $DstPath1 = ".\"+$argXX+"\"+$argFile
    If (!(Test-Path $DstPath1)) {
        $SrcPath1 = "\\xelpg-s-cms0001.xe.abb.com\dlpri\DPs\"+$argXX+"\"+$argFile
        Write-Host "Downloading " $argFile "... `r" -ForegroundColor DarkGray
        Copy-Item $SrcPath1 -Destination $DstPath1
    }
}
function FFileDirIfEmptyRemove([string]$argXX, [string]$argFile) { 
    If (Test-Path $argXX) {
      $LThisPathF = $argXX+"\"+$argFile
      If (Test-Path $LThisPathF) { Remove-Item $LThisPathF }
      $LdirXInfo = Get-ChildItem $argXX | Measure-Object
      If ($LdirXInfo.count -eq 0) { Remove-Item $argXX }
    }
}
function FEmptyDirRemove([string]$argXX) { 
    If (Test-Path $argXX) {
        $LdirXInfo = Get-ChildItem $argXX | Measure-Object
        If ($LdirXInfo.count -eq 0) { Remove-Item $argXX }
    }
}
function FDirInclContRemove([string]$argXX) { 
    If (Test-Path $argXX) {
        $LdirXInfo = Get-ChildItem $argXX | Measure-Object
        If ($LdirXInfo.count -eq 0) { 
            Remove-Item $argXX -Recurse
        } else {
            get-childitem -Path $argXX -File | foreach ($_) { remove-item $_.fullname -Force }  
            Remove-Item $argXX -Recurse
        }
    }
}
############################################################################## Pre-set Data 
$SPPNamesArr  = @( "201704", "201811", "201909", "201912" )
$SPPLevels = $SPPNamesArr.Count
# common versions matching to SPP
$SUTCodesArr3D  = @( # [$HPEGen789Idx][MSI/ver/CP][$TargetSPPLevel/*walk*]
    ( #G7
            ("", "", "", ""),     
            ("", "", "", ""),
            ("", "", "", "")
    ),( #G8
            ("{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "","" ),     
            ("2.0.1.0 (2017-12-22)", "2.0.1.0 (2017-12-22)", "", ""),  # 2.0.1.0 last for G8
            ("cp032917", "cp032917", "", "")          
    ),( #G9
            ("{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "{E5B97A07-A123-45DB-88B4-C7EDC49570DE}", "{8A790297-CC80-4874-B537-A89DC7683ABF}", "{72345FA8-99AE-4A69-8576-B86ECBC3DFC2}" ),     
            ("2.0.1.0 (2017-12-22)", "2.3.6.0 (201811)", "2.4.5.0 (201909)", "2.5.0.0 (201912)"),
            ("cp032917", "cp036670", "cp039132", "cp038225")
    ),( #G10
            ("", "{E5B97A07-A123-45DB-88B4-C7EDC49570DE}", "{8A790297-CC80-4874-B537-A89DC7683ABF}", "{72345FA8-99AE-4A69-8576-B86ECBC3DFC2}" ),     
            ("", "2.3.6.0 (201811)", "2.4.5.0 (201909)", "2.5.0.0 (201912)"),
            ("", "cp036670", "cp039132", "cp038225")            
    )
)
$SUTCodesArr2012 = @( # [$HPEGen789Idx][MSI/ver/CP][$TargetSPPLevel/*walk*]
    ( #G7
            ("", "", "", ""),     
            ("", "", "", ""),
            ("", "", "", "")
    ),( #G8
            ("{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "","" ),     
            ("2.0.1.0 (2017-12-22)", "2.0.1.0 (2017-12-22)", "", ""), # 2.0.1.0 last for G8
            ("cp032917", "cp032917", "", "")            
    ),( #G9
            ("{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "{E5B97A07-A123-45DB-88B4-C7EDC49570DE}", "{8A790297-CC80-4874-B537-A89DC7683ABF}","" ),     
            ("2.0.1.0 (2017-12-22)", "2.3.6.0 (201811)", "2.4.5.0 (201909)",""), # 2.4.5.0 (201909) last for 2012
            ("cp032917", "cp036670", "cp039132","")
    ),( #G10
            ("", "", "", ""),     
            ("", "", "", ""),
            ("", "", "", "")          
    )
)
$SUTCodesArr2008R2 = @( # [$HPEGen789Idx][MSI/ver/CP][$TargetSPPLevel/*walk*]
    ( #G7
            ("", "", "", ""),     
            ("", "", "", ""),
            ("", "", "", "")
    ),( #G8
            ("{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "","" ),     
            ("2.0.1.0 (2017-12-22)", "2.0.1.0 (2017-12-22)", "", ""), # 2.0.1.0 last for G8
            ("cp032917", "cp032917", "", "")            
    ),( #G9
            ("{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "{62640CD2-1C49-4510-B25C-B0D0C97F8DEF}", "","" ),     
            ("2.0.1.0 (2017-12-22)", "2.0.1.0 (2017-12-22)", "",""), # 2.2.1.0 (2018-05-03) last for 2008R2, also 2.4.5.0 (201909) marked as 2008R2 - but both not AMS-reported, so not impl.
            ("cp032917", "cp032917", "","")
    ),( #G10
            ("", "", "", ""),     
            ("", "", "", ""),
            ("", "", "", "")          
    )
)
# 2.1.0.0 supports 2008R2, but not Gen8 (cp031299)
$SUTCodesArrOSRef  = @( [ref] $SUTCodesArr2008R2, [ref] $SUTCodesArr2012, [ref] $SUTCodesArr3D, [ref] $SUTCodesArr3D)
########------------------------------------------------------------------########
########  W2008R2 / Must fully support SPP201704 level (G8->G9)
$I31W2008R2 = @(         
            ("cp029394","cp029429","cp030019",  "cp029425", "cp029408", "cp030039", "cp029652", "cp029661", "cp029671", "" ), #1704 EOS, Verified on 554 and 630
            ("cp029394","cp029429","cp030019",  "cp029425", "cp029408", "cp030039", "cp029652", "cp029661", "cp029671", ""),  #1811 +SUT, verified on 554 and 630
            ("", ""), 
            ("", "")
            )
$I31W2008R2Dev = @(
            ("_3Par","_3Par",         "xEX554FLB","xEX554FLB","xEX554FLB","xEX554FLB", "xQL630FLB", "xQL630FLB","xQL630FLB"),
            ("cp027948","HPE3PI17.msi","cp029983","cp032105","cp028184","cp031846",     "cp030253", "cp028184","cp028020"),
            ("cp027948","HPE3PI17.msi","cp029983","cp032105","cp028184","cp031846",     "cp030253", "cp028184","cp028020"),
            ("", ""),
            ("","")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 (cp029394) / dtto
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) / dtto
# HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) / dtto
# Headless Server Registry Update for Windows Server 2008 to Server 2012 R2 cp029425 /dtto
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2  cp029408 /dtto
# HPE ProLiant Agentless Management Service for Windows X64 10.60.0.0 (cp030039) /dtto
# Combined Chipset Identifier for Windows Server 2008 R2  8.2.0.0 (cp029652) /dtto
# HP ProLiant PCI-express Power Management Update for Windows (cp029661) /missing
# Matrox G200eH Video Controller Driver for Windows Server 2008 X64 cp029671  /dtto
# Dev: 3Par
# HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems cp027948 /dtto
# Dev: EX554FLB
# HPE Storage Fibre Channel Over Ethernet Adapter Kit for the x64 Emulex Storport Driver (cp029983) 11.1.145.16 /dtto
# HPE Emulex 10/20 GbE Driver for Windows Server 2008 R2 - 11.1.145.30(B)(21 Apr 2017) cp032105 11.1.145.30 /dtto
# HPE Network Configuration Utility for Windows Server 2008 R2 cp028184 11.50.0.0 /dtto
# HPE Firmware Flash for Emulex Converged Network Adapters - Windows (x64) 2016.10.05 (cp031846) /dtto 
# Dev: QL630FLB
# HPE QLogic NX2 10/20GbE Multifunction Drivers for Windows Server x64 Editions 7.13.104.0 (cp030253) + NCU /dtto
# HPE QLogic NX2 Online Firmware Upgrade Utility for Windows Server x64 Editions (cp028020) /dtto
# N/A 
#  Online ROM Flash for Windows - Power Management Controller (HP ProLiant Gen8 Servers) 3.3 (cp021612) /dtto

$I36W2008R2 = @(         
            ("cp029394","cp029429","cp030019", "cp029408", "cp030039", "cp030228", "cp029661", "cp029671", "cp029656", "cp029659", ""), #1704 Verified
            ("", ""),
            ("", ""),
            ("", "")
            )
$I36W2008R2Dev = @(
             ("_3Par","_3Par",         "xEX554FLB","xEX554FLB","xEX554FLB","xEX554FLB","xQL630FLB", "xQL630FLB", "xQL630FLB" ),
            ("cp027948","HPE3PI17.msi","cp029983","cp032105","cp028184","cp031846",    "cp030253","cp028184","cp028020" ),
            ("" ),  
            ("" ),  
            ("" )
            )
#  iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 (cp029394) / 1610
#  iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) / 1610
#  HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) / 1610
#  PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2  cp029408
#  HPE ProLiant Agentless Management Service for Windows X64 cp030039
#  HPE ProLiant Gen9 Chipset Identifier for Windows (cp030228)  10.1.2.77 
#  HP ProLiant PCI-express Power Management Update for Windows (cp029661)
#  Matrox G200eH Video Controller Driver for Windows Server 2008 X64 cp029671 
#  Intel C220 and C610 Series Platform Controller Hub NMI Fix for Windows Server 2008 R2 1.1.0.0 (cp029656) 
#  Intel USB 3.0 Drivers for Windows Server 2008 R2 (cp029659) 
# 3Par: HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems cp027948
# Dev: EX554FLB
#  HPE Storage Fibre Channel Over Ethernet Adapter Kit for the x64 Emulex Storport Driver 11.1.145.16 (cp029983) 
#  HPE Emulex 10/20 GbE Driver for Windows Server 2008 R2 11.1.145.30 (cp032105) 
#  HPE Network Configuration Utility for Windows Server 2008 R2 11.50.0.0 (cp028184) 
#  HPE Firmware Flash for Emulex Converged Network Adapters - Windows (x64) 2016.10.05 (cp031846)
# Dev: QL630FLB
#  HPE QLogic NX2 10/20GbE Multifunction Drivers for Windows Server x64 Editions (cp030253) + NCU + FW
#N/I  Online ROM Flash for Windows x64 - Advanced Power Capping Microcontroller Firmware for HPE Gen9 Servers 1.0.9 (cp029898) 

$P89W2008R2 = @(         
            ("cp029394","cp029429","cp030019", "cp027948", "cp029408", "cp030039", "cp030228", "cp029661", "cp029671", "cp029656", "cp029659","HPE3PI17.msi", ""), #1704 Verified
            ("cp029394","cp029429","cp030019", "cp027948", "cp029408", "cp030039", "cp030228", "cp029661", "cp029671", "cp029656", "cp029659","HPE3PI17.msi", ""), #copy of 201704 - 2K8 R2 EOS
            ("cp029394","cp029429","cp030019", "cp027948", "cp029408", "cp030039", "cp030228", "cp029661", "cp029671", "cp029656", "cp029659","HPE3PI17.msi", ""), #copy of 201704 - 2K8 R2 EOS
            ("", "") 
            )
$P89W2008R2Dev = @( 
             ("xQLOGCFCA","xQLOGCFCA","xP440AR", "xP440AR", "xP440AR", "x560SFP", "x560SFP", "x331i", "x331i"),
            ("cp031888","cp030243","cp030674", "cp030137", "cp031007", "cp029058", "cp028184", "cp030252", "cp028184"),
            ("cp031888","cp030243","cp032803", "cp030137", "cp031007", "cp029058", "cp028184", "cp030252", "cp028184"),  #SARC drv 6.20.0.64 cp032803
            ("cp031888","cp030243","cp032803", "cp030137", "cp031007", "cp029058", "cp028184", "cp030252", "cp028184"),  #SARC drv 6.20.0.64 cp032803
            ("","") 
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 (cp029394) / 1610
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) / 1610
# HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) / 1610
# HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems cp027948
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2  cp029408
# HPE ProLiant Agentless Management Service for Windows X64 cp030039
# HPE ProLiant Gen9 Chipset Identifier for Windows (cp030228)  10.1.2.77 
# HP ProLiant PCI-express Power Management Update for Windows (cp029661)
# Matrox G200eH Video Controller Driver for Windows Server 2008 X64 cp029671 
# Intel C220 and C610 Series Platform Controller Hub NMI Fix for Windows Server 2008 R2 1.1.0.0 (cp029656) 
# Intel USB 3.0 Drivers for Windows Server 2008 R2 (cp029659) 
# Dev: QLOGCFCA
# HPE HPE Storage Fibre Channel Adapter Kit for the x64 QLogic Storport Driver 9.1.17.25 (cp031888) 
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1 (cp030243)
# Dev: P440AR
# HPE ProLiant Smart Array HPCISSS3 Controller Driver for Windows Server 2008 x64 Edition  6.12.0.64 (cp030674)
# HP ProLiant Smart Array SAS/SATA Event Notification Service for for 64-bit Windows Server Editions 6.46.0.64 (cp030137) 
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 2.65.7.0  (cp031007) 
# Dev: 560SFP
# HPE Intel ixn/ixt Drivers for Windows Server 2008 R2 3.9.58.9101  (cp029058) 
# HPE Network Configuration Utility for Windows Server 2008 R2 11.50.0.0 (cp028184)
# Dev: 331i
# HPE Broadcom 1Gb Driver for Windows Server x64 Editions 17.4.0.0  (cp030252) + NCU

########------------------------------------------------------------------########
########  W2012 / Must fully support SPP201704 level (G8->G9, G8_EOS)
$I31W2012 = @(
            ("cp029394","cp029429","cp030019", "cp029425", "cp029408", "cp030039", "cp029653", "cp029672", ""), #1704 Verified
            ("",""),
            ("",""),
            ("","")
            )
$I31W2012Dev = @(
             ("xEX554FLB","xEX554FLB","xEX554FLB","xQL630FLB","xQL630FLB","_3Par","_3Par"),
            ("cp029983","cp032106","cp031846",    "cp030253","cp028020",  "HPE3PI17.msi","cp027948" ),
            ("","","","","",""),
            ("","","","","",""),
            ("","","","","","")
            )
# 2K12 201704 the same as 2012R2, except HPE Emulex 10/20 GbE Driver for Windows Server 2012 (cp032106)-11.1.145.30 cp032106

$I36W2012 = @(         
            ("cp029394","cp029429", "cp030039", "cp030228", "cp029672","cp029408","cp030019", "" ), #1704 Verified
            ("cp035107","cp035109", "cp037336", "cp035801", "cp032302","", "" ), #1811 Verified
            ("cp039984","cp035109", "cp039504", "cp035801", "cp038691","", "" ), #1909 Verified
            ("","","","","","")
            )
$I36W2012Dev = @(  
             ("xEX554FLB","xEX554FLB","xEX554FLB","_3Par","_3Par" ),
            ("cp029983","cp032106","cp031846",    "cp027948","HPE3PI17.msi"),            
            ("cp037422","cp034398","cp037462",    "cp034831","HPE3PI17.msi"),
            ("cp035755","cp037002","cp035749",    "cp034831","HPE3PI17.msi"),
            ("","","","","","")
            )
#  iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 
#   (cp029394) 3.30.0.0 /dtto / 4.0.0.0 (cp035107) / 4.1.0.0  (cp039984)
#  iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 
#   (cp029429) 3.30.0.0 /dtto / 4.0.0.0 (cp035109) /dtto
#  HPE StoreEver Tape Drivers for Microsoft Windows 
#   (cp030019)  4.2.0.0 /dtto / NA
#  PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2  
#   cp029408 1.0.0.0 / (cp030441) /NA
#  HPE ProLiant Agentless Management Service for Windows X64 
#   cp030039 10.60.0.0 / (cp031439) 10.60.0.0 / 10.90.0.0 (cp037336) / 10.96.0.0 (cp039504)
#  HPE ProLiant Gen9 Chipset Identifier for Windows 
#   (cp030228) 10.1.2.77  /dtto / 10.1.17809.8096 (cp035801) /dtto
#  Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 
#   9.15.1.143 (cp029672) / 9.15.1.184 (cp032302) /dtto / 9.15.1.224 (cp038691) 
#Dev: EX554FLB
#  HPE Storage Fibre Channel Over Ethernet Adapter Kit for the x64 Emulex Storport Driver 
#   11.1.145.16 (cp029983) /  11.2.1135.0 (cp032471) / 12.0.1109.0 (cp037422) / 12.0.1192.0 (cp035755)
#  HPE Emulex 10/20 GbE Driver for Windows Server 2012 11.1.145.30 
#   (cp032106) 11.1.145.30  / 11.2.1153.13 (cp030661) / 12.0.1115.0 (cp034398) / 12.0.1195.0 (cp037002)
#  HPE Firmware Flash for Emulex Converged Network Adapters - Windows (x64) 
#   (cp031846) 2016.10.05 / 2017.09.01  (cp032466) / 2018.11.01  (cp037462) / 2019.03.01 (cp035749)
# 3Par
#  HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems 
#   (cp027948) 3.1.1.1 /dtto / 3.2.1.0 (cp034831)/dtto
# Other N/A
#  Online ROM Flash for Windows x64 - Advanced Power Capping Microcontroller Firmware for HPE Gen9 Servers (cp029898) 1.0.9 /1.0.9(cp031162)/1.0.9(I)(cp037781)/dtto

$P89W2012 = @(         
            ("cp029394","cp029429", "cp027948", "cp030039", "cp030228", "cp029672", "cp030019", "cp029408","HPE3PI17.msi", ""), #1704 Verified
            ("cp035107","cp035109", "cp034831", "cp037336", "cp035801", "cp032302", "HPE3PI17.msi", "" ), #1811 Verified
            ("cp035107","cp035109", "cp034831", "cp037336", "cp035801", "cp032302", "HPE3PI17.msi", "" ), #1811 Verified
            ("","","","","","")
            )
$P89W2012Dev = @( 
             ("xQLOGCFCA","xQLOGCFCA","xP440AR", "xP440AR", "xP440AR", "x560SFP", "x331i"),
            ("cp031889","cp030243","cp032118", "cp030137", "cp031007", "cp029059", "cp030252"),             
            ("cp037431","cp037454","cp037439", "cp037465", "cp037424", "cp033707", "cp037379"),
            ("cp037431","cp037454","cp037439", "cp037465", "cp037424", "cp033707", "cp037379"),
            ("","","","","","")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 (cp029394) / / 4.0.0.0 (cp035107) 
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) / / 4.0.0.0  (cp035109)
# HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems cp027948 / / 3.2.1.0 (cp034831)
# HPE ProLiant Agentless Management Service for Windows X64 cp030039 / 10.60.0.0 cp031439 / 10.90.0.0 (cp037336)
# HPE ProLiant Gen9 Chipset Identifier for Windows (cp030228)  10.1.2.77 / / 10.1.17809.8096 (cp035801)
# Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 9.15.1.143 (cp029672) / 9.15.1.184 (cp032302)
# HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) / / NA
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2  cp029408 / 2012 and Server 2012 R2 1.0.0.0 (cp030441) / NA
# Dev: QLOGCFCA
# HPE Storage Fibre Channel Adapter Kit for the QLogic Storport Driver for Windows Server 2012 and 2012 R2 9.1.17.25 (cp031889) / 9.2.5.21 (cp032880) / 9.2.8.20  (cp037431) 
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1 (cp030243) / 1.0.0.1 (cp033239) / 1.0.0.1 (cp037454)
# Dev: P440AR
# HPE ProLiant Smart Array HPCISSS3 Controller Driver for 64-bit Microsoft Windows Server 2012/2016 Editions 100.18.2.64  (cp032118) / 100.20.0.64 (cp033990) /100.20.0.64 (cp037439)
# HP ProLiant Smart Array SAS/SATA Event Notification Service for for 64-bit Windows Server Editions 6.46.0.64 (cp030137) / 6.46.0.64 (cp034046) / 6.46.0.64  (cp037465)
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 2.65.7.0  (cp031007) / 3.25.4.0 (cp032646) / 3.30.14.0 (cp037424)
# Dev: 560SFP
# HPE Intel ixn/ixt Drivers for Windows Server 2012 3.9.58.9101 (cp029059) / 3.14.78.0 (cp033707) / 3.14.78.0 (cp033707)
# Dev: 331i
# HPE Broadcom 1Gb Driver for Windows Server x64 Editions 17.4.0.0  (cp030252) / 20.8.0.0 (cp033341) / 214.0.0.0 (cp037379)
$U17W2012 = @(
            ("cp029394","cp029429", ""), #1704 N/A
            ("cp035107","cp035109", "cp037336", "" ), #1811 incomplete
            ("cp035107","cp035109", "" ), #1903 N/A
            ("","","","","","")
            )
$U17W2012Dev = @(
             ("x331FLR"),
            ("cp030252"),
            ("x"),
            ("x"),
            ("","","","","","")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 (cp029394) / / 4.0.0.0 (cp035107) 
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) / / 4.0.0.0  (cp035109)
# HPE ProLiant Agentless Management Service for Windows X64 cp030039 / 10.60.0.0 cp031439 / 10.90.0.0 (cp037336)
#Dev: 
# HPE Broadcom 1Gb Driver for Windows Server x64 Editions 17.4.0.0 (cp030252)

########------------------------------------------------------------------########
########  W2012R2 / Must fully support 201710 level (G8->G9)
$P71W2012R2 = @(     
            ("cp029394","cp029429", ""),  #1704 for SUT only
            ("cp029394","cp029429", "cp029408", "cp030039", "cp030019", "cp029672", ""), #
            ("x",""),
            ("","","","","","")
            )
$P71W2012R2Dev = @(  
             ("_P420i","_P420i","_P420i","_P420i",        "_3Par", "_3Par", ".331T", "_QLOGCFCA", "_QLOGCFCA", ".QLOGCFCA",           ".P420i", ""),
            ("x","",""),
            ("cp032801","cp028045","cp031007","cp030137", "cp027948", "HPE3PI17.msi", "cp030252", "cp031889", "cp030243", "cp029691", "cp033362"),
            ("x","",""),
            ("","","","","","")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 3.30.0.0 (cp029394) 
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 3.30.0.0 (cp029429) 
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2 1.0.0.0 (cp029408) 
# HPE ProLiant Agentless Management Service for Windows X64 10.60.0.0 (cp030039)
# HPE StoreEver Tape Drivers for Microsoft Windows 4.2.0.0 (cp030019) 
# Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 9.15.1.143 (cp029672) 
#Dev: P420i / HPE ProLiant Smart Array HPCISSS3 Controller Driver for 64-bit Microsoft Windows Server 2012/2012 R2/2016 Editions 100.20.0.64 (cp032801)
# HP ProLiant Smart Array SAS/SATA Controller Driver for Windows Server 2012 x64 Edition 62.28.0.64 (cp028045) 
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 2.65.7.0 (cp031007) 
# HP ProLiant Smart Array SAS/SATA Event Notification Service for for 64-bit Windows Server Editions 6.46.0.64 (cp030137) 
#Dev: #Par / HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems 3.1.1.1 (cp027948) 
#Dev 331T / HPE Broadcom 1Gb Driver for Windows Server x64 Editions 17.4.0.0 (cp030252)
#Dev QLOGCFCA / HPE Storage Fibre Channel Adapter Kit for the QLogic Storport Driver for Windows Server 2012 and 2012 R2 9.1.17.25 (cp031889)  
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1 (cp030243) 
# HPE Firmware Online Flash for QLogic Fibre Channel Host Bus Adapters - Windows 2008/2012 (x64) 2016.10.01 (cp029691) 
#Dev P420i /  Online ROM Flash Component for Windows (x64) - Smart Array P220i, P222, P420i, P420, P421, P721m, and P822 8.00  (cp030726) / 8.30 (cp033362) 
# ??? Online ROM Flash for Windows - Power Management Controller (HP ProLiant Gen8 Servers) 3.3 (cp021612)  
# ??? Online ROM Flash Component for Windows (x64) - EH0146FBQDC and EH0300FBQDD drives (cp029260) 

$P70W2012R2 = @(     
            ("cp029394","cp029429","cp029653","cp029408","cp030039","cp030019","cp029672","cp029425", "", ""), #verfied
            ("cp029394","cp029429","cp029653","cp029408","cp030039","cp030019","cp029672","cp029425", "", ""), #verified
            ("x",""),
            ("x","")
            )
$P70W2012R2Dev = @( 
             ("xQLOGCFCA","xQLOGCFCA","xQLOGCFCA","x560SFP","x331FLR","x331FLR","xP420i","xP420i","_P420i",     "_3Par","_3Par",          "_P420i","xP420i","xP420i","xP420i"),
            ("cp031889","cp030243","cp029691","cp029060","cp030252","cp029395","cp032118","cp028045","cp031007","HPE3PI17.msi","cp027948","cp030137","x","cp029247","cp030726"),
            ("cp031889","cp030243","cp029691","cp029060","cp030252","cp029395","cp032801","cp028045","cp031007","HPE3PI17.msi","cp027948","cp030137","cp029250","cp029247","cp033362"),
            ("x","",""),
            ("x","")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 3.30.0.0 (cp029394) / dtto
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 3.30.0.0 (cp029429) / dtto
# Combined Chipset Identifier for Windows Server 2012 and Server 2012 R2 8.2.0.0 (cp029653) / missing
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2 1.0.0.0 (cp029408) / dtto
# HPE ProLiant Agentless Management Service for Windows X64 10.60.0.0 (cp030039) / dtto
# HPE StoreEver Tape Drivers for Microsoft Windows 4.2.0.0 (cp030019) / dtto
# Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 9.15.1.143 (cp029672) / dtto
# Headless Server Registry Update for Windows Server 2008 to Server 2012 R2 1.0.0.0  (cp029425) / missing
#Dev: QLOGCFCA
# HPE Storage Fibre Channel Adapter Kit for the QLogic Storport Driver for Windows Server 2012 and 2012 R2 9.1.17.25 (cp031889) / dtto
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1 (cp030243) / dtto
# HPE Firmware Online Flash for QLogic Fibre Channel Host Bus Adapters - Windows 2008/2012 (x64) (cp029691) 2016.10.01 / dtto
#Dev: 560SFP
# HPE Intel ixn/ixt Drivers for Windows Server 2012 R2 3.9.58.9101  (cp029060) / ?
#Dev: 331FLR
# HPE Broadcom 1Gb Driver for Windows Server x64 Editions 17.4.0.0 (cp030252) / dtto
# HPE Broadcom NX1 Online Firmware Upgrade Utility for Windows Server x64 Editions 5.0.0.24 (cp029395) / dtto
#Dev: P420i
# HPE ProLiant Smart Array HPCISSS3 Controller Driver for 64-bit Microsoft Windows Server 2012/2016 Editions 100.18.2.64-faulty (cp032118) / 100.20.0.64 (cp032801)
# HP ProLiant Smart Array SAS/SATA Controller Driver for Windows Server 2012 x64 Edition 62.28.0.64 (cp028045) / dtto
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 2.65.7.0 (cp031007) / dtto
# 3PArInfo + HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems 3.1.1.1 (cp027948) / ?
# HP ProLiant Smart Array SAS/SATA Event Notification Service for for 64-bit Windows Server Editions 6.46.0.64 (cp030137) / dtto
# Online ROM Flash Component for Windows (x64) - EG0300FBVFL, EG0450FBVFM, EG0600FBVFP, and EG0900FBVFQ Drives ? / HPDE (cp029250) 
# Online ROM Flash Component for Windows (x64) - EG0300FBDBR, EG0450FBDBT and EG0600FBDBU Drives (cp029247) HPDA / dtto
# Online ROM Flash Component for Windows (x64) - Smart Array P220i, P222, P420i, P420, P421, P721m, and P822 / cp030726 8.00 /  cp033362 8.32 

# N/A  Online ROM Flash for Windows - Power Management Controller (HP ProLiant Gen8 Servers) 3.3 (cp021612) 

$I31W2012R2 = @(
            ("cp029394","cp029429","cp030019", "cp029408", "cp030039", "cp029672", ""), #1704 Verified on 554 and 630
            ("", ""), 
            ("", ""), 
            ("", "")
            )
$I31W2012R2Dev = @(
             ("xEX554FLB","xEX554FLB","xQL630FLB", "_3Par",  "_3Par",   "xEX554FLB","xQL630FLB" ),
            ("cp029983","cp027194","cp030253","HPE3PI17.msi","cp027948","cp031846", "cp028020"),
            ("","","","","",""),
            ("", ""), 
            ("","","","","","")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 3.30.0.0 (cp029394) /dtto
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 3.30.0.0 (cp029429) / dtto
# HPE StoreEver Tape Drivers for Microsoft Windows 4.2.0.0  (cp030019) /dtto
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2 1.0.0.0 (cp029408) /dtto 
# HPE ProLiant Agentless Management Service for Windows X64 10.60.0.0 (cp030039) / dtto
# Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 9.15.1.143 (cp029672) / dtto
#Dev: EX554FLB
# HPE Storage Fibre Channel Over Ethernet Adapter Kit for the x64 Emulex Storport Driver 11.1.145.16 (cp029983) /dtto
# HPE Emulex 10/20 GbE Driver for Windows Server 2012 R2 (cp027194) 10.7.110.16 cp027194 /dtto
# HPE Firmware Flash for Emulex Converged Network Adapters - Windows (x64) 2016.10.05  (cp031846) /dtto
#Dev: QL630FLB
# HPE QLogic NX2 10/20GbE Multifunction Drivers for Windows Server x64 Editions (cp030253)
# HPE QLogic NX2 Online Firmware Upgrade Utility for Windows Server x64 Editions (cp028020) /dtto
#3Par:  HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems 3.1.1.1 (cp027948) /dtto 
# NA Online ROM Flash for Windows - Power Management Controller (HP ProLiant Gen8 Servers) 3.3 (cp021612) 

$P89W2012R2 = @(         
            ("cp029394","cp029429","cp030019", "cp029408", "cp030039", "cp030228", "cp029672", ""), #1704 Verified
            ("cp035107","cp035109","x", "x", "cp037336", "cp035801", "cp032302", ""), #1811 Verified
            ("cp035107","cp035109","x", "x", "cp037336", "cp035801", "cp032302", ""), #1811 Verified - 1909 NA - SW82Q HBAFW:8.08.01 issue
            ("cp039984","cp035109","x", "x", "cp041470", "cp040885", "cp038691", "" ) #201912
            )
$P89W2012R2Dev = @( 
             ("xQLOGCFCA","xQLOGCFCA","xQLOGCFCA","xP440AR", "xP440AR", "_P440AR","xP440AR","_P440AR", "x560SFP", "x560SFP", "x331i", "_3Par", "_3Par"),
            ("cp031889","cp030243","",        "cp032118", "cp030137", "cp031007", "", "",              "cp029060", "",       "cp030252", "HPE3PI17.msi", "cp027948"),
            ("cp037431","cp037454","",        "cp037439", "cp037465", "cp037424", "", "",              "cp033708", "",       "cp037379", "HPE3PI17.msi", "cp034831"),
            ("cp037431","cp037454","",        "cp037439", "cp037465", "cp037424", "", "",              "cp033708", "",       "cp037379", "HPE3PI17.msi", "cp034831"),
            ("cp039716","cp039719","cp039710","cp037982", "cp037465", "cp039745", "cp039995","cp039747","cp040861","cp040152","cp040545","HPE3PI17.msi", "cp034831")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 (cp029394) / / 4.0.0.0 (cp035107) /  (cp039984) 4.1.0.0 
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) / / 4.0.0.0 (cp035109)
# HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) / / NA
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2  cp029408 / PFA Server 2012 and Server 2012 R2 1.0.0.0 (cp030441) / NA
# HPE ProLiant Agentless Management Service for Windows X64 cp030039 /  10.80.0.0  (cp032760) / 10.90.0.0 (cp037336) / (cp041470) 10.97.0.0
# HPE ProLiant Gen9 Chipset Identifier for Windows (cp030228)  10.1.2.77 / / 10.1.17809.8096 (cp035801) /  (cp040885) 10.1.17969.8134 
# Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 9.15.1.143 (cp029672) / 9.15.1.184 (cp032302) / (cp038691) 9.15.1.224
#  Identifiers for Intel Xeon Processor Scalable Family for Windows 10.1.2.86 (cp033114) / 1803 / NA
#  Identifiers for AMD EPYC Processors for Windows 1.0.0.0  (cp033115) / 1803 / NA
#Dev: QLOGCFCA
# HPE Storage Fibre Channel Adapter Kit for the QLogic Storport Driver for Windows Server 2012 and 2012 R2 9.1.17.25 (cp031889) / 9.2.5.21 (cp032880) / 9.2.8.20 (cp037431) / (cp039716) 9.3.3.20 
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1 (cp030243) / 1.0.0.1 (cp033239) / 1.0.0.1 (cp037454) / (cp039719) 1.0.0.1  
# HPE Firmware Online Flash for QLogic Fibre Channel Host Bus Adapters - Windows 2012R2/2016/2019 (cp039710) 2019.12.01 
#Dev: P440AR
# HPE ProLiant Smart Array HPCISSS3 Controller Driver for 64-bit Microsoft Windows Server 2012/2016 Editions 100.18.2.64  (cp032118) / 100.20.0.64 (cp033990) / 100.20.0.64 (cp037439)/(cp037982) 106.26.0.64
# HP ProLiant Smart Array SAS/SATA Event Notification Service for for 64-bit Windows Server Editions 6.46.0.64 (cp030137) / 6.46.0.64 (cp034046) / 6.46.0.64 (cp037465)/(cp037465) 6.46.0.64
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 2.65.7.0  (cp031007) / 3.25.4.0 (cp032646) / 3.30.14.0 (cp037424) /(cp039745) 4.15.6.0
# ROM Flash Component for Windows (x64) - Smart Array  / (cp039995) 7.00
# HPE Smart Storage Administrator Diagnostic Utility (HPE SSADU) CLI for Windows 64-bit / (cp039747) 4.15.6.0 
#Dev: 560SFP
# HPE Intel ixn/ixt Drivers for Windows Server 2012 R2 3.9.58.9101 (cp029060) / 3.14.78.0 (cp033708) /  3.14.78.0  (cp033708) / (cp040861) 3.14.132.0
# HPE Intel Online Firmware Upgrade Utility for Windows Server x64 Editions / (cp040152) 5.2.0.0
#Dev: 331i
# HPE Broadcom 1Gb Driver for Windows Server x64 Editions 17.4.0.0  (cp030252) / 20.8.0.0 (cp033341) / 214.0.0.0 (cp037379) / (cp040545) 214.0.0.0
# 3PAr / HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems cp027948 / / 3.2.1.0 (cp034831)/dtto

$I36W2012R2 = @(         
            ("cp029394","cp029429","cp030039", "cp030228", "cp029672", "cp029427","cp029408","cp030019", ""), #1704 Verified
            ("cp035107","cp035109","cp037336", "cp035801", "cp032302", "cp035799", ""), #1811 verified
            ("cp039984","cp035109","cp039504", "cp035801", "cp038691", "cp035799", ""),
            ("","","")
            )
$I36W2012R2Dev = @(  
             ("_3Par", "_3Par",        "xEX554FLB","xEX554FLB","xQL630FLB","xQL630FLB","xEX554FLB" ),
            ("cp027948","HPE3PI17.msi","cp029983","cp027194",  "cp030253","cp028020",  "cp031846"),            
            ("cp034831","HPE3PI17.msi","cp037422","cp034399",  "cp037380","cp037351", "cp037462"),
            ("cp034831","HPE3PI17.msi","cp035755","cp037003",  "cp036669","cp036015", "cp035749"),
            ("","","")
            )
#iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 
#  cp029394 / 4.0.0.0 (cp035107) / 4.1.0.0 (cp039984)
#iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 
#  cp029429) / 4.0.0.0 (cp035109) / 4.0.0.0 (cp035109)
#HPE ProLiant Agentless Management Service for Windows X64 
#  cp030039 / 10.90.0.0 (cp037336) / 10.96.0.0 (cp039504)
#HPE ProLiant Gen9 Chipset Identifier for Windows 
#  cp030228)  10.1.2.77 / 10.1.17809.8096(cp035801) /10.1.17809.8096 (cp035801)
#Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 
#  9.15.1.143 (cp029672) / 9.15.1.184 / 9.15.1.224 (cp038691)
#NVMe Drive Eject NMI Fix for Windows Server 2012 R2 and Server 2016 
#  1.0.5.0 (cp029427) / 1.0.5.0 cp035799 /  1.0.5.0 (cp035799) 
#HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) 
#  / / NA
#PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2  cp029408 / PFA Server 2012 and Server 2012 R2 1.0.0.0 (cp030441) / NA
# Identifiers for Intel Xeon Processor Scalable Family for Windows 10.1.2.86 (cp033114) / 1803 / NA
# Identifiers for AMD EPYC Processors for Windows 1.0.0.0  (cp033115) / 1803 / NA
#3Par / HP 3PAR HostExplorer for Windows Server 2008 and 2012 x64 Operating Systems 
#  cp027948 / 3.2.1.0 (cp034831) / 3.2.1.0 (cp034831) 
#Dev: EX554FLB
#HPE Storage Fibre Channel Over Ethernet Adapter Kit for the x64 Emulex Storport Driver 
#  11.1.145.16 (cp029983) / 12.0.1109.0 (cp037422) /  12.0.1192.0 (cp035755) 
#  HPE Emulex 10/20 GbE Driver for Windows Server 2012 R2 
#  10.7.110.16 (cp027194) / 12.0.1115.0(cp034399) /  12.0.1195.0 (cp037003)
#  HPE Firmware Flash for Emulex Converged Network Adapters for Windows (x64) 
#  cp031846 / 2018.11.01 (cp037462) / 2019.03.01 (cp035749) 
# Dev: QL630FLB
#  HPE QLogic NX2 10/20 GbE Multifunction Drivers for Windows Server x64 Editions cp030253 / 7.13.155.0 (cp037380) / 7.13.161.0  (cp036669)
#  HPE QLogic NX2 Online Firmware Upgrade Utility for Windows Server x64 Editions (cp028020) / 5.1.3.6  (cp037351) / 5.1.4.0  (cp036015) 
#1909 N/I
#Online ROM Flash for Windows x64 - Advanced Power Capping Microcontroller Firmware for HPE Gen9 Servers 1.0.9(I)  (cp037781) 

$P86W2012R2 = @(         
            ("", ""),            
            ("cp035107","cp035109","cp037336", "cp035801", "cp032302", "cp029408", ""), #1811
            ("cp039984","cp035109","cp039504", "cp035801", "cp038691", "", ""),  #1909
            ("", "")
            )  
$P86W2012R2Dev = @(   
             ("_P440","x331T","x331T","x361i",            "_P440", "_P440","xP440", "x361i",              "xP440","xP440","xP440" ),
            ("","" ),  
            ("cp037439","cp037379","cp037348","cp028838", "cp037465", "cp037424", "cp037669", "cp037350", "cp034301","cp034298","" ),
            ("cp037982","cp036186","cp036111","cp037767", "cp037465", "cp038944", "cp039995", "cp035128", "cp037012","cp037254","cp037953" ),
            ("", "")
            )
#  iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 
#  ? / 3.30.0.0 (cp029394) / 4.0.0.0 (cp035107) /  4.1.0.0 (cp039984)
#  iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) 
#  / 3.30.0.0 (cp029429) / 4.0.0.0 (cp035109) / 4.0.0.0  (cp035109)
#  HPE ProLiant Agentless Management Service for Windows X64 
#  / 10.75.0.0 (cp032257)/ 10.90.0.0 (cp037336) / 10.96.0.0 (cp039504)
#  HPE ProLiant Gen9 Chipset Identifier for Windows 
#  / 10.1.2.77 (cp030228)  / 10.1.17809.8096 (cp035801) / 10.1.17809.8096  (cp035801)
#  Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2   
# / 9.15.1.184 (cp032302) / 9.15.1.184 (cp032302) / 9.15.1.224  (cp038691)
#  PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2 
#  / 1.0.0.0  (cp030441) / (cp029408) / -
#  HPE StoreEver Tape Drivers for Microsoft Windows 
#  / 4.2.0.0 (cp030019) / - / -
# Dev: 361i 331T P440
#  HPE ProLiant Smart Array HPCISSS3 Controller Driver for 64-bit Microsoft Windows Server 2012/2016 Editions  
#  / 100.20.0.64 (cp032801)  /100.20.0.64 (cp037439) / 106.26.0.64 (cp037982) 
#  HPE Broadcom 1Gb Driver for Windows Server x64 Editions 
#  / 20.6.0.5 (cp032617) /214.0.0.0 (cp037379) /214.0.0.0 (cp036186)
#  HPE Broadcom NX1 Online Firmware Upgrade Utility for Windows Server x64 Editions
#  /  5.1.1.0 cp032626 / (cp037348) / (cp036111)
#  HPE Intel E1R Driver for Windows Server 2012 R2 
#  / 12.14.8.0  (cp028838) / same  /  12.14.8.0 (cp037767) 
#  HPE ProLiant Smart Array SAS/SATA Event Notification Service for 64-bit Windows Server Editions 
#  / 6.46.0.64 (cp032820) / 6.46.0.64 (cp037465) /  6.46.0.64 (cp037465)
#  HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 
#  / 3.10.3.0  (cp031012) / 3.30.14.0 (cp037424) / 3.47.6.0 (cp038944)
#  Online ROM Flash Component for Windows (x64) - Smart Array and Smart HBA H240ar, H240nr, H240, H241, H244br, P240nr, P244br, P246br, P440ar, P440, P441, P542D, P741m, P840, P840ar, and P841 
#  / 6.06  (cp032781) / 6.60  (cp037669) /  7.00 (cp039995)
#  HPE Intel Online Firmware Upgrade Utility for Windows Server x64 Editions 
#  / 5.1.1.0  (cp032236)  / 5.1.3.0 (cp037350) / 5.1.4.0 (cp035128)
# Online ROM Flash Component for Windows (x64) - EG0600JETKA, EG0900JETKB, and EG1200JETKC Drives / HPD6 (cp032368) / HPD6 cp034301) / HPD7  (cp037012)
# Online ROM Flash Component for Windows (x64) - EG0300JFCKA, EG0600JEMCV, EG0900JFCKB, and EG1200JEMDA Drives / HPD6 (cp032288) /  HPD6(cp034298) / HPD6  (cp037254) 
# ROM Flash Component for Windows (x64) - EG000600JWEBH and EG000300JWEBF Drives (cp037953)
 
# NI - 1909 - Dynamic Smart Array B140i Controller Driver for 64-bit Microsoft Windows Server 2012/2012 R2/2016/2019 Editions 62.12.0.64 (cp038272) 

$U32W2012R2 = @(         
            ("x","x"),             
            ("cp034070","cp034831","cp037335","cp033123", "cp034635", "cp035137", "cp035802", "HPE3PI17.msi", ""), #1811 verified
            ("cp034070","cp034831","cp037335","cp033123", "cp034635", "cp035137", "cp035802", "HPE3PI17.msi", ""), #1811 verified
            ("x","x")
            )
$U32W2012R2Dev = @(
             ("x331i","x562SFP","xSN1100Q","xSN1100Q"),
            ("x","x"),
            ("cp037379","cp033275","cp037431","cp037454"),
            ("cp037379","cp033275","cp037431","cp037454"),
            ("x","x")
            )
# iLO 5 Channel Interface Driver for Windows Server 2012 R2 4.3.0.0 (cp034070) 
# HPE 3PAR HostExplorer for Windows Server 2008 2012 and 2016 x64 Operating Systems 3.2.1.0 (cp034831) 
# Agentless Management Service for Windows X64 1.30.0.0 (cp037335) 
# Matrox G200eH3 Video Controller Driver for Windows Server 2012 R2 9.15.1.184 (cp033123) 
# NVMe Drive Eject NMI Fix for Intel Xeon Processor Scalable Family for Windows 1.1.0.0 (cp034635) 
# iLO 5 Automatic Server Recovery Driver for Windows Server 2012 R2 4.2.0.0 / 4.4.0.0 (cp035137) 
# Identifiers for Intel Xeon Processor Scalable Family for Windows Server 2012 R2 to Server 2019 10.1.2.86 / 10.1.17809.8096 (cp035802) 
# Dev: 331i
#  HPE Broadcom NX1 1Gb Driver for Windows Server x64 Editions 212.0.0.0 / 214.0.0.0 (cp037379) 
# Dev: 562SFP
#  HPE Intel i40ea Driver for Windows Server 2012 R2 1.8.94.0 / 1.8.83.0 (cp033275) (562SFP-Downgrade!)
#Dev: SN1100Q
# HPE Storage Fibre Channel Adapter Kit for the x64 QLogic Storport Driver for Windows Server 2012 and 2012 R2 9.2.8.20  (cp037431) 
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1 (cp037454) 

$U30W2012R2 = @(         
            ("x","x"),             
            ("cp034070","cp037335","cp033123", "cp034635", "cp035137","cp035802", ""), #1811
            ("cp039986","cp039663","cp038693", "cp034635", "cp035137","cp038754", ""), #1909
            ("cp040013","cp040001","cp040214", "cp034635", "cp040015","cp040561")
            )
$U30W2012R2Dev = @(  
             ("x331i","x331i",     "xP816i","xP816i","xP816i",      "xP816i","xP816i","xP816i","xP816i"),
            ("x","x"),
            ("cp037379","",        "cp037424","cp037451","cp036076","","","",""),
            ("cp036186","cp036111","cp038944","cp040553","cp039146","cp039215","cp037247","cp037295","cp039532"),
            ("cp040545","cp040814","cp039745","cp041257","cp037793","cp043370","cp040455","cp040392","cp040453")
            )
#  iLO 5 Channel Interface Driver for Windows Server 2012 R2 4.3.0.0 (cp034070) /  4.5.0.0 (cp039986) /(cp040013) 4.6.0.0
#  Agentless Management Service for Windows X64 1.30.0.0 (cp037335) / 1.44.0.0  (cp039663) / (cp040001) 2.10.0.0 
#  Matrox G200eH3 Video Controller Driver for Windows Server 2012 R2 9.15.1.184 (cp033123) / 9.15.1.224 (cp038693) /(cp040214) 9.15.1.224 
#  NVMe Drive Eject NMI Fix for Intel Xeon Processor Scalable Family for Windows 1.1.0.0 (cp034635) /1.1.0.0 (cp034635) /(cp034635) 1.1.0.0 
#  iLO 5 Automatic Server Recovery Driver for Windows Server 2012 R2  4.4.0.0 (cp035137) / 4.4.0.0 (cp035137) / (cp040015)  4.6.0.0 
#  Identifiers for Intel Xeon Processor Scalable Family for Windows Server 2012 R2 to Server 2019 10.1.17809.8096 (cp035802) /  10.1.17861.8101 (cp038754) /(cp040561) 10.1.18015.8142 
# Dev: 331i
#  HPE Broadcom NX1 1Gb Driver for Windows Server x64 Editions 214.0.0.0 (cp037379) /214.0.0.0 (cp036186) / (cp040545) 214.0.0.0
#  HPE Broadcom NX1 Online Firmware Upgrade Utility for Windows Server x64 Editions ? / 5.1.4.0  (cp036111) / (cp040814)  5.2.0.0
# Dev P816i
#  HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit (cp037424) 3.30.14.0 / 3.47.6.0 (cp038944) / (cp039745) 4.15.6.0 
#  HPE Smart Array Gen10 Controller Driver for Windows Server 2012 R2, Windows Server 2016, and Windows Server 2019 (cp037451) 100.62.0.64 / 106.100.0.1014 (cp040553) / (cp041257) 106.166.0.1022 
#  HPE Smart Array SR Event Notification Service for Windows Server 64-bit Editions (cp036076) 1.2.0.64 / 1.2.1.64 (cp039146) / (cp037793) 1.2.1.64 
#  Online ROM Flash Component for Windows (x64) - HPE Smart Array P408i-p, P408e-p, P408i-a, P408i-c, E208i-p, E208e-p, E208i-c, E208i-a, P408i-sb, P408e-m, P204i-c, P204i-b, P816i-a and P416ie-m SR Gen10 ? / 1.99 (cp039215) / -> 2.65 cp043370
#  Online ROM Flash Component for Windows (x64) - MM1000JEFRB and MM2000JEFRC Drives ?/ HPD8  (cp037295) / cp040392 HPD8C
#  Online ROM Flash Component for Windows (x64) - EG000300JWFVB Drives ? / HPD2 (cp037247) / cp040455 HPD2C
#  Online ROM Flash Component for Windows (x64) - EG000600JWJNP and EG001200JWJNQ Drives cp039532) / (cp040453)  HPD2
 
$P67W2012R2 = @(         
            ("cp029394","cp029429", "cp029408", "cp030019"),   # 1704            
            ("cp024845","cp025786", "cp022305", "cp023805"),   # as 201510
            ("x","x", ""), 
            ("x","x")
            )
$P67W2012R2Dev = @( 
             ("xP410i", "xP410i", "xP410i", "xNC382i", "xNC382i"),
            ("cp028045", "cp030137", "cp031007", "cp023430", ""),
            ("cp028045","cp027261","cp027014", "cp023430", "cp025087"),
            ("x","x"),
            ("x","x")
            )
# iLO 3/4 Channel Interface Driver for Windows Server 2008 to Server 2012 R2 (cp029394)  3.30.0.0 /1510:3.10.0.0 (cp024845)
# iLO 3/4 Management Controller Driver Package for Windows Server 2008 to Server 2012 R2 (cp029429) 3.30.0.0 / 1510:(cp025786) 3.20.0.0 
# PFA Server Registry Update for Windows Server 2008 R2 to Server 2012 R2 (cp029408) 1.0.0.0 /1510:(cp022305) 1.0.0.0
# HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) 4.2.0.0 /1510:(cp023805) 4.0.0.0
#Dev P410i
# HP ProLiant Smart Array SAS/SATA Controller Driver for Windows Server 2012 x64 Edition (cp028045) 62.28.0.64 /1510:(cp020624) 62.28.0.64
# HP ProLiant Smart Array SAS/SATA Event Notification Service for for 64-bit Windows Server Editions (cp030137) 6.46.0.64/1510:(cp027261) 6.44.0.64
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit (cp031007) 2.65.7.0 /1510:(cp027014) 2.30.6.0 
#Dev NC382i
# HP Broadcom 1Gb Multifunction Drivers for Windows Server x64 Editions (cp023430) 7.8.50.0 / 1510:(cp023430) 7.8.50.0 
# HP QLogic NX2 10/20GbE Multifunction Drivers for Windows Server x64 Editions /1510 only: (cp025087) 7.12.41.0, NA in 1704

$U14W2012R2 = @(         
            ("x","x"),   # 1704            
            ("x","x"),
            ("cp039984","cp035109","cp039504","cp038691","cp035801"),
            ("x","x")
            )
$U14W2012R2Dev = @(              
             ("x361i","x560SFP","_EXLTPFCA","xEXLTPFCA","xEXLTPFCA", "_3Par","_3Par",          "xB140i","_B140i","_B140i"),
            ("x","x"),
            ("x","x"),
            ("cp037767","cp037915", "cp037970","cp035756","cp035754","cp034831","HPE3PI17.msi","cp038272","cp038944","cp037465"),
            ("x","x")
            )
# iLO 4 Channel Interface Driver for Windows Server 2012 and Server 2012 R2 4.1.0.0 (cp039984) 
# iLO 4 Management Controller Driver Package for Windows Server 2012 and Server 2012 R2 4.0.0.0 (cp035109) 
# HPE ProLiant Agentless Management Service for HPE Apollo, ProLiant and Synergy Gen9 servers 10.96.0.0 (cp039504) 
# Matrox G200eH Video Controller Driver for Windows Server 2012 and Server 2012 R2 9.15.1.224 (cp038691) 
# HPE ProLiant Gen9 Chipset Identifier for Windows Server 2012 to Server 2019 10.1.17809.8096 (cp035801)
#560
# HPE Intel ixn Driver for Windows Server 2012 R2 3.14.132.0 (cp037915) 
#361i
# HPE Intel E1R Driver for Windows Server 2012 R2 12.14.8.0 (cp037767) 
#SN1100E
# HPE Emulex Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1 (cp037970) 
# HPE Storage Fibre Channel Adapter Kit for the x64 Emulex Storport Driver for Windows 2012, Windows 2012R2 and Windows 2016 12.0.318.0 (cp035756) 
# HPE Firmware Flash for Emulex Fibre Channel Host Bus Adapters for Windows 2012/2012 R2/2016/2019 x64 2019.03.01 (cp035754) 
#B140i
# Dynamic Smart Array B140i Controller Driver for 64-bit Microsoft Windows Server 2012/2012 R2/2016/2019 Editions 62.12.0.64 (cp038272) 
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 3.47.6.0 (cp038944) 
# HPE ProLiant Smart Array SAS/SATA Event Notification Service for 64-bit Windows Server Editions 6.46.0.64 (cp037465) 
#3Par
# HPE 3PAR HostExplorer for Windows Server 2008 2012 and 2016 x64 Operating Systems 3.2.1.0 (cp034831) 

$U20W2012R2 = @(         
            ("x","x"),
            ("x","x"),
            ("cp039984","cp035109","cp039504"),
            ("x","x")
            )
$U20W2012R2Dev = @(              
             ("x","x"),
            ("x","x"),
            ("x","x"),
            ("x","x"),
            ("x","x")
            )
# iLO 4 Channel Interface Driver for Windows Server 2012 and Server 2012 R2 4.1.0.0 (cp039984) 
# iLO 4 Management Controller Driver Package for Windows Server 2012 and Server 2012 R2 4.0.0.0 (cp035109) 
# HPE ProLiant Agentless Management Service for HPE Apollo, ProLiant and Synergy Gen9 servers 10.96.0.0 (cp039504) 


########------------------------------------------------------------------########
########  W2016 
$I31W2016 = @(         
            ("x","x"), #1704 N/A          
            ("cp030218","cp030624","cp030671", "cp030672", "cp030039","cp030019","cp030431"), #From 201907 G8.15 upgrade
            ("x","x"),
            ("x","x")
            )
$I31W2016Dev = @(
             ("xQL630FLB","xQL630FLB","_3Par","_3Par"),
            ("x","x"),            
            ("cp030253","cp028020", "HPE3PI17.msi","cp034831"),
            ("x","x"),
            ("x","x")
            )
 
# Combined Chipset Identifier for Windows Server 2016 (cp030218)  10.1.2.77 
# PFA Server Registry Update for Windows Server 2016 1.5.0.0 (cp030624) 
# iLO 3/4 Channel Interface Driver for Windows Server 2016 (cp030671)  3.30.0.0
# HPE ProLiant Agentless Management Service for Windows X64 (cp030039) 10.60.0.0 
# iLO 3/4 Management Controller Driver Package for Windows Server 2016 (cp030672) 3.30.0.0  
# HPE StoreEver Tape Drivers for Microsoft Windows (cp030019) 4.2.0.0 
# Matrox G200eH Video Controller Driver for Windows Server 2016 (cp030431) 9.15.1.143 
# HPE QLogic NX2 10/20GbE Multifunction Drivers for Windows Server x64 Editions (cp030253)  7.13.104.
# HPE QLogic NX2 Online Firmware Upgrade Utility for Windows Server x64 Editions (cp028020)  5.0.0.24 
# SUT (cp032917) 2.0.1.0 

$I36W2016 = @(         
            ("x","x"), #1704 N/A            
            ("cp035108","cp035110", "cp037336", "cp035801", "cp035799", "cp035104", "", ""), #201811 Verified
            ("cp039985","cp037927", "cp039504", "cp035801", "cp035799", "cp038692", "", ""), #201909 Verified
            ("x","x")
            )
$I36W2016Dev = @(
             ("xQL630FLB","xQL630FLB","_3Par","_3Par",          "xEX554FLB","xEX554FLB","xEX554FLB"),
            ("x","x"),            
            ("cp037380","cp037351",   "HPE3PI17.msi","cp034831","cp037510","cp037422","cp037462"),
            ("cp036669","cp036015",   "HPE3PI17.msi","cp034831","cp037004","cp035755","cp035749"),
            ("x","x")
            )
# iLO 4 Channel Interface Driver for Windows Server 2016 and Server 2019 4.0.0.0  (cp035108) / 4.1.0.0 (cp039985)
# iLO 4 Management Controller Driver Package for Windows Server 2016 and Server 2019 4.0.0.0 (cp035110) / 4.0.0.0  (cp037927)
# HPE ProLiant Agentless Management Service for HPE Apollo, ProLiant and Synergy Gen9 servers 10.90.0.0  (cp037336) /10.96.0.0 (cp039504)
# HPE ProLiant Gen9 Chipset Identifier for Windows Server 2012 to Server 2019 10.1.17809.8096 (cp035801)  /dtto
# NVMe Drive Eject NMI Fix for Intel Xeon v3 and Xeon v4 Processors for Windows Server 2012 R2 to Server 2019 1.0.5.0 (cp035799) /dtto
# Matrox G200eH Video Controller Driver for Windows Server 2016 and Server 2019 9.15.1.218 (cp035104) / 9.15.1.224 (cp038692)
# Dev: 554FLB: HPE Emulex 10/20 GbE Driver for Windows Server 2016 12.0.1115.0 (cp037510) / 12.0.1195.0 (cp037004)
#   HPE Storage Fibre Channel Over Ethernet Adapter Kit for the x64 Emulex Storport Driver for Windows 2012, Windows 2012R2 and Windows 2016 12.0.1109.0 (cp037422) / 12.0.1192.0 (cp035755)
#   HPE Firmware Flash for Emulex Converged Network Adapters for Windows (x64) 2018.11.01  (cp037462) / 2019.03.01 (cp035749) 
# Dev: QL630FLB
#  HPE QLogic NX2 10/20 GbE Multifunction Drivers for Windows Server x64 Editions 7.13.155.0 (cp037380) / 7.13.161.0  (cp036669)
#  HPE QLogic NX2 Online Firmware Upgrade Utility for Windows Server x64 Editions 5.1.3.6  (cp037351) / 5.1.4.0  (cp036015) 
# HPE 3PAR HostExplorer for Windows Server 2008 2012 and 2016 x64 Operating Systems 3.2.1.0 (cp034831) /dtto
# NI: Online ROM Flash for Windows x64 - Advanced Power Capping Microcontroller Firmware for HPE Gen9 Servers 1.0.9(I) (cp037781) 

$U30W2016 = @(         
            ("x","x"), #1704 N/A            
            ("cp035112","cp035802", "cp034635", "cp035140", "cp035106", "cp037335", ""), #201811
            ("cp039987","cp038754", "cp034635", "cp035140", "cp038694", "cp039663", ""), #201909
            ("cp040014","cp040561", "cp034635", "cp040016", "cp040215", "cp040001", "")  #201912
            )
$U30W2016Dev = @(   
             ("x331i","x331i",     "xP816i","xP816i","xP816i","xP816i", "xP816i", "xP816i","xP816i",            "_S100i","xS100i",    "_P408i","_P408i","_P408i","xP408i","xP408i","xP408i","xP408i",              "xP824I-P","_P824I-P","xP824I-P","xP824I-P","_SN1100Q","xSN1100Q","xSN1100Q"), 
            ("x","x"),            
            ("cp036186","cp037348","cp037197","cp036076","cp037424","cp036957","cp034292","cp038745","cp037449","cp037222","cp037313"),
            ("cp036186","cp036111","cp040553","cp039146","cp038944","cp036957","cp040475","cp040676","cp039215","cp036435","cp039742","cp040553","cp039146","cp038944","cp038751","cp041697","cp040676","cp039215","cp034411","cp036916","","",                 "","",""),
            ("cp040545","cp040814","cp041257","cp037793","cp039745","cp040410","cp040475","cp040676","cp043370","cp036435","cp041317","cp041257","cp037793","cp039745","","","",""                                ,"cp034411","cp036916","cp040421","cp040218", "cp039719","cp039717","cp043694") 
            )

#iLO 5 Channel Interface Driver for Windows Server 2016 and Server 2019 (cp035112) 4.3.0.0 / 4.5.0.0  (cp039987) / (cp040014) 4.6.0.0
#Identifiers for Intel Xeon Processor Scalable Family for Windows Server 2012 R2 to Server 2019 (cp035802) 10.1.17809.8096 / 10.1.17861.8101 (cp038754) / (cp040561) 10.1.18015.8142
#NVMe Drive Eject NMI Fix for Intel Xeon Processor Scalable Family for Windows 1.1.0.0 (cp034635) / dtto / (cp034635) 1.1.0.0
#iLO 5 Automatic Server Recovery Driver for Windows Server 2016 and Server 2019 4.4.0.0 (cp035140) / dtto / (cp040016) 4.6.0.0 
#Matrox G200eH3 Video Controller Driver for Windows Server 2016 and Server 2019 (cp035106) 9.15.1.218 / 9.15.1.224 (cp038694) / (cp040215) 9.15.1.224
#Agentless Management Service for Windows X64 (cp037335) 1.30.0.0 / 1.44.0.0  (cp039663) / (cp040001) 2.10.0.0
#Devs
#HPE Broadcom NX1 1Gb Driver for Windows Server x64 Editions (cp036186 214.0.0.0 ) / dtto / (cp040545) 214.0.0.0
#FW: HPE Broadcom NX1 Online Firmware Upgrade Utility for Windows Server x64 Editions (5.1.3.6 cp037348) / (cp036111 5.1.4.0 ) / 5.2.0.0  (cp040814)
#HPE Smart Array Gen10 Controller Driver for Windows Server 2012 R2, Windows Server 2016, and Windows Server 2019 (cp037197 106.84.2.64 ) /  106.100.0.1014  (cp040553) / (cp041257) 106.166.0.1022 
#HPE Smart Array SR Event Notification Service for Windows Server 64-bit Editions (1.2.0.64 cp036076)  / 1.2.1.64 (cp039146)/(cp037793) 1.2.1.64 
#HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 3.30.14.0 (cp037424) / 3.47.6.0 (cp038944) / (cp039745) 4.15.6.0
# Online ROM Flash Component for Windows (x64) - MB8000GFECR Drives (HPG5 (cp036278) is faulty - replaced by HPG6 (cp036957) / cp040410 HPG6B
# Online HDD/SDD Flash Component for Windows (x64) - EG000600JWEBH and EG000300JWEBF Drives /cp034292 / (cp040475) HPD4 
#Online ROM Flash Component for Windows (x64) - VK000240GWSRQ, VK000480GWSRR, VK000960GWSRT, VK001920GWSRU and VK003840GWSRV Drives - unknown-placed HPG1 / HPG1 (cp038745 -> HPG2 cp040676) 
#FW: Online ROM Flash Component for Windows (x64) - HPE Smart Array P408i-p, P408e-p, P408i-a, P408i-c, E208i-p, E208e-p, E208i-c, E208i-a, P408i-sb, P408e-m, P204i-c, P204i-b, P816i-a and P416ie-m SR Gen10  1.65 cp037449 /  1.99 (cp039215)/ (cp039561->cp043370) 2.62->2.65
#Dev S100i
# HPE Smart Array S100i SR Gen10 SW RAID Driver for Windows Server 2012 R2, Windows Server 2016, and Windows Server 2019  100.8.0.0 (cp037222) / 106.12.4.0 (cp036435) 
# Alt 1: Online ROM Flash Component for Windows (x64) - VK000240GWJPD, VK000480GWJPE, VK000960GWJPF, VK001920GWJPH, VK003840GWJPK, MK000240GWKVK, MK000480GWJPN, MK000960GWJPP and MK001920GWJPQ Drives (cp037313 - HPG3) / HPG3 replaced by HPG5 htfx (cp039742) 
# Alt 2: Online HDD/SDD Flash Component for Windows (x64) - MR000240GWFLU, MR000480GWFLV, VR000480GWFMD, MR000960GWFMA, VR000960GWFME, MR001920GWFMB and VR001920GWFMC Drives (cp041317) HPGE
#Dev: P824I-P
# HPE Smart Array P824i-p MR 64-bit controller driver for Microsoft Windows 2016 edition. (cp034411) 6.714.18.0 
# HPE MegaRAID Storage Administrator (HPE MRSA) for Windows 64-bit (cp036916) 3.113.0.0
# Online HDD/SDD Flash Component for Windows (x64) - MB8000JFECQ Drives (cp040421) HPD7
# Online ROM Flash Component for Windows (x64) - HPE Smart Array P824i-p MR Gen10 (cp040218)  24.23.0-0042 
#Dev: SN1100Q
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems (cp039719) 1.0.0.1 
# HPE Storage Fibre Channel Adapter Kit for the x64 QLogic Storport Driver for Windows Server 2016 9.3.3.20 (cp039717) 
# HPE Firmware Online Flash for QLogic Fibre Channel Host Bus Adapters - Windows 2012R2/2016/2019 (x86_64) 2019.12.01/01.73.07 (cp039710 -> hotfixed cp043694-1.73.08) 

$U32W2016 = @(         
            ("x","x"), #1704 N/A
            ("x","x"), #201811 not impl.
            ("cp039987","cp038754", "cp035140", "cp039663", "cp038694", "cp034635", ""), #201909
            ("cp040014","cp040561", "cp041379", "cp042810", "cp040215", "cp034635", "")  #202003 - verify!, mainly sn1100Q
            )
$U32W2016Dev = @(
             ("x331i","x331i",     "xP408i","xP408i","_P408i","xP408i","xP408i","xP408i",            "xSN1100Q","xSN1100Q","xSN1100Q","_S100i" ), 
            ("x","x"),
            ("x","x"),
            ("cp036186","cp036111","cp040553","cp039146","cp038944","cp038751","cp041697","cp039215","cp037804","cp035776","cp040753","cp036435"),
            ("cp042633","cp042269","cp041257","cp037793","cp042018","","",                "cp043370","cp039719","cp039717","cp043694","cp043250") 
            )
# iLO 5 Channel Interface Driver for Windows Server 2016 and Server 2019 4.5.0.0 (cp039987) / cp040014
# Identifiers for Intel Xeon Processor Scalable Family for Windows Server 2012 R2 to Server 2019 10.1.17861.8101 (cp038754) / cp040561
# iLO 5 Automatic Server Recovery Driver for Windows Server 2016 and Server 2019 4.4.0.0 (cp035140) / cp041379
# Agentless Management Service for Windows X64 1.44.0.0 (cp039663) / cp042810
# Matrox G200eH3 Video Controller Driver for Windows Server 2016 and Server 2019 9.15.1.224 (cp038694) / (cp040215) 9.15.1.224
# NVMe Drive Eject NMI Fix for Intel Xeon Processor Scalable Family for Windows 1.1.0.0 (cp034635) /dtto
#   HPE Broadcom NX1 1Gb Driver for Windows Server x64 Editions 214.0.0.0 (cp036186) /  cp042633
#   HPE Broadcom NX1 Online Firmware Upgrade Utility for Windows Server x64 Editions cp036111 / cp042269
# HPE Smart Array Gen10 Controller Driver for Windows Server 2012 R2, Windows Server 2016, and Windows Server 2019 106.100.0.1014 (cp040553) / cp041257
# HPE Smart Array SR Event Notification Service for Windows Server 64-bit Editions 1.2.1.64 (cp039146) / (cp037793)  1.2.1.64  
# HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 3.47.6.0 (cp038944) / (cp039745) 4.15.6.0 / cp042018
# Online ROM Flash Component for Windows (x64) - MB001000GWFWK and MB002000GWFWL Drives HPG5 (cp038751) 
# HPD4-5 - EG001800JWJNR and EG002400JWJNT Drives cp039881- replaced by "cp041697"
# Online ROM Flash Component for Windows (x64) - HPE Smart Array P408i-p, P408e-p, P408i-a, P408i-c, E208i-p, E208e-p, E208i-c, E208i-a, P408i-sb, P408e-m, P204i-c, P204i-b, P816i-a and P416ie-m SR Gen10 1.99 (cp039215) /  (cp039561->cp043370) 2.62->2.65 
# 201912 -----
# HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems (cp039719) 1.0.0.1
# HPE Storage Fibre Channel Adapter Kit for the x64 QLogic Storport Driver for Windows Server 2016 (cp039717)  9.3.3.20 
# HPE Firmware Online Flash for QLogic Fibre Channel Host Bus Adapters - Windows 2012R2/2016/2019 (x86_64) (cp039710) 2019.12.01 (=01.73.07) / cp043694
# HPE Smart Array S100i SR Gen10 SW RAID Driver for Windows Server 2012 R2, Windows Server 2016, and Windows Server 2019 (cp036435) 106.12.4.0 / cp043250
# !!! - must be offline for HBA mode / Online HDD/SDD Flash Component for Windows (x64) - MR000240GWFLU, MR000480GWFLV, VR000480GWFMD, MR000960GWFMA, VR000960GWFME, MR001920GWFMB and VR001920GWFMC Drives (cp041317) HPGE



$P89W2016 = @(         
            ("x","x"), #1704 N/A
            ("cp035108","cp035110", "cp035801", "cp035104", "cp037336"),  #201811 
            ("cp039985","cp037927", "cp035801", "cp038692", "cp039504"),  #201909 
            ("x","x")
            )
$P89W2016Dev = @(                          
             ("xQLOGCFCA","xQLOGCFCA","xQLOGCFCA","x560SFP","x560SFP","x331i","x331i", "_3Par", "_3Par",            "xP440AR","xP440AR","_P440AR","xP440AR","xP440AR"),
            ("x","x"),
            ("cp037454","cp037432","cp037464","cp037391","cp037350","cp037379","cp037348","cp034831","HPE3PI17.msi","cp037439","cp037465","cp037424","cp035202","cp037669"),
            ("cp037804","cp035776","cp040753","cp037916","cp035128","cp036186","cp036111","cp034831","HPE3PI17.msi","cp037982","cp037465","cp038944","cp037253","cp039995"),
            ("x","x")
            )
#iLO 4 Channel Interface Driver for Windows Server 2016 and Server 2019 4.0.0.0 (cp035108) / 4.1.0.0 (cp039985)
#iLO 4 Management Controller Driver Package for Windows Server 2016 and Server 2019 4.0.0.0 (cp035110) / 4.0.0.0 (cp037927) 
#HPE ProLiant Gen9 Chipset Identifier for Windows Server 2012 to Server 2019 10.1.17809.8096  (cp035801) /  10.1.17809.8096 (cp035801)
#Matrox G200eH Video Controller Driver for Windows Server 2016 and Server 2019 9.15.1.218  (cp035104) / 9.15.1.224  (cp038692) 
#HPE ProLiant Agentless Management Service for HPE Apollo, ProLiant and Synergy Gen9 servers 10.90.0.0 (cp037336) / 10.96.0.0 (cp039504) 
#QLOGCFCA
#HPE QLogic Smart SAN Enablement Kit for Windows 64 bit operating systems 1.0.0.1  (cp037454) / 1.0.0.1 (cp037804)
#HPE Storage Fibre Channel Adapter Kit for the x64 QLogic Storport Driver for Windows Server 2016 9.2.8.20 (cp037432) / 9.2.9.22 (cp035776) 
#HPE Firmware Online Flash for QLogic Fibre Channel Host Bus Adapters - Windows 2012/2012R2/2016/2019 (x86_64) 2018.11.01  (cp037464) / 2019.03.02 (cp040753)
#560SFP
#HPE Intel ixn Driver for Windows Server 2016 4.1.77.0  (cp037391) / 4.1.131.0 (cp037916) 
#HPE Intel Online Firmware Upgrade Utility for Windows Server x64 Editions 5.1.3.0  (cp037350) / 5.1.4.0 (cp035128)
#331i
# HPE Broadcom NX1 1Gb Driver for Windows Server x64 Editions 214.0.0.0 (cp037379) / 214.0.0.0 (cp036186)
# HPE Broadcom NX1 Online Firmware Upgrade Utility for Windows Server x64 Editions (cp037348) 5.1.3.6 / cp036111 5.1.4.0
#3Par
#HPE 3PAR HostExplorer for Windows Server 2008 2012 and 2016 x64 Operating Systems 3.2.1.0 (cp034831) / dtto
#P440AR
#HPE ProLiant Smart Array HPCISSS3 Controller Driver for 64-bit Microsoft Windows Server 2012/2012 R2/2016/2019 Editions 100.20.0.64  (cp037439) / 106.26.0.64 (cp037982)  
#HPE ProLiant Smart Array SAS/SATA Event Notification Service for 64-bit Windows Server Editions 6.46.0.64 (cp037465) / dtto
#HPE Smart Storage Administrator (HPE SSA) for Windows 64-bit 3.30.14 (cp037424) / 3.47.6.0 (cp038944)
#Online ROM Flash Component for Windows (x64) - EG0300JEHLV, EG0600JEHMA, EG0900JEHMB, and EG1200JEHMC Drives HPD5  (cp035202) / HPD5 (cp037253)
#Online ROM Flash Component for Windows (x64) - Smart Array and Smart HBA H240ar, H240nr, H240, H241, H244br, P240nr, P244br, P246br, P440ar, P440, P441, P542D, P741m, P840, P840ar, and P841 6.60 (cp037669) / 7.00 (cp039995) 
# N?A
# Online ROM Flash for Windows x64 - Advanced Power Capping Microcontroller Firmware for HPE Gen9 Servers 1.0.9(I) (cp037781) / dtto

#############################################################################   
$SupBIOSCodes = "I31", "P70", "P71", "I36", "P89", "P86", "U17", "U32", "U30", "P67", "U14", "U20"
$SupBIOSGen   = "G8",  "G8",  "G8",  "G9",  "G9",  "G9",  "G9",  "G10", "G10", "G7", "G9", "G9"
$SupBIOSDescr = "BL460c", "DL380p", "DL360p", "BL460c", "DL360", "DL120", "DL580", "DL360", "DL380", "DL380", "XL170r", "DL160/180"

#############################################################################    OS/HW support matrix to load $OSHWCPArr from
$VoidPArr = @(("x","x"),("x","x"),("x","x"),("x","x"),("D","D"))
$HWOSMatrixArr  = @(
            ( [ref] $I31W2008R2, [ref] $I31W2012, [ref] $I31W2012R2, [ref] $I31W2016),  # G8 - I31   
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P70W2012R2, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P71W2012R2, [ref] $VoidPArr),
            ( [ref] $I36W2008R2, [ref] $I36W2012, [ref] $I36W2012R2, [ref] $I36W2016),  #G9 - I36
            ( [ref] $P89W2008R2, [ref] $P89W2012, [ref] $P89W2012R2, [ref] $P89W2016),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P86W2012R2, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $U17W2012, [ref] $VoidPArr, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U32W2012R2, [ref] $U32W2016),  # G10 - U32 
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U30W2012R2, [ref] $U30W2016),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P67W2012R2, [ref] $VoidPArr),   # G7 - P67
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U14W2012R2, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U20W2012R2, [ref] $VoidPArr)
            )
$HWOSMatrixArrDev  = @(
            ( [ref] $I31W2008R2Dev, [ref] $I31W2012Dev, [ref] $I31W2012R2Dev, [ref] $I31W2016Dev),  # G8 - I31   
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P70W2012R2Dev, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P71W2012R2Dev, [ref] $VoidPArr),
            ( [ref] $I36W2008R2Dev, [ref] $I36W2012Dev, [ref] $I36W2012R2Dev, [ref] $I36W2016Dev),  #G9 - I36
            ( [ref] $P89W2008R2Dev, [ref] $P89W2012Dev, [ref] $P89W2012R2Dev, [ref] $P89W2016Dev),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P86W2012R2Dev, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $U17W2012Dev, [ref] $VoidPArr, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U32W2012R2Dev, [ref] $U32W2016Dev),  # G10 - U32 
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U30W2012R2Dev, [ref] $U30W2016Dev),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $P67W2012R2Dev, [ref] $VoidPArr),   # G7 - P67
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U14W2012R2Dev, [ref] $VoidPArr),
            ( [ref] $VoidPArr, [ref] $VoidPArr, [ref] $U20W2012R2Dev, [ref] $VoidPArr)
            )
$HWOSSPPNotesArr  = @( # [SPP,HW,OS]
    (       ( "EOS", "ok", "ok", ""),  # G8 - I31   
            ( "EOS", "", "ok", ""),
            ( "", "", "SUT", ""),
            ( "EOS", "ok", "ok", ""),  #G9 - I36
            ( "EOS", "", "drv only", ""),
            ( "EOS", "", "", ""),
            ( "EOS", "", "", ""),
            ( "", "", "", ""),  # G10 - U32 
            ( "", "", "", ""),
            ( "", "", "EOS", ""),   # G7 - P67
            ( "", "", "", ""),
            ( "", "", "", "")
    ),(     ( "+SUT", "", "", ""),  # G8 - I31   
            ( "", "", "ok", ""),
            ( "", "", "201907 Gen8.15", ""),
            ( "", "ok", "ok", "ok"),  #G9 - I36
            ( "", "", "drv only", "ok"),
            ( "", "", "ok", ""),
            ( "", "", "", ""),
            ( "", "", "", ""),  # G10 - U32 
            ( "", "", "drv only", "ok"),
            ( "", "", "!!! as 201510", ""),   # G7 - P67
            ( "", "", "", ""), #U14 - 3Par v3
            ( "", "", "", "")
    ),(     ( "", "", "", ""),  # G8 - I31   
            ( "", "", "", ""),
            ( "", "", "", ""),
            ( "", "ok", "ok", "ok"),  #G9 - I36
            ( "", "", "", "ok"),
            ( "", "", "ok", ""),
            ( "", "", "", ""),
            ( "", "", "", "ok"),  # G10 - U32 
            ( "", "", "ok", "ok"),
            ( "", "", "", "") ,  # G7 - P67
            ( "", "", "ok", ""),
            ( "", "", "limited", "")
    ),(     ( "", "", "", ""),  # G8 - I31   
            ( "", "", "", ""),
            ( "", "", "", ""),
            ( "", "", "", ""),  #G9 - I36
            ( "", "", "", ""),
            ( "", "", "", ""),
            ( "", "", "", ""),
            ( "", "", "", "202003"),  # G10 - U32 
            ( "", "", "hotfixed202003", "hotfixed202003"),
            ( "", "", "", ""),   # G7 - P67
            ( "", "", "", ""),
            ( "", "", "", "")
    )
)
############################
$SilSetArr = @(
            ("{ED307498-1209-4B2A-ABF7-D6A3A8C7B992}","HP-{85171634-98E9-47E5-9E56-96BBC7FE1715}", "HP-{15EC9FFF-3B11-4F2A-92F8-F63F33F64B31}", "{3D99D1D6-9479-419B-A5E4-D1470755E856}",
             "{D467972B-5987-4859-883A-B55C1FCD9B54}", "{F3EB2FEB-3D29-449F-B50A-1093C9C19150}", "{471658B0-C43D-407A-B06E-0252124D12BE}", "HP-{EDE88CBB-3384-4DDA-B23B-7E54A3F4344F}", "HP-{94ECEBAA-D82C-4D3C-BA43-A21C697CEBBB}", ""), # end by empty one     
            ("ILO4_CHIF 4.0.0.0","ILO4_CHIF 4.0/3.30 HP", "ILO4_MGMT 4.0/3.30 HP", "NVMeNMIFix 1.1.0.0",
             "ILO4_CHIF 3.30.0.0", "PCHNMIFix 1.1.0.0", "NVMeNMIFix 1.0.5.0", "AMS G9", "AMS G10", "")
            )
# HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\    
#############################################################################         Setup window 160x60    
Clear-Host 
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
  # Relaunch as an elevated process:
  Start-Process powershell.exe "-File",('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
  Write-Host "SpeedUPD must run as Admin - child process launched" -ForegroundColor Yellow
  Start-Sleep -Seconds 10
  exit
}
# Now running elevated 
$console = $host.UI.RawUI
$buffer = $console.BufferSize
$buffer.Width = 146
$buffer.Height = 2000
$console.BufferSize = $buffer
$size = $console.WindowSize
$size.Width = 146
$size.Height = 76
$console.WindowSize = $size
##################################    #.\start [SPPXyz] [-f] [-h|-?]
$RootFldr = "C:\cpqsystem"
$TInstFldr = "C:\compaq"
If ($args.count -gt 0) { 
    For ($iii=0; $iii -lt $args.count; $iii++) {
        $XTemp = $args[$iii].ToString()
        If ($XTemp.Substring(0,1) -eq "-") {
            If ($XTemp.ToUpper() -eq "-F") { $ActionForce = 1 }
            If ($XTemp.ToUpper() -eq "-R") { $ActionReduce = 1 }
            If (($XTemp.ToUpper() -eq "-H") -OR ($XTemp -eq "-?")) { $ActionHelp = 1 }
        } else {
            $SPPSpecified = $XTemp
            $SUSRunAuto = 1
        }
    }
}
############################################################################# Get basic info - HW, OS
$MySession =  $env:SESSIONNAME 
$MyCwd=(Get-Location).path
$MyOSName = (Get-WmiObject Win32_OperatingSystem).Name
$MyBIOSVer = (Get-WmiObject win32_bios).SMBIOSBIOSVersion
$MyBIOSMan = (Get-WmiObject win32_bios).Manufacturer
$MyBIOSMaj = (Get-WmiObject win32_bios).SMBIOSMajorVersion
$MyBIOSMin = (Get-WmiObject win32_bios).SMBIOSMinorVersion
$MyBIOSDate = (Get-WmiObject win32_bios).ReleaseDate.Substring(0,8)
$GotSupBIOSIdx = 999
For ($iii=0; $iii -lt $SupBIOSCodes.length; $iii++) {
    If ($MyBIOSVer -eq $SupBIOSCodes[$iii]) { $GotSupBIOSIdx = $iii }
}
$OSIDPos = $MyOSName.Indexof(' 2')
$MyOSID = ""
if ($MyOSName.Substring($OSIDPos,8) -eq " 2012 R2") { 
    $MyOSID = "W2012R2"
    $MyOSIdx = 2 }
if ($MyOSName.Substring($OSIDPos,8) -eq " 2008 R2") { 
    $MyOSID = "W2008R2"
    $MyOSIdx = 0 }
if (($MyOSName.Substring($OSIDPos,5) -eq " 2012") -and ($MyOSID -eq "")) { 
    $MyOSID = "W2012" 
    $MyOSIdx = 1 }
if (($MyOSName.Substring($OSIDPos,5) -eq " 2016") -and ($MyOSID -eq "")) { 
    $MyOSID = "W2016"
    $MyOSIdx = 3 }
If ($GotSupBIOSIdx -ne 999) {
    switch ($SupBIOSGen[$GotSupBIOSIdx]) {
        "G7" { $HPEGen789Idx = 0 } 
        "G8" { $HPEGen789Idx = 1 } 
        "G9" { $HPEGen789Idx = 2 } 
        "G10" { $HPEGen789Idx = 3 }         
    }
}
############################################################################# Welcome...
Write-Host "---------------------------------------------------------------------              " "`r" -ForegroundColor Black -BackgroundColor Cyan
Write-Host "IBM CZ / CIC Brno HPE HW Team SW                                                   " "`r" -ForegroundColor Black -BackgroundColor Cyan
Write-Host "---------------------------------------------------------------------              " "`r" -ForegroundColor Black -BackgroundColor Cyan  
If ($ActionHelp -ne 1) {
    If ($GotSupBIOSIdx -eq 999) {
        Write-Host "ERROR: HW Not Supported (" $MyBIOSVer "), Supporting:" "`r" -ForegroundColor Yellow -BackgroundColor Red
        For ($iii=0; $iii -lt $SupBIOSCodes.length; $iii++) { Write-Host $SupBIOSDescr[$iii] $SupBIOSGen[$iii] " - " $SupBIOSCodes[$iii] "`r" -ForegroundColor Yellow }
        $ActionHelp = 1
    }
    If ($MyOSID -eq "") {
        Write-Host "ERROR: OS Not Supported (" $MyOSName "), Supporting:" "`r" -ForegroundColor Yellow -BackgroundColor Red
        Write-Host "2008 R2, 2012, 2012 R2 and 2016" "`r" -ForegroundColor Yellow
        $ActionHelp = 1
    }
}
$TabChar = [char]9  
If ($ActionHelp -eq 1) {        # No action if unsupported OR help requested
        Write-Host "Supporting SPP levels:" "`r" -ForegroundColor White
        For ($iii=0; $iii -lt $SPPLevels; $iii++) { 
            $TmpHdrSX = $TabChar+$TabChar+$TabChar+"2008R2"+$TabChar+"2012"+$TabChar+"2012R2"+$TabChar+"2016 -------------------------------"
            Write-Host $SPPNamesArr[$iii] $TmpHdrSX "`r" -ForegroundColor Yellow 
            For ($jjj=0; $jjj -lt $SupBIOSCodes.length; $jjj++) { 
                Write-Host $SupBIOSCodes[$jjj] "(" $SupBIOSDescr[$jjj] $SupBIOSGen[$jjj] ")" $TabChar -NoNewline -ForegroundColor Gray 
                For ($kkk=0; $kkk -lt 4; $kkk++) { #~$MyOSIdx
                    $OSHWCPArrTmp = $HWOSMatrixArr[$jjj][$kkk].Value
                    If ($OSHWCPArrTmp[$iii][0].Length -lt 2) {
                        Write-Host "x" $TabChar -NoNewline -ForegroundColor DarkGray
                    } else {
                        $OSHWCPArrTmpDev = $HWOSMatrixArrDev[$jjj][$kkk].Value
                        $HWDevTmpSample = $OSHWCPArrTmpDev[0][0]
                        If ($HWDevTmpSample.Length -gt 1) { $HWDevTmpSample = $HWDevTmpSample.Substring(0,1) }
                        If (($HWDevTmpSample -eq "_") -OR ($HWDevTmpSample -eq "x")) {
                            Write-Host "ok" $TabChar -NoNewline -ForegroundColor Green 
                        } else {
                            Write-Host "?" $TabChar -NoNewline -ForegroundColor Red
                        }
                    }
                }
                Write-Host "`r"
            }
        }
        Write-Host "Syntax:        .\start [-h|-?] | [SPP] [-f] [-r]                  " "`r" -ForegroundColor White
        Write-Host "-h, -?         Display this help screen                            " "`r" -ForegroundColor Yellow
        Write-Host "SPP            Specify SPP to run in automated mode                " "`r" -ForegroundColor Yellow
        Write-Host "-f             Force installation of PCI devices from RDP session  " "`r" -ForegroundColor Yellow
        Write-Host "-r             Reduced (will skip all management agents)           " "`r" -ForegroundColor Yellow
} else {
############################################################################## GO GO GO
Write-Host "Folder pre-set ..." "`r"
FldrPreSet $RootFldr
$colDisksX = Get-WMIObject Win32_Logicaldisk -filter "deviceid='C:'" 
foreach ($diskX in $colDisksX) {
    if ($diskX.size -gt 0) {
    $diskXY = $diskX.freespace / 1024000999
        If ($diskXY -lt 20) {
            Write-Host "Warning: C: free space below 20GB!!! (" $diskXY ")`r" -ForegroundColor Red -BackgroundColor Yellow
        }
    }
}
$xAMSService = Get-Service -Name "hpqams" -ErrorAction SilentlyContinue
if ($xAMSService.Status -ne "Running") {
    $xAMSService10 = Get-Service -Name "ams" -ErrorAction SilentlyContinue
    if ($xAMSService10.Status -ne "Running") {
        Write-Host "Warning: AMS not running!" "`r" -ForegroundColor Red -BackgroundColor Yellow
    }
}
Start-Transcript $RootFldr\hpehw\sus$(get-date -uformat %y%m%d%H%M).log
$OSWMIc = Get-WmiObject Win32_OperatingSystem
$LastBootUpA= $OSWMIc.ConvertToDateTime($OSWMIc.LastBootUpTime)
Write-Host ("Last boot:   " + $LastBootUpA)
$LModFile = $RootFldr + "\log\cpqsetup.log"
If (Test-Path -Path $LModFile) {
    $lastModifiedDate = (Get-Item $LModFile).LastWriteTime
    If ($lastModifiedDate -ge $LastBootUpA) {
        Write-Host "Last update: " $lastModifiedDate "`r" -ForegroundColor Red -BackgroundColor Yellow
    } else {
        Write-Host "Last update: " $lastModifiedDate
    }
} else {
    Write-Host "Last update: unknown"
}
############################################################################## get System Info 
# Chk for HPE SUT 1.6.5 and remove (cp029625) -----------------------------------------------------
    $ThisRP = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{DF7C9FAA-09AD-4F95-A1B9-4ED1B7B8AB3D}"
    If (Test-Path -Path $ThisRP) {
        Write-Host "Warning: Found obsolete HPSUT 1.6.5 (HPSUTService), starting removal ..." "`r" -ForegroundColor Yellow 
        $ThisCPPath = "MsiExec.exe"
        $ThisCPArgs = "/X" + "{DF7C9FAA-09AD-4F95-A1B9-4ED1B7B8AB3D}" + " /quiet /norestart"
        $CPprocess = (Start-Process -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
        Start-Sleep -s 3
        If (Test-Path -Path $ThisRP) {
            Write-Host "Error: HPSUT 1.6.5 could not be removed. Please uninstall before continuing." "`r" -ForegroundColor Red
        } else { 
            Write-Host "HPSUT 1.6.5 has been removed" "`r" -ForegroundColor Green
        }
    }
# Chk for current SUT -----------------------------------------------------------------------------
$SUTVer = ""
$SUTSilent = 0
$MySUTCodesArr = $SUTCodesArrOSRef[$MyOSIdx].Value
For ($iii=0; $iii -lt $SPPLevels; $iii++) {
    $ThisCP = $MySUTCodesArr[$HPEGen789Idx][0][$iii]
    If (($ThisCP.Length -gt 1) -AND ($SUTVer -eq "")) {
        $ThisRP = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + $ThisCP
        If (Test-Path -Path $ThisRP) {
            $SUTVer = $MySUTCodesArr[$HPEGen789Idx][1][$iii]
            $SUTVerSPPIdx = $iii
            $Key1 = $null
            $Key1 = Get-ItemProperty -Path $ThisRP -Name SystemComponent -EA SilentlyContinue |% {$_.SystemComponent}
            If ($Key1 -eq 1) { $SUTSilent = 1 }  
           
        }
    }
}
Write-Host "---------------------------------------------------------------------" "`r"
Write-Host $MySession "`r"
Write-Host "OS Supported:" $MyOSID "(" $MyOSIdx ")" "`r"
Write-Host "HW Supported:" $SupBIOSCodes[$GotSupBIOSIdx] $SupBIOSDescr[$GotSupBIOSIdx] $SupBIOSGen[$GotSupBIOSIdx] "(" $GotSupBIOSIdx ")" "`r"
If ($SUTVer -eq "") {
        Write-Host "Currently Assumed SUT level: unknown / none" "`r"
} else {
     If ($SUTSilent -eq 1) {
        Write-Host "Currently Assumed SUT level: " $SUTVerSPPIdx " - " $SUTVer " - ok" "`r" -ForegroundColor Green
     } else {
        Write-Host "Currently Assumed SUT level: " $SUTVerSPPIdx " - " $SUTVer " - not configured" "`r" -ForegroundColor Yellow -BackgroundColor DarkRed
     }
}    
############################################################################## Evaluate support matrix and/or select SPP
$OSHWCPArr = $HWOSMatrixArr[$GotSupBIOSIdx][$MyOSIdx].Value
$OSHWCPArrDev = $HWOSMatrixArrDev[$GotSupBIOSIdx][$MyOSIdx].Value
If ($SPPSpecified.Length -gt 1 ) { 
    $TargetSPPLevel = 999
    For ($iii=0; $iii -lt $SPPLevels; $iii++) { 
        If ($SPPNamesArr[$iii] -eq $SPPSpecified) { $TargetSPPLevel = $iii }
    }
    If ($TargetSPPLevel -ge $SPPLevels) { 
            Write-Host "ERROR: SPP not specified or invalid (" $SPPSpecified ")" "`r" -ForegroundColor Yellow -BackgroundColor Red
            Write-Host "Leaving script ..."
            Start-Sleep -s 30        
            Exit 1
    }
    If ($OSHWCPArr[$TargetSPPLevel][0].Length -lt 2) {
        Write-Host "ERROR: SPP " $SPPSpecified " is not supported for this HW and OS combination" "`r" -ForegroundColor Yellow -BackgroundColor Red
    } else {
        Write-Host "*** Automated update, SPP specified " $SPPSpecified " is supported *** `r" -ForegroundColor Green -BackgroundColor Black
    }
} else { #SPP not spefified - run dialog for selection
    Write-Host "---------------------------------------------------------------------"
    $TargetSPPLevel = 0
    For ($iii=0; $iii -lt $SPPLevels; $iii++) { 
        If ($OSHWCPArr[$iii][0].Length -lt 2) {
            Write-Host $iii $SPPNamesArr[$iii] " N/A `r" -ForegroundColor DarkGray 
        } else {
            $TargetSPPLevel = $iii
            $XNote = $HWOSSPPNotesArr[$iii][$GotSupBIOSIdx][$MyOSIdx]
            $XSUTavailable = $MySUTCodesArr[$HPEGen789Idx][1][$iii]            
            If ($XNote.Length -gt 1) {
                Write-Host $iii $SPPNamesArr[$iii] $XSUTavailable $XNote "`r" -ForegroundColor Green
            } else {
                Write-Host $iii $SPPNamesArr[$iii] $XSUTavailable "? `r" -ForegroundColor Green
            }
        }
    }   
    Write-Host "---------------------------------------------------------------------"
    $MyPrompt = "Please select target SPP level (0/1/2/3/X/ ["+$TargetSPPLevel+"] )"   
    $myvoid = read-host -Prompt $MyPrompt 
    If ($myvoid -ne "") {
        If (($myvoid -ge 0) -AND ($myvoid -lt $SPPLevels)) {
            $TargetSPPLevel = $myvoid -as [int]
        } else {
            Write-Host "ERROR: SPP not specified or invalid (" $myvoid ")" "`r" -ForegroundColor Red -BackgroundColor Yellow
            Write-Host "Leaving script ..."
            Start-Sleep -s 30        
            Exit 2
        }
    }
    $SPPSpecified = $SPPNamesArr[$TargetSPPLevel]   
}
Write-Host "SPP selected:" $SPPSpecified " (" $TargetSPPLevel ")" "`r"   

############################################################################## Get Devices Info
$DevsArray = @()
$DevsArrayVer = @()
$CPToInstallArray = @()
$HKLM = 2147483650
$regStd = [wmiclass]"\\.\root\default:StdRegprov"
$keyL1 = "SYSTEM\CurrentControlSet\Control\Class"
$subkeysL1 = $regStd.EnumKey($HKLM, $keyL1)
Foreach ($ThisL1Key in ($subkeysL1.sNames)) {
    $keyL2 = $keyL1 + "\" + $ThisL1Key
    $subkeysL2 = $regStd.EnumKey($HKLM, $keyL2)    
    Foreach ($ThisL2Key in ($subkeysL2.sNames)) {
        If ($ThisL2Key -ne "Properties") {
            $keyL3 = $keyL2 + "\" + $ThisL2Key
            $DDValue = ""
            $DDVersion = ""
            $DDValue = ($regStd.GetStringValue($HKLM, $keyL3, "DriverDesc")).svalue  ## REG_SZ
    	 	switch($DDValue) {
                "Emulex FCoE HBA - Storport Miniport Driver" { $HBADType = "EX554FLB" }
                {$_ -eq "HP 630FLB FCoE Device" -or $_ -eq "HPE 630FLB FCoE Device" -or $_ -eq "HP FlexFabric 20Gb 2-port 630FLB Adapter" } { $HBADType = "QL630FLB" }
                "QLogic Fibre Channel Adapter" { $HBADType = "QLOGCFCA" }
                "HP NC382i DP Multifunction Gigabit Server Adapter" { $HBADType = "NC382i" }
			    "Emulex LightPulse HBA - Storport Miniport Driver" { $HBADType = "EXLTPFCA" }
                "Smart Array P440ar Controller"  { $HBADType = "P440AR" }
                "Smart Array P420i Controller" { $HBADType = "P420i" } 
                "Smart Array P440 Controller" { $HBADType = "P440" } 
                "HPE Smart Array P816i-a SR Gen10"  { $HBADType = "P816i" }
                "HPE Smart Array P408i-a SR Gen10"  { $HBADType = "P408i" } 
                "Smart Array P410i Controller"  { $HBADType = "P410i" } 

                "HPE Smart Array S100i SR Gen10 SW RAID"  { $HBADType = "S100i" } 
                "Dynamic Smart Array B140i" { $HBADType = "B140i" }  
                {$_ -eq "AVAGO MegaRAID SAS Adapter" -or $_ -eq "HPE Smart Array p824i-p MR Gen10 Controller" } { $HBADType = "P824I-P" }
    
                {$_ -eq "HP Ethernet 10Gb 2-port 560FLR-SFP+ Adapter" -or $_ -eq "HPE Ethernet 10Gb 2-port 560SFP+ Adapter" -or $_ -eq "HP Ethernet 10Gb 2-port 560SFP+ Adapter" -or $_ -eq "Intel(R) 82599 10 Gigabit Dual Port Network Connection" } { $HBADType = "560SFP" }
                {$_ -eq "HP Ethernet 1Gb 4-port 331i Adapter" -or $_ -eq "HPE Ethernet 1Gb 4-port 331i Adapter" -or $_ -eq "Broadcom NetXtreme Gigabit Ethernet" } { $HBADType = "331i" }  #Broadcom - from WinInst
                {$_ -eq "HP Ethernet 1Gb 4-port 331FLR Adapter" -or $_ -eq "HPE Ethernet 1Gb 4-port 331FLR Adapter" } { $HBADType = "331FLR" }   
                {$_ -eq "HP Ethernet 1Gb 4-port 331T Adapter" -or $_ -eq "HPE Ethernet 1Gb 4-port 331T Adapter" } { $HBADType = "331T" }   
                {$_ -eq "HP Ethernet 1Gb 2-port 361i Adapter" -or $_ -eq "HPE Ethernet 1Gb 2-port 361i Adapter" } { $HBADType = "361i" } 

                {$_ -eq "HPE Ethernet 10Gb 562SFP+ Adapter" -or $_ -eq "Hxxxxx" -or $_ -eq "HP xx" } { $HBADType = "562SFP" }
                {$_ -eq "HPE SN1100Q 16Gb 2p FC HBA" -or $_ -eq "Hxxxxx" -or $_ -eq "HP xx" } { $HBADType = "SN1100Q" }     
                           
                default {$HBADType = ""}
            }
            If ($HBADType -ne "") {
                $DDVersion = ($regStd.GetStringValue($HKLM, $keyL3, "DriverVersion")).svalue  ## REG_SZ
                $CurDevPresent = 0
                If ($DevsArray.length -gt 0) {
                    For ($iii=0; $iii -lt $DevsArray.length; $iii++) {
                        If ($DevsArray[$iii] -eq $HBADType) { $CurDevPresent = 1 }
                    }
                }
                If ($CurDevPresent -eq 0) {
                    $DevsArray += $HBADType
                    $DevsArrayVer += $DDVersion				
                }
            }
        }
   }
}
# Count MPIO 3Par disks / add 3Par Dev
$3PARdataVVCnt = 0
$keyL1 = "SYSTEM\CurrentControlSet\Enum\MPIO"
$subkeysL1 = $regStd.EnumKey($HKLM, $keyL1)
Foreach ($ThisL1Key in ($subkeysL1.sNames)) {
    $keyL2 = $keyL1 + "\" + $ThisL1Key
    $subkeysL2 = $regStd.EnumKey($HKLM, $keyL2)    
    Foreach ($ThisL2Key in ($subkeysL2.sNames)) {
        $keyL3 = $keyL2 + "\" + $ThisL2Key
        $DDValue = ""
        $DDVersion = ""
        $DDValue = ($regStd.GetStringValue($HKLM, $keyL3, "FriendlyName")).svalue  ## REG_SZ / 3PARdata VV  Multi-Path Disk Device
        If ($DDValue.SubString(0,11) -eq "3PARdata VV") { $3PARdataVVCnt++ }
   }
}
If ($3PARdataVVCnt -gt 0) {
    $DevsArray += "3Par"
    $DevsArrayVer += $3PARdataVVCnt.ToString()
}
############################################################################## Show System Info and validate it
Write-Host "-------------------- PCI Devices ------------------------------------" "`r"
If ($DevsArray.length -gt 0) {
    For ($iii=0; $iii -lt $DevsArray.length; $iii++) {
        Write-Host $DevsArray[$iii] $DevsArrayVer[$iii] "`r" 
        # faulty: ProLiant Smart Array HPCISSS3 Controller Driver for 64-bit Microsoft Windows Server 2012/2016 Editions 100.18.2.64 (cp032118) 
        If ($DevsArrayVer[$iii] -eq "100.18.2.64") { Write-Host "!!! Alarm: Driver 100.18.2.64 fails with BSOD. Dont update SARC FW !!!" "`r" -ForegroundColor Yellow -BackgroundColor Red } 
    }
}
# 3PI 1.7 chk agains 3Par devs
    # $3PIPath = "C:\Program Files (x86)\3PAR\HP 3PARInfo\HP3PARInfo.exe"
    $3PIPath = "C:\Program Files (x86)\3PAR\HPE 3PARInfo\HP3PARInfo.exe"   
    If ((Test-Path $3PIPath) -AND ($3PARdataVVCnt -eq 0)) {
        Write-Host "!!! Alarm: Found 3ParInfo 1.7, but no devices detected. Please check manually !!!" "`r" -ForegroundColor Yellow -BackgroundColor Red
    }
Write-Host "---------------------------------------------------------------------" "`r"
If ($OSHWCPArr[$TargetSPPLevel][0].Length -lt 2) {
    Write-Host "ERROR: OS and HW and SPP Combination Is Not Supported" "`r" -ForegroundColor Red -BackgroundColor Yellow
    Write-Host "Leaving script ..."
    Start-Sleep -s 30
    Exit 1
}
If ($MySession -ne "Console") { 
    If ($ActionForce -ne 1) {
        Write-Host "WARNING: Session is not console, some PCI devices will be skipped !!!" "`r" -ForegroundColor Red -BackgroundColor White 
    } else {
        Write-Host "WARNING: Session is not console, but FORCE specified. Network device disconnection will be recovered by automated reboot!!!" "`r" -ForegroundColor Yellow -BackgroundColor Red
    }
}
If ($ActionReduce -eq 1) { Write-Host "WARNING: -R management option set, AMS and SUT installation will be skipped !!!" "`r" -ForegroundColor Red -BackgroundColor White  } 
Write-Host "---------------------------------------------------------------------" "`r"
############################################################################## Generate package list
For ($iii=0; $iii -lt 32; $iii++) {
    $ThisCP = $OSHWCPArr[$TargetSPPLevel][$iii]
    If ($ThisCP.Length -ge 2) {
        If ($ThisCP.Contains(".msi")) {
            GetMisFile $SupBIOSGen[$GotSupBIOSIdx] $ThisCP
            $ThisCPPath = ".\"+$SupBIOSGen[$GotSupBIOSIdx]+"\"+$ThisCP                
        } else {
            $ThisCPFile = $ThisCP+".exe"
            $ThisCPPath = ".\"+$SupBIOSGen[$GotSupBIOSIdx]+"\"+$ThisCPFile
            GetMisFile $SupBIOSGen[$GotSupBIOSIdx] $ThisCPFile            
        }        
        If (Test-Path $ThisCPPath) {
            $CPFileDescriptionInfo = (Get-ItemProperty $ThisCPPath).VersionInfo.FileDescription
            $CPFileVersionInfo = (Get-ItemProperty $ThisCPPath).VersionInfo.FileVersion
            If (($ActionReduce -eq 1) -AND ($CPFileDescriptionInfo -like "*Agentless*")) {
                Write-Host "Skipped: " $ThisCP $CPFileVersionInfo $CPFileDescriptionInfo "`r" -ForegroundColor DarkGray
            } else {
                Write-Host $ThisCP $CPFileVersionInfo $CPFileDescriptionInfo "`r"
                $CPToInstallArray += $ThisCP
            }
        } else {
            Write-Host $ThisCPPath "not found!" "`r" -ForegroundColor Red -BackgroundColor Yellow
        }
    }
}
Write-Host "---------------------------------------------------------------------" "`r"
If ($DevsArray.length -gt 0) { # List ForEach Device Found
    For ($iii=0; $iii -lt $DevsArray.length; $iii++) {
        For ($jjj=0; $jjj -lt 32; $jjj++) {
          If ($OSHWCPArrDev[0][$jjj].Length -gt 2) {
            $ThisDevForced = $OSHWCPArrDev[0][$jjj].substring(0,1)
            $ThisDev = $OSHWCPArrDev[0][$jjj].substring(1)  
            $ThisDevCP = ""          
            If ($ThisDev -eq $DevsArray[$iii]) {
                $ThisDevCP = $OSHWCPArrDev[$TargetSPPLevel+1][$jjj]
                If ($ThisDevCP.Length -gt 2) {
                    If ($ThisDevCP.Contains(".msi")) {
                        $ThisCPFile = $ThisDevCP
                    } else {
                        $ThisCPFile = $ThisDevCP+".exe"
                    }
                    $ThisCPPath = ".\"+$SupBIOSGen[$GotSupBIOSIdx]+"\"+$ThisCPFile
                    GetMisFile $SupBIOSGen[$GotSupBIOSIdx] $ThisCPFile
                    If (Test-Path $ThisCPPath) {
                        $CPFileDescriptionInfo = (Get-ItemProperty $ThisCPPath).VersionInfo.FileDescription
                        $CPFileVersionInfo = (Get-ItemProperty $ThisCPPath).VersionInfo.FileVersion
                        If (($MySession -eq "Console") -OR ($ActionForce -eq 1) -OR ($ThisDevForced -eq "_")) {
                            Write-Host $DevsArray[$iii] $ThisDevCP $CPFileVersionInfo $CPFileDescriptionInfo "`r"
                            $CPToInstallArray += $ThisDevCP
                        } else {
                            Write-Host "Skipped: "$DevsArray[$iii] $ThisDevCP $CPFileVersionInfo $CPFileDescriptionInfo "`r" -ForegroundColor DarkGray
                        }
                    } else {
                        Write-Host $DevsArray[$iii] $ThisDevCP "not found!" "`r" -ForegroundColor Red -BackgroundColor Yellow
                    }
                } else {
                    Write-Host $DevsArray[$iii] "Package not defined !!!" "`r" -ForegroundColor Red -BackgroundColor Yellow
                }
            }
          }
        }
    }
}
Write-Host "---------------------------------------------------------------------" "`r"
############################################################################## GO, confirm if interractive 
If ($SUSRunAuto -ne 1) { $myvoid = read-host "Press Enter to start installation" } #

If (!(Test-Path $TInstFldr)) {
        New-Item -Path $TInstFldr -ItemType "directory" | Out-Null
}        

If ($ActionForce -eq 1) {
    Start-Sleep -s 1
    If (Test-Connection (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop) -Quiet -Count 1) {
        Write-host "- FORCED - Gateway pingable, scheduling OS reboot after 30 minutes ..." "`r" -ForegroundColor Yellow
        $sdwncmd = 'shutdown -r -t 1800 -c "OS reboot scheduled after 30 minutes to safeguard devices recognition or update. It should be aborted soon."'
        iex $sdwncmd
    } else {
        Write-host "- FORCED - Gateway NOT pingable. Action cannot continue safely!" "`r" -ForegroundColor Red -BackgroundColor Yellow
        Write-Host "Leaving script ..."
        Start-Sleep -s 60        
        Exit 2
    }
}

Write-Host "Installation Progress ..." "`r"
For ($iii=0; $iii -lt $CPToInstallArray.length; $iii++) {
    $ThisCP = $CPToInstallArray[$iii]
    If ($ThisCP.Contains(".msi")) {
                $ThisCPPath = "msiexec"
                    $CpySrc9 = $MyCwd+"\"+$SupBIOSGen[$GotSupBIOSIdx]+"\"+$ThisCP
                    $CpyDst9 = $TInstFldr+"\"+$ThisCP
                    Copy-Item $CpySrc9 -Destination $CpyDst9
                $ThisCPArgs = "-i "+$CpyDst9+" /quiet /norestart" 
                $CPprocess = (Start-Process -Verb runAs -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
    } else {
                $ThisCPArgs = "/s"
                    $CpySrc9 = $MyCwd+"\"+$SupBIOSGen[$GotSupBIOSIdx]+"\"+$ThisCP+".exe"
                    $CpyDst9 = $TInstFldr+"\"+$ThisCP+".exe"
                    Copy-Item $CpySrc9 -Destination $CpyDst9
                $CPprocess = (Start-Process -FilePath $CpyDst9 -ArgumentList $ThisCPArgs -PassThru -Wait)
    }
    switch ($CPprocess.ExitCode){
        0 { $ErrMsg = '0 Success'} 
        1 { $ErrMsg = '1 Skipped (already up to date)?'}
        2 { $ErrMsg = '2 installed ?'}
        3 { $ErrMsg = '3 Skipped (already installed)'}
        default { $ErrMsg = $CPprocess.ExitCode } 
    }
    Write-Host $ThisCP $ErrMsg
    Start-Sleep -m 100
}

If ($ActionForce -eq 1) {
    Start-Sleep -s 10
    If (!(Test-Connection (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop) -Quiet -Count 1)) {
        Write-host "- FORCED - Gateway NOT pingable. Trying to bring interfaces up ..." "`r" -ForegroundColor Red -BackgroundColor Yellow 
        Get-NetAdapter | Enable-NetAdapter
        Start-Sleep -s 15
    }
    If (Test-Connection (Get-NetRoute -DestinationPrefix 0.0.0.0/0 | Select-Object -ExpandProperty Nexthop) -Quiet -Count 1) {
        Write-host "- FORCED - Gateway is pingable. Aborting scheduled OS reboot ..." "`r" -ForegroundColor Yellow
        $sdwncmd = 'shutdown -a'
        iex $sdwncmd
    } else {
        Write-host "- FORCED - Gateway NOT pingable. System reboot remains scheduled!!!" "`r" -ForegroundColor Red -BackgroundColor Yellow                   
    }
}

Write-Host "---------------------------------------------------------------------" "`r"
Start-Sleep -s 3
Write-Host "Installation finished. Performing cleanup ..." "`r"
Write-Host "Removing menu and MSI items" "`r"
FFileDirIfEmptyRemove "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\HPE 3PAR" "HPE 3PARInfo 1.7.lnk"
FFileDirIfEmptyRemove "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\HPE Management Agents" "HPE System Management Homepage.lnk"
FFileDirIfEmptyRemove "C:\Intel\Logs" "IntelUSB3.log"
FEmptyDirRemove "C:\Intel"
FDirInclContRemove "C:\SWStore\FCInfo"
FEmptyDirRemove "C:\SWStore"
FDirInclContRemove "C:\clu\log"
FEmptyDirRemove "C:\clu"
FDirInclContRemove "C:\compaq\wbem\certs"
FDirInclContRemove "C:\compaq\wbem\homepage"
If (!(Test-Path "C:\Program Files (x86)\3PAR\HP 3PARInfo\HP3PARInfo.exe")) { #if uninstalled
    FDirInclContRemove "C:\Program Files (x86)\3PAR\HP 3PARInfo"
}

$ThisPathF = "C:\hpkeyclick.exe"
If (Test-Path $ThisPathF) { Remove-Item $ThisPathF }
$ThisPathF = "C:\smh_installer.log"
If (Test-Path $ThisPathF) { Remove-Item $ThisPathF }
$ThisPathF = "C:\cpqsprt.trace"
If (Test-Path $ThisPathF) { Remove-Item $ThisPathF }
$ThisPathF = "C:\cleanup.cmd"
If (Test-Path $ThisPathF) { Remove-Item $ThisPathF }

For ($iii=0; $iii -lt 999; $iii++) {
    $ThisCP = $SilSetArr[0][$iii]
    If ($ThisCP.Length -gt 1) {
        $ThisRP = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + $ThisCP
        If (Test-Path -Path $ThisRP) {
            $Key1 = $null
            $Key1 = Get-ItemProperty -Path $ThisRP -Name SystemComponent -EA SilentlyContinue |% {$_.SystemComponent}
            If ($Key1 -eq $null) { New-ItemProperty -Path $ThisRP -Name SystemComponent -value 1 -PropertyType "DWord" | Out-Null }
            If ($Key1 -eq 0) { Set-ItemProperty -Path $ThisRP -Name SystemComponent -value 1 }
            Write-Host "..." $SilSetArr[1][$iii] "`r"
        }
    } else {
        break
    }
}

#Hide Storageworks if exists and not hidden
$SWksPath = "C:\StorageWorks"
If (Test-Path $SWksPath) {
    If (!((get-item $SWksPath -force).Attributes -match 'Hidden')) { 
        $SWfrfldr=get-item $SWksPath -Force
        $SWfrfldr.attributes="Hidden"       
    }
}

Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel\NameSpace\{4F0051E1-3471-4394-B1BA-0E909E872292}" -Recurse -ErrorAction SilentlyContinue #AMS G9 201811/201909 in Control Panel
# HKEY_LOCAL_MACHINE\SOFTWARE\Classes\CLSID\{4F0051E1-3471-4394-B1BA-0E909E872292}  G10?

# SUT Install / upgrade  -----------------------------------
$SUTForce = 0
If ($SupBIOSGen[$GotSupBIOSIdx] -eq "G7") {   # no SUT on G7
    $SNSMsg = "SUT not supported on " + $SupBIOSGen[$GotSupBIOSIdx] + " SPP " + $SPPSpecified
    Write-Host $SNSMsg "`r" -ForegroundColor DarkGray
} else {
    If ($SUTVer -ne "") { $SUTForce = 1 } # Do auto if found
    If ($SupBIOSDescr[$GotSupBIOSIdx].Substring(0,2) -eq "BL") { $SUTForce = 1 } # Do auto if blade 
    If (($SUSRunAuto -ne 1) -AND ($ActionReduce -ne 1) -AND ($SUTForce -eq 0))  { #Ask if interactive, not reduced and unclear decission
        $SUTconfirmation = Read-Host "Do you want to install SUT? (y/n)"
        if (($SUTconfirmation -eq 'y') -OR ($SUTconfirmation -eq 'Y')) { $SUTForce = 1 }
    } 
    If ($ActionReduce -eq 1) { $SUTForce = 0 } # , but do never if "-R/no agents" requested
}
If (($SUTForce -eq 0) -OR ($MySUTCodesArr[$HPEGen789Idx][0][$TargetSPPLevel].Length -le 1)) {
  Write-Host "SUT installation skipped" "`r"
} else {                     # Using $SUTVer+$SUTVerSPPIdx, $TargetSPPLevel
    If ( $SUTVer -ne "" ) {
        If ($SUTVerSPPIdx -eq $TargetSPPLevel) {
            Write-Host "SUT already installed - skipping " $SUTVer " installation" "`r"
        } elseif ($SUTVerSPPIdx -gt $TargetSPPLevel) {
            Write-Host "Higher SUT version " $SUTVer $SUTVerSPPIdx " already installed - skipping " $MySUTCodesArr[$HPEGen789Idx][1][$TargetSPPLevel] $TargetSPPLevel " installation" "`r"
        } else { # prepare for upgrade
            If ($SupBIOSGen[$GotSupBIOSIdx] -ne "G10") { 
                Write-Host "SUT found " $SUTVer " Uninstalling..." "`r"
                $ThisCPPath = "MsiExec.exe"
                $ThisCPArgs = "/X" + $MySUTCodesArr[$HPEGen789Idx][0][$SUTVerSPPIdx] + " /quiet /norestart"
                $CPprocess = (Start-Process -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
                Start-Sleep -s 10
            } else {
                Write-Host "Going to upgrade from SUT " $SUTVer " to keep G10 setup..." "`r"
            }
            $SUTVer = ""
        }
    }
    If ( $SUTVer -eq "" ) {
        Write-Host "Installing SUT " $MySUTCodesArr[$HPEGen789Idx][1][$TargetSPPLevel] "`r"
        $ThisCPFile = $MySUTCodesArr[$HPEGen789Idx][2][$TargetSPPLevel] + ".exe" 
        $ThisCPPath = ".\" + $SupBIOSGen[$GotSupBIOSIdx] + "\" + $ThisCPFile 
        GetMisFile $SupBIOSGen[$GotSupBIOSIdx] $ThisCPFile
        $ThisCPArgs = "/s"
        $CPprocess = (Start-Process -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
        $HPSumEvt = "SUT_" + $MySUTCodesArr[$HPEGen789Idx][1][$TargetSPPLevel]
        Log-HPSUMET $HPSumEvt
        Start-Sleep -s 30
    }
}
# Make target SUT silent if present ---------------------------------------- 
If (($ActionReduce -ne 1) -AND ($MySUTCodesArr[$HPEGen789Idx][0][$TargetSPPLevel].Length -gt 1)) {
    $ThisRP = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\" + $MySUTCodesArr[$HPEGen789Idx][0][$TargetSPPLevel]
    If (Test-Path -Path $ThisRP) {
        $Key1 = $null
        $Key1 = Get-ItemProperty -Path $ThisRP -Name SystemComponent -EA SilentlyContinue |% {$_.SystemComponent}
        If ($Key1 -eq $null) { New-ItemProperty -Path $ThisRP -Name SystemComponent -value 1 -PropertyType "DWord" | Out-Null }
        If ($Key1 -eq 0) { Set-ItemProperty -Path $ThisRP -Name SystemComponent -value 1 }
#   & configure it 
        $SUTConfigDo = 1
        If (($SUSRunAuto -ne 1) -AND ($SUTVer -ne "")) { #Ask/confirm config if interactive and SUT was already there
            $SUTconfirmation2 = Read-Host "Do you want to configure SUT? (y/n)"
            if (($SUTconfirmation2 -ne 'y') -AND ($SUTconfirmation2 -ne 'Y')) { $SUTConfigDo = 0 }
        }
        If ($SUTConfigDo -eq 1) {
            Write-Host "Configuring SUT ..." "`r"
            $ThisCPPath = "C:\Progra~1\SUT\bin\sut.exe"           
            If ($HPEGen789Idx -ge 2) { #G9, G10 
                Start-Sleep -s 3
                $ThisCPArgs = "/set tpmbypassflag=true" 
                Write-Host "... " $ThisCPArgs "`r"
                $CPprocess = (Start-Process -Verb runAs -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
                If (($HPEGen789Idx -ge 3) -AND ($SUSRunAuto -ne 1)) { # G10                
                    $SUTpass = Read-Host "Enter _hpuadmin password (empty to skip):"
                    If ($SUTpass.Length -gt 1) {
                        Start-Sleep -s 3
                        $ThisCPArgs = "/set ilousername=_hpuadmin ilopassword="
                        Write-Host "... " $ThisCPArgs "`r"
                        $ThisCPArgs = $ThisCPArgs  + $SUTpass # dont transcript password
                        $CPprocess = (Start-Process -Verb runAs -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait) 
                    }
                }
            }
            Start-Sleep -s 3
            $ThisCPArgs = "/set mode=AutoDeploy" 
            Write-Host "... " $ThisCPArgs "`r"
            $CPprocess = (Start-Process -Verb runAs -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
            Start-Sleep -s 20  #allow svc to start
            $ThisCPArgs = "/clearstaging" 
            Write-Host "... " $ThisCPArgs "`r"
            $CPprocess = (Start-Process -Verb runAs -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
            Start-Sleep -s 3
                $SutFldr = $RootFldr + "\SUTStage"
                $sUTdirXInfo = Get-ChildItem $SutFldr | Measure-Object #Cleanup before set
                If ($sUTdirXInfo.count -gt 0) { 
                    get-childitem -Path $SutFldr -File | foreach ($_) { remove-item $_.fullname }  
                }
            $ThisCPArgs = "/set stagingdirectory=" + $RootFldr + "\SUTstage" 
            Write-Host "... " $ThisCPArgs "`r"
            $CPprocess = (Start-Process -Verb runAs -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
            Start-Sleep -s 3
            $ThisCPArgs = "/set pollingintervalinminutes=57" 
            Write-Host "... " $ThisCPArgs "`r"
            $CPprocess = (Start-Process -Verb runAs -FilePath $ThisCPPath -ArgumentList $ThisCPArgs -PassThru -Wait)
            Start-Sleep -s 3
            Write-Host "---------------------------------------------------------------------" "`r"
            $ThisCPPath = 'C:\Progra~1\SUT\bin\sut.exe "/status"'
            Invoke-Expression $ThisCPPath
            Start-Sleep -s 10
        }
    }
}
### bye bye
Write-Host "Leaving ..." "`r"
    FDirInclContRemove $TInstFldr
    Start-Sleep -s 3
    Remove-Item -Path $TInstFldr -Recurse -ErrorAction SilentlyContinue
Write-Host "---------------------------------------------------------------------" "`r"
Stop-Transcript
# eof GO GO GO
}
Start-Sleep -s 3


