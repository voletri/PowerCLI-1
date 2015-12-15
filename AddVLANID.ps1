#vSwitch Creation Script v.1
#This script creates a new vSwitch on every host in the cluster.
#
#Written by Eric Tekrony
#Edited by Andru Estes
#
#v.1 7/7/2011
#v.2 11/02/2015


#Prompt user for cluster
$cluster = Read-Host "Enter Cluster"

#Prompt user for vSwitch
$vswitch = Read-Host "Enter vSwitch"

#Reading CSV file for autopopulation of VLANs.
$vlanCSV = Import-Csv "Z:\Documents\VMware\Scripts\CSVs\vlans.csv"

#Gather hosts from vCenter for chosen cluster
$MyVMHosts = Get-Cluster $cluster | Get-VMHost | sort Name | % {$_.Name}

#Prompting for user choice
$selection = Read-Host "Would you like to specify the VLANs? If so, type YES, otherwise type NO"

#Add all VLAN IDs if desired.
if ($selection -eq "N" -or $selection -eq "NO"){
	foreach ($hostname in $MyVMHosts) {
		foreach ($newVlan in $vlanCSV) {
			Get-VirtualSwitch -VMHost $hostname -Name $vswitch | New-VirtualPortGroup -Name $newVlan.name -VLanId $newVlan.vlanid
		}
	}
}

elseif ($selection -eq "Y" -or $selection -eq "YES"){
		#Prompt user for VLAN name
		$vlanname = Read-Host "Enter VLAN name"

		#Prompt user for VLAN ID
		$vlanid = Read-Host "Enter VLAN ID"

		foreach ($hostname in $MyVMHosts) {
			Get-VirtualSwitch -VMHost $hostname -Name $vswitch | New-VirtualPortGroup -Name $vlanname -VLanId $vlanid
		}
}