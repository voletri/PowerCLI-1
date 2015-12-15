$vCenterServerName = "drsedcapp099" # Enter your vCenter server name here. In case of multiple vCenter servers, separate using a comma.
 
$ErrorActionPreference = "Stop"
 
# Connect to vCenter(s)
Write-Host "Connecting..."
$VC = Connect-VIServer $vCenterServerName
 
Write-Host "Counting physical cpu's and vRAM in your environment. Please be patient..."
# Gather information
$pCpu = (Get-VMHost | Get-View | Select -ExpandProperty Hardware | Select -ExpandProperty CpuInfo | Measure-Object -Property NumCpuPackages -Sum).Sum
$vRAM = [Math]::Round((Get-VM | Where {$_.PowerState -eq "PoweredOn"} | Measure-Object -Property MemoryMB -Sum).Sum/1024,0)
Write-Host "======"
"pCpu Count: {0}" -f $pCpu
"vRAM (GB):  {0}" -f $vRAM
Write-Host "======"
# Disconnect
Disconnect-VIServer $vCenterServerName -Confirm:$false
 
# Calculate required licenses
$licCol = @()
$licObj = "" | Select Edition, Entitlement, Licenses
$licObj.Edition = "Essentials/Essentials Plus/Standard"
$licObj.Entitlement = "1 pCpu + 24 GB vRAM"
If (($vRAM/24) -gt $pCpu)
{
	$licObj.Licenses = "{0} with {1} pCpu overhead" -f [Math]::Ceiling($vRAM/24), ([Math]::Ceiling($vRAM/24) - $pCpu)
}
Else
{
	$licObj.Licenses = "{0} with {1} GB vRAM overhead" -f $pCpu, ((24 * $pCpu) - $vRAM)
}
$licCol += $licObj
$licObj = "" | Select Edition, Entitlement, Licenses
$licObj.Edition = "Enterprise"
$licObj.Entitlement = "1 pCpu + 32 GB vRAM"
If (($vRAM/32) -gt $pCpu)
{
	$licObj.Licenses = "{0} with {1} pCpu overhead" -f [Math]::Ceiling($vRAM/32), ([Math]::Ceiling($vRAM/32) - $pCpu)
}
Else
{
	$licObj.Licenses = "{0} with {1} GB vRAM overhead" -f $pCpu, ((32 * $pCpu) - $vRAM)
}
$licCol += $licObj
$licObj = "" | Select Edition, Entitlement, Licenses
$licObj.Edition = "Enterprise Plus"
$licObj.Entitlement = "1 pCpu + 48 GB vRAM"
If (($vRAM/48) -gt $pCpu)
{
	$licObj.Licenses = "{0} with {1} pCpu overhead" -f [Math]::Ceiling($vRAM/48), ([Math]::Ceiling($vRAM/48) - $pCpu)
}
Else
{
	$licObj.Licenses = "{0} with {1} GB vRAM overhead" -f $pCpu, ((48 * $pCpu) - $vRAM)
}
$licCol += $licObj
# Displaying output
Write-Host "Resulting license options:"
$licCol
Write-Host "======"
Write-Host "NOTE: vRAM only counts memory allocated to vm's that are POWERED ON." -ForegroundColor Red 
Write-Host "NOTE: Please double check the results of this script, since hosts may have been omitted due to errors." -ForegroundColor Red 
Write-Host "Disclaimer: No rights can be deduced from this calculation." -ForegroundColor Red
Write-Host "======"