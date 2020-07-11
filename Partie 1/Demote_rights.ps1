## Script Suppression des droits admins locaux des users PRESTA10##

$group = "Administrateurs"
$groupuser = Get-ADGroupMember -Identity $group | Where {$_.SamAccountName -notlike "adm*"}

foreach ($user in $groupuser) {

    Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false  

}
