# The following example lists all hosts nics and nic speeds

#Connect-VIServer MYVISERVER
 
Write "Gathering VMHost objects" 
$vmhosts = Get-VMHost | Sort Name | Where-Object {$_.State -eq "Connected"} | Get-View 
$Information = @() 
foreach ($vmhost in $vmhosts){ 
	$ESXHost = $vmhost.Name 
	Write "Collating information for $ESXHost" 
	$networkSystem = Get-view 
	$vmhost.ConfigManager.NetworkSystem 
	foreach($pnic in $networkSystem.NetworkConfig.Pnic){ 
		$pnicInfo = $networkSystem.QueryNetworkHint($pnic.Device) 
		foreach($Hint in $pnicInfo){ 
			$NetworkInfo = "" | select-Object Host, PNic, Speed 
			$NetworkInfo.Host = $vmhost.Name 
			$NetworkInfo.PNic = $Hint.Device  
			$record = 0 
			Do { 
				If ($Hint.Device -eq $vmhost.Config.Network.Pnic[$record].Device){ 
				$NetworkInfo.Speed = $vmhost.Config.Network.Pnic[$record].LinkSpeed.SpeedMb 
				} 
				$record ++ 
			} 
			Until ($record -eq ($vmhost.Config.Network.Pnic.Length)) 
			$Information += $NetworkInfo 
		} 
	} 
} 
$Information | Sort Host, PNic