#Enable and Configure SNMP Script v.1
#This script enables SNMP on the hosts of a cluster and configure them with desired settings.
#
#Written by Zach Milleson
#
#v.1 10/29/2012


#Prompt user for cluster
$cluster = Read-Host "Enter Cluster"

#Prompt user for vSwitch
$vswitch = Read-Host "Enter vSwtich"

#Prompt user for VLAN name
$vlanname = Read-Host "Enter VLAN name"

#Prompt user for VLAN ID
$vlanid = Read-Host "Enter VLAN ID"

#Gather hosts from vCenter for chosen cluster
$MyVMHosts = Get-Cluster $cluster | Get-VMHost | sort Name | % {$_.Name}

#Add VLAN IDs
foreach ($hostname in $MyVMHosts) {
		Get-VirtualSwitch -VMHost $hostname -Name $vswitch | New-VirtualPortGroup -Name $vlanname -VLanId $vlanid
}