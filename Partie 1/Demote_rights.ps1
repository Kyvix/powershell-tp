## Script Suppression des droits admins locaux des users PRESTA10 ##

$group = "Migration"
$groupuser = Get-ADGroupMember -Identity $group

foreach ($user in $groupuser) {

    Remove-ADGroupMember -Identity $group -Members $user -Confirm:$false 

}
