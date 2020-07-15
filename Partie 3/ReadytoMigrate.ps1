## Script éligibilité des machines pour migration ## 
function import_csv([string]$file) {
    $list = Import-Csv $file 
    return $list
}

$SharedFolderPath= "\\SRC-SRV-AD01\Migration\ReadyToMigrate\"
$ComputersList = import_csv("\\SRC-SRV-AD01\Migration\Flux_de_migration.csv") 
$header = Get-Content "\\SRC-SRV-AD01\Migration\Flux_de_migration.csv" | Select-Object -First 1
Set-Content -Path "${SharedFolderPath}PretPourMigration.csv" -Value $header -Encoding UTF8
$PretPourMigration = @()

foreach ($Computer in $ComputersList) {
    [int]$memory = $Computer.RAM
    [int]$processor_generation = [convert]::ToInt32($Computer.Processeur[21], 10)
    [int]$disk_size = $Computer.TailleDisque
    try {
        [int]$wireless_adapter_speed = $Computer.SpeedNetWireless
    }
    catch [System.InvalidCastException] {
        $wireless_adapter_speed = 0
    }
    try {
        [int]$ethernet_adapter_speed = $Computer.SpeedNetWired
    }
    catch [System.InvalidCastException] {
         $ethernet_adapter_speed = 0
     }
    if ($memory -ge 12 -and $processor_generation -ge 6 -and $disk_size -ge 500 -and ($ethernet_adapter_speed -ge 1 -or $wireless_adapter_speed -ge 1 )) {
        $PretPourMigration += $Computer
    }
    else {
        $computer_to_buy += 1
    }
}
$PretPourMigration | Export-Csv -NoTypeInformation -Path "${SharedFolderPath}PretPourMigration.csv" -Encoding UTF8
$DateTime = Get-Date -UFormat "%Y/%m/%d %T"
Add-Content -Path ${SharedFolderPath}PC_a_remplacer.txt -Value "$DateTime : PC qu'il faut remplacer: ${computer_to_buy}"
$work_todo = (($ComputersList | Measure-Object).Count - (import_csv("${SharedFolderPath}PC_Migres.csv") | Measure-Object).Count)
Add-Content -path ${SharedFolderPath}PC_a_Migrer.txt -Value "$DateTime : $work_todo PC restent à migrer"