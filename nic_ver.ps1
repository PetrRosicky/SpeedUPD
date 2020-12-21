$NLBTeamToChkName = ""
$myNICInfoName = @("","")
$myNICInfoMode = @("","")

$NLBTeamObj = Get-NetLbfoTeam
Foreach ($NLBTeamItem in $NLBTeamObj) { # chk just one
    $NLBTeamToChkName = $NLBTeamItem.Name
    $NLBTeamToChkMode = $NLBTeamItem.TeamingMode
    $NLBTeamToChkAlg = $NLBTeamItem.LoadBalancingAlgorithm
    Break
}
If ($NLBTeamToChkName -eq "") {
    Write-Host "Sorry, no teaming found" -ForegroundColor Black
    exit 1
} else {
    Write-Host "Team:" $NLBTeamToChkName
    Write-Host "Mode:" $NLBTeamToChkMode
    Write-Host "Alg: " $NLBTeamToChkAlg
    $iii = 0
    $TeamMembers = Get-NetLbfoTeamMember -Team $NLBTeamToChkName
    Foreach ($TeamMember in $TeamMembers) { 
        Write-Host "- " $TeamMember.Name $TeamMember.AdministrativeMode
        $myNICInfoName[$iii] = $TeamMember.Name
        $myNICInfoMode[$iii] = $TeamMember.AdministrativeMode
        $iii++
        If ($iii -ge 2) { Break }
    }
    # validate
    If (($myNICInfoMode[0] -eq "Active") -AND ($myNICInfoMode[1] -eq "Active")) {
        Write-Host "Fatal: NIC Active-Active Mode" -ForegroundColor Red
        exit 100
    }
}