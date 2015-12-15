#$vmList = Get-Cluster -Name "OMAEDC" | Get-VM
$vm = Import-CSV "Z:\Documents\VMware\Scripts\CSVs\multiple-nics.csv"
$vmList = Get-VM $vm.Name

$x = 0

foreach($vm in $vmList){
	Write-Host $vm -Fore Green
	Get-NetworkAdapter -VM $vmList[$x] #| 
	
	<# Below is testing.
	Select @{N="Name";Label="VM Name"},
	@{Expression="Name";Label="NIC Name"},
	@{Expression="NetworkName";E="VLAN"} |
	Export-CSV -NoTypeInformation -UseCulture "C:\vlan-report.csv"
	#Above is testing
	#>
	
	#Select {$_.Name} {$_.NetworkName}
	#Select Name, NetworkName
	Write-Host ""
	
	$x = $x + 1
} #| 
#Export-CSV -NoTypeInformation -UseCulture "Z:\Documents\OUTPUT.csv"
