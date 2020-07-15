## Script des Users selon leurs présences  ##

function verification_user([string]$username) {
    Try { 
        Get-ADuser -Identity $username -ErrorAction Stop
        return $true
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        return $false
    }
}


$list = Import-Csv -Path "C:\Partages\Exploit\CSV_Users_Presta10\Users_List.csv" 
$group = "Migration"

foreach ($user in $list) {

    $username = $user.sam
    $password = $user.company + "@2020"
    $path = "OU=Migration,OU=PRESTA10,DC=esgi-src,DC=ads"
    $presence = $user.presence

    if ($presence -eq 1) {
        if (verification_user ($username)) {
            Get-ADuser -Identity $username | Enable-ADAccount
            write-host "L'utilisateur " $user.name " est créé et activé"
        }
        else {

            New-ADUser -Name $user.name `
            -SamAccountName $user.sam`
            -Givenname $user.givenname`
            -Surname $user.surname`
            -DisplayName $user.name`
            -Company $user.company`
            -Department $user.department`
            -EmailAddress $user.mail `
            -AccountPassword (ConvertTo-SecureString -AsPlainText $password -Force)`
            -ChangePasswordAtLogon $true `
            -PasswordNeverExpires $false `
            -PasswordNotRequired $false `
            -Path $path `
            -Enabled $true `
            -TrustedForDelegation $false


            Add-ADGroupMember -Identity $group -Members $username
            
            Write-Host "L'utilisateur" $user.name " a été créé"
        }
    }
    else {
        if (verification_user ($username)) {
            Get-ADuser -Identity $username | Disable-ADAccount
            write-host "L'utilisateur " $user.name " a été désactivé"
        }
        else {
            write-host "Aucune action requise"
        }
    }   
}
