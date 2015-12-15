#Turn OFF Automatic Install of Tools on Reboot Script v.1
#This script turns OFF the feature to install a new version of the VMware tools when a Windows host reboots.
#
#Written by Eric Tekrony
#
#v.1 03/27/2012

#Prompt for Datacenter and Cluster
$datacenter = Read-Host "Enter Datacenter"

#Get Windows Guest machines in cluster from vCenter server
$vmguests = Get-Datacenter $datacenter | Get-VM | %{Get-View $_.ID} | where {$_.Guest.GuestFamily -match "windowsGuest"}

#Create new Virtual Machince Config Spec
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

#Write new config options to VMs
foreach ($vm in $vmguests){
	
	$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$vmConfigSpec.tools = New-Object VMware.Vim.ToolsConfigInfo
	$vmConfigSpec.tools.toolsUpgradePolicy = "manual"

	$vm.ReconfigVM_Task($vmConfigSpec)
}
