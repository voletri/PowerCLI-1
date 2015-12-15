#: Andru Estes (w/ LucD help)
#: December 09, 2015
#: Script reads in user input of NAA ID for desired LUN and automates the process of attaching to a cluster. 

# Settings...
# Entering the LUN naa Id. 
$LunIds = Read-Host "Enter NAA ID here"

# Setting the desired cluster with user input.
$Clustername = Read-Host "Enter Cluster name"

#######################################################
###				Initializing Functions				###
#######################################################

function Attach-Disk{
    param(
        [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VMHostImpl]$VMHost,
        [string]$CanonicalName
    )
     
    $storSys = Get-View $VMHost.Extensiondata.ConfigManager.StorageSystem
    $lunUuid = (Get-ScsiLun -VmHost $VMHost | 
      where {$_.CanonicalName -eq $CanonicalName}).ExtensionData.Uuid
     
    $storSys.AttachScsiLun($lunUuid)
}

#######################################################
###				End of Initialization				###
#######################################################

# Collecting all ESXi hosts within the selected cluster.
Write-Host "Gathering ESXi hosts..." -ForegroundColor Magenta
$ClusterHosts = Get-Cluster $Clustername | Get-VMHost

# For every ESXi host within the cluster, and for every LUN ID within the LUN IDs entered, detach that LUN from each host using NAA ID and loop for all hosts.
Foreach($VMHost in $ClusterHosts)
{
    Foreach($LUNid in $LunIDs)
    {
        Write-Host "Attaching" $LUNid "onto" $VMHost -ForegroundColor "Yellow"
        Attach-Disk -VMHost $VMHost -CanonicalName $LUNid
    }
}
