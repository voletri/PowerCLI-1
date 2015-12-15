#Turn on Automatic Install of Tools on Reboot Script v.1
#This script turns on the feature to install a new version of the VMware tools when a Windows host reboots.
#
#Written by Eric Tekrony
#
#v.1 10/7/2011

#Prompt for Datacenter and Cluster
#$datacenter = Read-Host "`nEnter Datacenter: "
#$cluster = Read-Host "Enter Cluster: "

#Get Windows Guest machines in cluster from vCenter server
$vmguests = Get-Datacenter OMAEDC | Get-VM | %{Get-View $_.ID} | where {$_.Guest.GuestFamily -match "windowsGuest"}

#Get Guest machines from CSV file
#$vmguests = import-csv "D:\Script_Repo\CSVs\_.csv"

#Create new Virtual Machince Config Spec
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

#Write new config options to VMs using csv
foreach ($vm in $vmguests){
	
	$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$vmConfigSpec.tools = New-Object VMware.Vim.ToolsConfigInfo
	$vmConfigSpec.tools.toolsUpgradePolicy = "upgradeAtPowerCycle"

	$vm.ReconfigVM_Task($vmConfigSpec)
}
