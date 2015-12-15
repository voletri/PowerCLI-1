#vSwitch Creation Script v.1
#This script creates a new vSwitch on every host in the cluster.
#
#Written by Eric Tekrony
#Edited by Andru Estes
#
#v.1 7/7/2011
#v.2 11/02/2015

#Prompt user for datacenter and cluster
$datacenter = Read-Host "Enter Datacenter"
$cluster = Read-Host "`Enter Cluster"

#Gather hosts from vCenter for chosen cluster
Write-Host "Getting hosts from cluster..."
$MyVMHosts = Get-Datacenter $datacenter | Get-Cluster $cluster | Get-VMHost

#Prompt user for vSwitch name
$vswitchname = Read-Host "Enter name of new vSwitch"

#DEPRECATED!! Prompt user for number of ports
#$ports = Read-Host "Enter number of ports for vSwitch"

#Prompt user for nics to connect
$vmNICS = Get-VMHostNetworkAdapter -VMHost $myVMHosts | % {$_.Name}
#$nicstring = Read-Host "Enter names of NICs to connect (example:  vmnic1,vmnic2)"

#Get Guest machines from CSV file
#$MyVMHosts = import-csv "D:\Script_Repo\CSVs\createvswitch.csv"

#Create new vSwitch on each host.
foreach ($hostname in $MyVMHosts) {
		New-VirtualSwitch -VMHost $hostname -Name $vswitchname
		
		Write-Host "$hostname...done."
}