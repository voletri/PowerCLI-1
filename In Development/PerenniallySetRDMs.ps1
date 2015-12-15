# Set Perennially Reserved LUNs v.1
# This script sets the LUNs used as RDMs for Microsoft Clusters as reserved.  This speeds up boot time of the ESX Host.
# Written by:  Eric TeKrony
#
# 04/24/2012 -- v.1


# Get the hosts in the cluster
$vmhosts = Get-Cluster "OMAEDC_i5" | Get-VMHost

# Get the lunIDs from text file
$lunids = Import-Csv "D:\Script_Repo\CSVs\omaedc5RDMs.csv"

foreach ($vmhost in $vmhosts)
{
	$myesxcli = Get-EsxCli -VMHost $vmhost
	
	foreach ($lunid in $lunids)
	{
		$myesxcli.storage.core.device.setconfig($false, $lunid, $true)
	}
	
}