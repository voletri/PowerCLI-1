#: Andru Estes (with help of VMware community)
#: November 12, 2015
#: Script reads in cs of VMs with multiple NICs, takes that list and exports the IP and VLAN for the NICs.

# Importing CSV with VMs to use.
$vmList = Import-CSV "Z:\Documents\VMware\Scripts\CSVs\multiple-nics.csv"

# Setting the target lsit to use for processing info.
$targetVMs = $vmList.name

Get-VM $targetVMs |
ForEach-Object {
  $VM = $_
  $VM | Get-VMGuest | Select-Object -ExpandProperty Nics |
  ForEach-Object {
    $Nic = $_
    foreach ($IP in $Nic.IPAddress)
    {
      if ($IP.Contains('.'))
      {     
        "" | Select-Object -Property @{Name='VM';Expression={$VM.Name}},
          @{Name='IPAddress';Expression={$IP}},
          @{Name='NetworkName';Expression={$Nic.NetworkName}}
      }
    }
  }
} |
Export-CSV -NoTypeInformation -UseCulture "Z:\Documents\VMware\Scripts\CSVs\OUTPUT.csv"

