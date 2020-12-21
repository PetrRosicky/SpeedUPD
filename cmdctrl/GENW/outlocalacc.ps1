$UsrFile = "C:\hp\users.csv"
$GrpFile = "C:\hp\groups.csv"
$MemsFile = "C:\hp\grpmems.csv"


$XUsers = Get-WmiObject -Class Win32_UserAccount -Filter  "LocalAccount='True'" | Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID 
    $OutStr = "Name,Disabled"
    $OutStr
    add-content $UsrFile $OutStr
foreach ($XUser in $XUsers) {
    $OutStr = $XUser.Name + "," + $XUser.Disabled
    $OutStr
    add-content $UsrFile $OutStr
}

$Groups = Get-WmiObject -Class Win32_Group -Filter “LocalAccount=True” | Select PSComputername, Name, Status, Disabled, AccountType, Lockout, PasswordRequired, PasswordChangeable, SID
    $OutStr = "Name,Status"
    $OutStr
    add-content $GrpFile $OutStr
    add-content $MemsFile $OutStr
foreach ($item in $Groups) { 
    $OutStr = $item.Name + "," + $item.Status
    $OutStr
    add-content $GrpFile $OutStr
    If ($item.Name.Length -gt 0) {
        $Mems = Get-LocalGroupMember -Group $item.Name
        foreach ($MemsItem in $Mems.Name) {
            $OutStr = $item.Name + "," + $MemsItem
            $OutStr
            add-content $MemsFile $OutStr
        }
    }
} 


Write-host "Done"
Start-Sleep -Seconds 200