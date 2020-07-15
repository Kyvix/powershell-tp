## Script pour la centralisation des fichiers inventaire e un seul "Flux de migration" ##

$SharedFolderPath= "\\SRC-SRV-AD01\Migration\"
$InventoriesPath= "\\SRC-SRV-AD01\Migration\Inventaires_machines\"
$header = '"NomSystème","OS","VersionOS","Processeur","CoeursPhysiques","CoeursLogiques","RAM","TailleDisque","SpeedNetWireless","SpeedNetWired","NomIntervenant","DateHeureInter"'
Set-Content -Path "${SharedFolderPath}Flux_de_migration.csv" -Value $header -Encoding UTF8
Get-ChildItem -Path "${InventoriesPath}*" -Include *.csv |`
Foreach-Object {
    $content = Get-Content $_.FullName 
    Add-Content -Path "${SharedFolderPath}Flux_de_migration.csv" -Value $content -Encoding UTF8
    }

