#: Andru Estes
#: October 29, 2015

# Script to obtain a specific VM's VLAN ID.
# Eventually will allow for single VM, VMs on specific cluster, VMs on datacenter, etc.

$vm = Read-Host "Enter the VM you wish to check VLAN info for"

get-vm -name $vm | Get-VirtualPortGroup | select Name, VLanId