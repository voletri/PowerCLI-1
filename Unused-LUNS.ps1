#: Author: Andru Estes 
#: December 09, 2015
#: Script scans designated cluster for any LUNs that are presented but not being used by any VMs. Essentially orphaned LUNs. 

# Setting variables with user input.  
Write-Host "Enter cluster name: " -ForegroundColor Green -NoNewline
$cluster = Read-Host

# Gathering all ESXi Hosts.
Write-Host "Gathering all ESXi hosts..." -ForegroundColor Magenta
$esx = Get-Cluster $cluster | Get-VMHost

<# Using the VMHosts within the chosen cluster, scanning for available LUNs that return a null value (not attached/used by VMs).
Then, getting rid of duplicate LUN naa id's when presented to make it easier to read. 
#>
$dsSys = Get-View $esx.Extensiondata.ConfigManager.DatastoreSystem
$dsSys.QueryAvailableDisksForVmfs($null) | Select DisplayName, CanonicalName | Sort-Object -Property CanonicalName -Unique | FT -AutoSize