## Script de récupération des informations système de la machine cliente ##

function getNetworkAdapterSpeed([string]$type) {
    $NetworkAdapterSpeed = Get-WmiObject Win32_NetworkAdapter -ComputerName "localhost" |`
    Where-Object {$_.Name -match $type -and $_.Name -notmatch 'virtual' -and $null -ne $_.Speed -and $null -ne $_.MACAddress} |`
    Measure-Object -Property speed -sum |`
    ForEach-Object { [Math]::Round(($_.sum / 1GB))}    
    if ($null -ne $NetworkAdapterSpeed) {
        return $NetworkAdapterSpeed
    } else {
        return "no ${type} adapter found"
    }
}

$SharedFolderPath = "\\SRC-SRV-AD01\Migration\Inventaires_machines"
$Computer = "localhost"
$PSO = New-Object PSObject
$CPUInfo = Get-WmiObject Win32_Processor -ComputerName  $Computer
$SystemName = $CPUInfo.SystemName
$OSInfo = Get-WmiObject Win32_OperatingSystem -ComputerName $Computer
$PhysicalMemory = Get-WmiObject CIM_PhysicalMemory -ComputerName    $Computer | Measure-Object -Property capacity -Sum | ForEach-Object { [Math]::Round(($_.sum / 1GB), 2) }
$DiskSize = Get-WmiObject Win32_logicaldisk -ComputerName localhost | Measure-Object -Property size -Sum | ForEach-Object { [Math]::Round(($_.sum / 1GB), 2) }
$WirelessAdapterSpeed = getNetworkAdapterSpeed("Wi-Fi")
$EthernetAdapterSpeed = getNetworkAdapterSpeed("Intel")
$DateTime = Get-Date -UFormat "%Y/%m/%d %T"

Add-Member -inputObject $PSO -memberType NoteProperty -name "NomSystème" -value $SystemName
Add-Member -inputObject $PSO -memberType NoteProperty -name "OS" -value $OSInfo.Caption
Add-Member -inputObject $PSO -memberType NoteProperty -name "VersionOS" -value $OSInfo.Version
Add-Member -inputObject $PSO -memberType NoteProperty -name "Processeur" -value $CPUInfo.Name
Add-Member -inputObject $PSO -memberType NoteProperty -name "CoeursPhysiques" -value $CPUInfo.NumberOfCores
Add-Member -inputObject $PSO -memberType NoteProperty -name "CoeursLogiques" -value $CPUInfo.NumberOfLogicalProcessors
Add-Member -inputObject $PSO -memberType NoteProperty -name "RAM" -value $PhysicalMemory
Add-Member -inputObject $PSO -MemberType NoteProperty -name "TailleDisque" -Value $DiskSize
Add-Member -inputObject $PSO -MemberType NoteProperty -name "SpeedNetWireless" -Value $WirelessAdapterSpeed
Add-Member -inputObject $PSO -MemberType NoteProperty -name "SpeedNetWired" -Value $EthernetAdapterSpeed
Add-Member -inputObject $PSO -MemberType NoteProperty -name "NomIntervenant" -Value $env:UserName
Add-Member -inputObject $PSO -MemberType NoteProperty -name "DateHeureInter" -Value $DateTime

$PSO | ConvertTo-Csv -NoTypeInformation | Select-Object -Skip 1 | Set-Content -Path "${SharedFolderPath}\${SystemName}.csv" -Encoding UTF8
