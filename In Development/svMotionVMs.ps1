Connect-VIServer -Server "DRSEDCAPP099" -User "ipgna\esb.service" -Password Password1
Write-Host "`nConnected to vCenter Server: DRSEDCAPP099"

#Get Guest machines from CSV file
$vm = Get-View -ViewType VirtualMachine -Filter @{"Name" = "DRSEDCDNS100"}
#hostView = Get-View -ID "$vm.Runtime.Host"
#$hostView.Summary.Runtime
#Write-Host $vm.Runtime.Host

#import-csv "D:\Script_Repo\CSVs\svMotionVMs.csv"

$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$extra = New-Object VMware.Vim.optionvalue
$extra.Key="fsr.maxSwitchoverSeconds"
$extra.Value="240"

$vmConfigSpec.extraconfig += $extra

	#if ($vm -eq "DRSEDCMHT003") 
$vm.ReconfigVM($vmConfigSpec)
	#	write-host