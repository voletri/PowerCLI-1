#SysLog Restart Script
#This script passes the ESXCLI command to reload the syslog daemon on the host.
#
#Written by Eric Tekrony
#
#v.1 2/8/2013

#Prompt user for datacenter and cluster
$datacenter = Read-Host "Enter Datacenter"
#$cluster = Read-Host "`Enter Cluster"

#Gather hosts from vCenter for chosen cluster
Write-Host "Getting hosts from vCenter Server..."
$MyVMHosts = Get-DataCenter | Get-VMHost

#Run command on each host.
foreach ($hostname in $MyVMHosts) {
		 $esxCli = Get-EsxCli -VMHost $hostname
		 $esxCli.system.syslog.reload
		 Write-Host "$hostname...done."
}