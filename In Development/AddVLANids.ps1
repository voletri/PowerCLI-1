#vSwitch Creation Script v.1
#This script creates a new vSwitch on every host in the cluster.
#
#Written by Eric Tekrony
#
#v.1 7/7/2011

#Prompt user for vCenter server and connect.
#$vcenter = Read-Host "Enter vCenter Server"
Connect-VIServer -Server "drsedcapp099" -User "ipgna\esb.service" -Password Password1
Write-Host "`nConnected to vCenter Server: DRSEDCAPP099"

#Prompt user for datacenter and cluster
#$datacenter = Read-Host "Enter Datacenter"
#$cluster = Read-Host "`Enter Cluster"

#Gather hosts from vCenter for chosen cluster
Write-Host "Getting hosts from cluster..."
$MyVMHosts = Get-Datacenter "DRSEDC" | Get-Cluster "DRSEDC" | Get-VMHost

#Add VLAN IDs
foreach ($hostname in $MyVMHosts) {
		#Get-VirtualSwitch -Name "vSwitch0" | Get-VirtualPortGroup -Name "vMotion" | Set-VirtualPortGroup -VLanId "421" -Confirm:$false
		Get-VirtualSwitch -Name "vSwitch0" | Get-VirtualPortGroup -Name "FT Logging" | Set-VirtualPortGroup -VLanId "422" -Confirm:$false
		
		Write-Host "$hostname...done."
}