#Match Selected OS to Installed OS v.1
#This script will match the Selected OS to the installed OS.
#
#Written by Eric Tekrony
#
#v.1 10/13/2011

#Get Guest machines from CSV file
$vmguests = import-csv "D:\Script_Repo\CSVs\MatchOSTest.csv"

#Create new Virtual Machince Config Spec
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

#Write new config options to VMs using csv
foreach ($vm in $vmguests){
	
	$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
	$vmConfigSpec.guestId = $vm.OS
	
	Get-VM $vm.Name | %{Get-View $_.ID}| %{$_.ReconfigVM_Task($vmConfigSpec)}
}
