$report = @()
$rdmVMs = @()
$vms = Get-VM | Get-View

foreach($machine in $vms){
     foreach($dev in $machine.Config.Hardware.Device){
          if(($dev.gettype()).Name -eq "VirtualDisk"){
               if(($dev.Backing.CompatibilityMode -eq "physicalMode") -or
               ($dev.Backing.CompatibilityMode -eq "virtualMode")){
                    $row = "" | select VMName, VMHost, LUNName
                    $row.VMName = $machine.Name
                    $esx = Get-View $machine.Runtime.Host
                    $row.VMHost = ($esx).Name
#                    $row.HDDeviceName = $dev.Backing.DeviceName
#                    $row.HDFileName = $dev.Backing.FileName
#                    $row.HDMode = $dev.Backing.CompatibilityMode
#                    $row.HDSize = $dev.CapacityInKB
                    $row.LUNName = ($esx.Config.StorageDevice.ScsiLun | where {$_.Uuid -eq $dev.Backing.LunUuid}).DisplayName
#                    $report += $row
					$rdmVMs += @($row | Select-Object -Property VMName, LUNName, VMHost)
               }
          }
     }
}
#$report #| Export-Csv -NoTypeInformation C:\RDM-Report.csv

$rdmVMs | FT -AutoSize
@($rdmVMs.Count)
