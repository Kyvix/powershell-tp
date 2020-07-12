## Script Desactivation des utilisateurs post migration ##

$path = "OU=Migration,OU=PRESTA10,DC=esgi-src,DC=ads"
$prestauser = Get-ADUser -Filter * -SearchBase $path

foreach ($user in $prestauser) {

    Get-ADuser -Identity $user | Disable-ADAccount

}
