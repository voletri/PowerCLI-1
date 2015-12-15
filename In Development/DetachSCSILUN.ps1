# Script to Detach a SCSI LUN by name from all hosts in cluster
# by:  Eric TeKrony
# 
# v.1 -- 3/28/2012

function Detach-Disk{
    param([VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost,[string]$CanonicalName)
    
    $storSys = Get-View $VMHost.Extensiondata.ConfigManager.StorageSystem
    $lunUuid = (Get-ScsiLun -VmHost $VMHost | where {$_.CanonicalName -eq $CanonicalName}).ExtensionData.Uuid
    
    $storSys.DetachScsiLun($lunUuid)
}

#function Attach-Disk{
#    param(
#        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost,
#        [string]$CanonicalName    )
#    
#    $storSys = Get-View $VMHost.Extensiondata.ConfigManager.StorageSystem
#    $lunUuid = (Get-ScsiLun -VmHost $VMHost | where {$_.CanonicalName -eq $CanonicalName}).ExtensionData.Uuid
#    
#   $storSys.AttachScsiLun($lunUuid)
#}

# Ask for cluster
$cluster = Read-Host "Which cluster"

# Ask user for LUN Name 
$name = Read-Host "What is the LUN Name you wish to detach"

# Gather all hosts from cluster
$MyVMHosts = Get-Cluster $cluster | Get-VMHost | sort Name | % {$_.Name}

# Run detach command on all hosts in cluster
foreach ($hostname in $MyVMHosts) {
	$myhost = Get-VMHost $hostname
	Detach-Disk -VMHost $myhost -CanonicalName $name
}

