## Script Suppression des droits admins locaux des users PRESTA10 ##

#$groupadmin= "Admins du domaine"
$group = "Migration"
#$groupuser = Get-ADGroupMember -Identity $group | Where-Object {$_.SamAccountName -notlike "adm*"}
$groupuser = Get-ADGroupMember -Identity $group

foreach ($user in $groupuser) {

    Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false 

}
