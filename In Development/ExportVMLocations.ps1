# Export all VMs in a cluster and their locations v.1
# This script will export all VMs in a cluster and export it to a CSV.
#
#Written by Eric Tekrony
#
#v.1 11/15/2012


#Prompt user for cluster
$cluster = Read-Host "Enter Cluster"

Get-Cluster $cluster | Get-VM | Select Name, @{N="Cluster";E={Get-Cluster -VM $_}}, @{N="ESX Host";E={Get-VMHost -VM $_}}, @{N="Datastore";E={Get-Datastore -VM $_}} | `
Export-Csv -NoTypeInformation "D:\Output\"$cluster + "_VMs.csv" 