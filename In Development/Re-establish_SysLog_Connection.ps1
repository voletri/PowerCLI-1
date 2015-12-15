#Re-enable Syslog Reporting v.1
#This script re-establishes the Syslog collecting from the hosts to the vCenter Server. Each time the vCenter server is restarted, this will need to be run.
#
#Written by Zach Milleson
#
#v.1 5/28/2013

#Prompt user for cluster
$cluster = Read-Host "Enter Cluster"

#Gather hosts from vCenter for chosen cluster
$MyVMHosts = Get-Cluster $cluster | Get-VMHost | sort Name | % {$_.Name}

foreach ($hostname in $MyVMHosts){
    Write-Host "ESX: "$hostname
    $esxcli = Get-EsxCli -VMhost $hostname
    $esxcli.system.syslog.reload()
}