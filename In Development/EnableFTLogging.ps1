#vSphere Enable FT Logging Script v.1
#This enables Fault Tolerance Logging on the existing vMotion port on all ESX hosts in datacenter.
#
#Written by Eric Tekrony
#
#v.1 6/21/2011

#Prompt user for vCenter server and connect.
#$vcenter = Read-Host "Enter vCenter Server"
#Connect-VIServer -Server $vcenter -User "ipgna\esb.service" -Password Password1
#Write-Host "`nConnected to vCenter Server: $vcenter"
	
#Prompt user for datacenter and cluster
$datacenter = Read-Host "`nEnter Datacenter"
$cluster = Read-Host "`nEnter Cluster"

#Gather hosts from vCenter for chosen cluster
Write-Host "`nGetting hosts from cluster..."
$MyVMHosts = Get-Datacenter $datacenter | Get-Cluster $cluster | Get-VMHost

#Get Guest machines from CSV file
#$MyVMHosts = import-csv "D:\Script_Repo\CSVs\HostFTLogging.csv"

#Connect to each host and enable FT Logging.
foreach ($hostname in $MyVMHosts) {
		
		$hostView = Get-VMHost $hostname | Get-View -Property configManager
		$nicManager = Get-View $hostView.configManager.virtualNicManager
		$nicManager.SelectVnicForNicType("faultToleranceLogging", "vmk0")

		Disconnect-VIServer -Confirm:$false
		Write-Host "`n$hostname...done."
}