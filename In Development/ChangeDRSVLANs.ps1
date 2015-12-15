#vSphere PortGroup Reconfigure  -- DRS v.1
#This script will add the new VLAN IDs, change the VMs to the new ones, then delete the old ones in the cluster.
#
#Written by Eric Tekrony
#
#v.1 7/13/2011
#v.2 11/02/2015	- Edited by Andru Estes

#Prompt user for vCenter server and connect.
#$vcenter = Read-Host "Enter vCenter Server"
#Connect-VIServer -Server $vcenter -User "ipgna\esb.service" -Password Password1
#Write-Host "`nConnected to vCenter Server: $vcenter"
	
#Prompt user for datacenter and cluster
$datacenter = Read-Host "`nEnter Datacenter"
$cluster = Read-Host "`nEnter Cluster"

#Gather hosts from vCenter for chosen cluster
Write-Host "`nGetting hosts from cluster..."
$MyVMHosts = Get-Datacenter $datacenter | Get-Cluster $cluster | Get-VMHost

#Get Guest machines from CSV file
#$MyVMHosts = import-csv "D:\Script_Repo\CSVs\DRSHosts.csv"

#Gather VM machines from Cluster
$MyVMs = Get-Datacenter $datacenter | Get-Cluster $cluster | Get-VM

#Get New VLAN IDs
$NewVlanIds = Import-Csv "D:\Script_Repo\CSVs\NewDRSVLANs.csv"

#Add new VLANs to hosts
foreach ($hostname in $MyVMHosts) {
		foreach ($newvlan in $NewVlanIds) {	
			New-VirtualPortGroup -VirtualSwitch "vSwitch0" -Name $newvlan.newname -VLanId $newvlan.newid -Confirm $false
		}
		Write-Host "`n$hostname...created new VLANs."
}

#Reconfigure each VM to new VLANS
foreach ($vm in $MyVMs) {
	$vmnics = Get-NetworkAdapter -VM $vm
	
	foreach ($nic in $vmnics) {
	
		foreach ($newvlan in $NewVlanIds) {
			if ($nic.NetworkName -eq $newvlan.oldname) {
				Set-NetworkAdapter -NetworkName $newvlan.newname
			}
		}
	}
	
	Write-Host "`n$vm...done."
}

#Remove old VLANs from hosts
foreach ($hostname in $MyVMHosts) {
		foreach ($newvlan in $NewVlanIds) {	
			Get-VirtualSwitch -Name "vSwitch0" | Remove-VirtualPortGroup -VirtualPortGroup $newvlan.oldname
		}
		Write-Host "`n$hostname...removed old VLANs."
}
