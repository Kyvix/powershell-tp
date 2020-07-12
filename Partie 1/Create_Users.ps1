function verification_user([string]$username) {
    Try { 
        Get-ADuser -Identity $username -ErrorAction Stop
        return $true
    }
    Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        return $false
    }
}


$list = Import-Csv -Path "C:\Partages\Exploit\CSV_Users_Presta10\Week_1.csv" 
$groupadmin = "Administrateurs"
$group = "Migration"

foreach ($user in $list) {

    $username = $user.sam
    $password = $user.company + "@2020"
    $path = "OU=Migration,OU=PRESTA10,DC=esgi-src,DC=ads"
    $presence = $user.presence

    if (verification_user ($username)) {
        if ($presence -eq 1) {
            Get-ADuser -Identity $username | Enable-ADAccount
            write-host "L'utilisateur " $user.name " est cr√©√© et activ√©"
        }
        else {
            Get-ADuser -Identity $username | Disable-ADAccount
            write-host "L'utilisateur " $user.name " a √©t√© d√©sactiv√©"
        }
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

        Add-ADGroupMember -Identity $groupadmin -Members $username
        Add-ADGroupMember -Identity $group -Members $username

        Write-Host "L'utilisateur" $user.name " a ÈtÈ crÈÈ"
        }
}
