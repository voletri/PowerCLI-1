#: Andru Estes
#: Novemeber 03, 2015
#: Script to check the current vSwitch settings and alter them if necessary.

# Reading in arguments passed from "Get-vSwitch-Security" script
if ($args[0] -and $args[1]){
	$datacenter = $args[0]
	$cluster = $args[1]
}
else{
	
	Write-Host " "
	Write-Host "No arguments were passed in..."
	
	#Listing the datacenters to choose from.
	Write-Host " "
	Write-Host "Here are the Datacenter choices..."

	$gotDatacenters = Get-Datacenter

	Write-Host $gotDatacenters

	Write-Host " "

	#Setting datacenter variable.
	$datacenter = Read-Host "Enter datacenter"

	#Listing clusters to choose from.
	Write-Host " "
	Write-Host "Below are the clusters to choose from..."
	Write-Host " "

	Get-Datacenter -Name $datacenter | Get-Cluster | % {$_.Name}

	Write-Host " "

	#Setting cluster 
	$cluster = Read-Host "Enter cluster name"
}
Write-Host " "

# Setting vmHosts to store all hosts within the cluster.
Write-Host "Collecting ESXi hosts..." -Foreground "Green"
$vmHosts = Get-Cluster -Name $cluster | Get-VMHost

#Listing the current vSwitch settings.
Write-Host "Gathering vSwtich settings for ESXi hosts..." -Foreground "Green"
foreach ($vmHost in $vmHosts){
	Get-VirtualSwitch -VMHost $vmHost -Standard | Select VMhost, Name, `  
		@{N="MacChanges";E={if ($_.ExtensionData.Spec.Policy.Security.MacChanges) { "Accept" } Else { "Reject"} }}, `  
		@{N="PromiscuousMode";E={if ($_.ExtensionData.Spec.Policy.Security.PromiscuousMode) { "Accept" } Else { "Reject"} }}, `  
		@{N="ForgedTransmits";E={if ($_.ExtensionData.Spec.Policy.Security.ForgedTransmits) { "Accept" } Else { "Reject"} }}  
	}

Function Set-VirtualSwitchSecurity {  
	Param (  
		[Parameter(Mandatory=$True,ValueFromPipeline=$True)]$vSwitch,  
		[ValidateSet("Accept","Reject")]$MacAddressChanges,  
		[ValidateSet("Accept","Reject")]$PromiscuousMode,  
		[ValidateSet("Accept","Reject")]$ForgedTransmits
	)  
	Process {  
		$hostExt = $vSwitch.VMHost.ExtensionData  
		$networkSystem = get-view $hostExt.ConfigManager.NetworkSystem  
		$networkSystem.NetworkConfig.Vswitch| Where {$_.name -match $vSwitch.Name} | Foreach {  
			$switchSpec = $_.spec  
			if ($PromiscuousMode -eq "Accept") {  
				$switchSpec.Policy.Security.AllowPromiscuous = $True  
			}  
			if ($PromiscuousMode -eq "Reject") {  
				$switchSpec.Policy.Security.AllowPromiscuous = $False  
			}  
			if ($MacAddressChanges -eq "Accept") {  
				$switchSpec.Policy.Security.MacChanges = $True  
			}  
			if ($MacAddressChanges -eq "Reject") {  
				$switchSpec.Policy.Security.MacChanges = $False  
			}  
			if ($ForgedTransmits -eq "Accept") {  
				$switchSpec.Policy.Security.ForgedTransmits = $True  
			}  
			if ($ForgedTransmits -eq "Reject") {  
				$switchSpec.Policy.Security.ForgedTransmits = $False  
			}  
			$NetworkSystem.UpdateVirtualSwitch($vSwitch.Name, $switchSpec)  
		}  
		Get-VirtualSwitch -Name $vSwitch.Nameclear -VMHost $vSwitch.VMHost | Select VMHost, Name, `  
			@{N="MacChanges";E={if ($_.ExtensionData.Spec.Policy.Security.MacChanges) { "Accept" } Else { "Reject"} }}, `  
			@{N="PromiscuousMode";E={if ($_.ExtensionData.Spec.Policy.Security.PromiscuousMode) { "Accept" } Else { "Reject"} }}, `  
			@{N="ForgedTransmits";E={if ($_.ExtensionData.Spec.Policy.Security.ForgedTransmits) { "Accept" } Else { "Reject"} }}  
	}  
}  


#$switchName = Read-Host "Enter target switch name"
#$host = Read-Host "Enter the ESXi host you want to edit"

#$switch = Read-Host "Enter the switch you wish to change"
$switches = Get-VirtualSwitch -Standard
Write-Host "Changing vSwitch settings to desired options..." -Foreground "Green"

foreach ($vswitch in $switches){
	Get-VirtualSwitch -Standard -Name $vswitch | Set-VirtualSwitchSecurity -MacAddressChanges Accept -PromiscuousMode Reject -ForgedTransmits Reject
	#Get-VirtualSwitch -VMHost $host -Name $switchName | Set-VirtualSwitchSecurity -MacAddressChanges Accept -PromiscuousMode Reject -ForgedTransmits Accept
}