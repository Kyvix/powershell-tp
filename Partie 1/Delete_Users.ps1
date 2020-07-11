function delete_users() {
    $timespan = New-Timespan –Days 30
    Search-ADAccount -AccountInactive -Timespan $timespan | Where-Object { $_.ObjectClass -eq 'user' } | Remove-ADUser
}