#:	Andru Estes
#:	November 03, 2015
#:	Script purpose is to gather all ESXi hosts within the cluster


# Creating the menu for the user to choose from.
do {
    do {
        write-host ""
        write-host "Choose the datacenter..." -Foreground Yellow
        write-host "A - OMA"
        write-host "B - CHI"
        write-host "C - LDN"
        write-host "D - TEST"
        write-host "E - TDC"
		write-host ""
        write-host "X - Exit"
        write-host ""
        write-host -nonewline "Type your choice and press Enter: "
        
        $choice = read-host
        
        write-host ""
        
        $ok = $choice -match '^[abcdex]+$'
        
        if ( -not $ok) { write-host "Invalid selection" }
    } until ( $ok )
    
<#  switch -Regex ( $choice ) {
        "A"
        {
            write-host "You chose 'OMA'"
        }
        
        "B"
        {
            write-host "You chose 'CHI'"
        }

        "C"
        {
            write-host "You chose 'LDN'"
        }

        "D"
        {
            write-host "You chose 'TEST'"
        }
		"E"
        {
            write-host "You chose 'TDC'"
        }
    }
#>
} until ( $choice )


#Write-Host "Enter the cluster: " -NoNewLine -Foreground Yellow
if ($choice -eq "A"){
	$datacenter = "OMA"
}
elseif ($choice -eq "B"){
	$datacenter = "CHI"
}
elseif ($choice -eq "C"){
	$datacenter = "LDN"
}
elseif ($choice -eq "D"){
	$datacenter = "TEST"
}
elseif ($choice -eq "E"){
	$datacenter = "TDC"
}

$clusterChoices = Get-Datacenter -Name $datacenter | Get-Cluster

foreach ($option in $clusterChoices){
	Write-Host $option -Foreground Green
}

Write-Host ""
$cluster = Read-Host "Enter a cluster from above"
Write-Host ""

Write-Host "Gathering ESXi hosts..." -Foreground "Green"
$vmHosts = Get-Datacenter -Name $datacenter | Get-Cluster -Name $cluster | Get-VMHost


foreach ($vmHost in $vmHosts){
	Write-Host " "
	Write-Host "Host:" $vmHost -Foreground "Green"
	Get-VirtualSwitch -VMHost $vmHost -Standard | Select VMhost, Name, `
	#Get-VirtualSwitch -VMHost $vmHost -Standard | Select Name, `  
	#Get-VirtualSwitch -Standard | Select VMHost, Name, `  
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
        Get-VirtualSwitch -Name $vSwitch.Name -VMHost $vSwitch.VMHost | Select VMHost, Name, `  
            @{N="MacChanges";E={if ($_.ExtensionData.Spec.Policy.Security.MacChanges) { "Accept" } Else { "Reject"} }}, `  
            @{N="PromiscuousMode";E={if ($_.ExtensionData.Spec.Policy.Security.PromiscuousMode) { "Accept" } Else { "Reject"} }}, `  
            @{N="ForgedTransmits";E={if ($_.ExtensionData.Spec.Policy.Security.ForgedTransmits) { "Accept" } Else { "Reject"} }}  
    }  
}  

Write-Host "Would you like to change any of the settings? (Yes or No) " -NoNewLine -Foreground Yellow
$proceed = Read-Host

if ($proceed -eq "Yes" -or $proceed -eq "Y"){
	Z:\Documents\VMware\Scripts\Set-vSwitch-Settings.ps1 $datacenter $cluster
}
else{
	Write-Host " "
	Write-Host "All done!"
	exit 0
}

#Get-VirtualSwitch -Name vSwitch2 | Set-VirtualSwitchSecurity -MacAddressChanges Accept -PromiscuousMode Reject -ForgedTransmits Accept  
#Get-VirtualSwitch -VMHost "drsedcvmx112.na.corp.ipgnetwork.com" -Name "vSwitch2" | Set-VirtualSwitchSecurity -MacAddressChanges Accept -PromiscuousMode Reject -ForgedTransmits Reject
