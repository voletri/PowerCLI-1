#Virtual Machine Hardening Script v.1
#All page numbers reference "VMware vSphere 4.1 Security Hardening Guide"
#Updated document can be found here: http://communities.vmware.com/docs/DOC-15413
#
#Written by Eric Tekrony
#
#v.1 6/16/2011

#Prompt and Connect to vCenter Server
$vcenter = Read-Host "Enter a vCenter server:"
Connect-VIServer -Server $vcenter -Protocol HTTPS -User "ipgna\esb.service" -Password "Password1"

#Prompt for Datacenter and Cluster
#$datacenter = Read-Host "`nEnter Datacenter: "
#$cluster = Read-Host "`nEnter Cluster: "

#Get Guest machines in cluster from vCenter server
#Write-Host "`nCollecting all VMs in $cluster..."
#$vmguests = Get-Datacenter $datacenter | Get-Cluster $cluster | Get-VMGuest
#Write-Host "done!"

#Get Guest machines from CSV file
$vmcsv = import-csv "D:\Script_Repo\CSVs\VMHardening.csv"

#Create new Virtual Machince Config Spec
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec

#Create temp options array
$temp = New-Object VMware.Vim.optionvalue


#Write new config options to VMs using array
#foreach ($vmguest in $vmguests){
#     $vm = Get-VM $vmguest.vm
#	 Write-Host "`nWriting new config to $vm..."
#	 $vm.Extensiondata.ReconfigVM($vmConfigSpec)
#	 Write-Host "done!"
#}

#Write new config options to VMs using csv
foreach ($vmguest in $vmcsv){
     $vm = Get-VM $vmguest.name
	 Write-Host "`nWriting new config to $vm..."
	 #Set Disk Shrink tools to disabled  p.12
	$temp.Key = “isolation.tools.diskShrink.disable”
	$temp.Value = "TRUE"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)
	$temp.Key = “isolation.tools.diskWiper.disable”
	$temp.Value ="TRUE"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)

	#Set number of remote display sessions for users to 1  p.13 
	$temp.Key = "RemoteDisplay.maxConnections"
	$temp.Value = "1"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)

	#Restrict certain hardware devices  p.14
	$temp.Key = "floppy0.present"
	$temp.Value = "false"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)
	#$temp.Key = "serialX.present"
	#$temp.Value = "false"
	#$vmConfigSpec.extraconfig += $temp
	#$temp.Key = "parallelX.present"
	#$temp.Value = "false"
	#$vmConfigSpec.extraconfig += $temp
	#$temp.Key = "usb.present"
	#$temp.Value = "false"
	#$vmConfigSpec.extraconfig += $temp

	#Restrict VMCI communication between VMs  p.16
	$temp.Key = "vmci0.unrestricted"
	$temp.Value = "FALSE"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)

	#Configure log file size to match storage blocks  p.17
	$temp.Key = "log.rotateSize"
	$temp.Value = "4000000"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)
	$temp.Key = "log.keepOld"
	$temp.Value = "5"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)

	#Disable certain Workstation/Fusion features  p.20
	$temp.Key = "isolation.tools.unity.push.update.disable"
	$temp.Value = "TRUE"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)
	$temp.Key = "isolation.tools.ghi.launchmenu.change"
	$temp.Value = "TRUE"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)
	$temp.Key = "isolation.tools.memSchedFakeSampleS"
	$temp.Value = "TRUE"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)
	$temp.Key = "isolation.tools.getCreds.disable"
	$temp.Value = "TRUE"
	$vmConfigSpec.extraconfig += $temp
	$vm.Extensiondata.ReconfigVM($vmConfigSpec)

	#Disable Host reporting to guest performance data  p.22
	$temp.Key = "tools.guestlib.enableHostInfo"
	$temp.Value = "false"
	$vmConfigSpec.extraconfig += $temp
	 $vm.Extensiondata.ReconfigVM($vmConfigSpec)
	 Write-Host "done!"
}

#Disconnect from vCenter
Disconnect-VIServer -Confirm:$false
Write-Host "All done."