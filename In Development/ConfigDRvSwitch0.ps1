#Prompt user for vCenter server and connect.
#$vcenter = Read-Host "Enter vCenter Server"
Connect-VIServer -Server "DRSEDCAPP099" -User "ipgna\esb.service" -Password Password1
Write-Host "`nConnected to vCenter Server: $vcenter"

#Gather hosts from vCenter for chosen cluster
Write-Host "`nGetting hosts from cluster..."
$MyVMHosts = Get-Datacenter "DRSEDC" | Get-Cluster "DRSEDC4i" | Get-VMHost

#Get Guest machines from CSV file
#$MyVMHosts = import-csv "D:\Script_Repo\CSVs\NewDRHosts.csv"

#Connect to each host, create 2 new port groups, enable vMotion on one, and FT Logging on the the other.
foreach ($hostname in $MyVMHosts) {
#		$vip = $MyVMHosts.vip
#		$ftip = $MyVMHosts.ftip
		
		Connect-VIServer -Server $hostname -User "root" -Password H0me*Brew3r
		Write-Host "`nConnected to $hostname"
		
#		Get-VMHost | Get-VMHostNetworkAdapter -VMKernel | Set-VMHostNetworkAdapter -VMotionEnabled $false -Confirm:$false
#		$network = Get-VMHostNetwork
#		Remove-VMHostNetworkAdapter $network.VirtualNic[0] -Confirm:$false
#		Remove-VirtualSwitch -VirtualSwitch "vSwitch3" -Confirm:$false
#		New-VMHostNetworkAdapter -PortGroup "vMotion" -VirtualSwitch "vSwitch0" -IP $vip -SubnetMask 255.255.255.192 -VMotionEnabled:$true
#		New-VMHostNetworkAdapter -PortGroup "FT Logging" -VirtualSwitch "vSwitch0" -IP $ftip -SubnetMask 255.255.255.192 -FaultToleranceLoggingEnabled:$true
#		New-VirtualSwitch -NumPorts 64 -Name "vSwitch3" -Nic "vmnic4"		
#		New-VirtualPortGroup -Name "10.199.37.0_27_VLAN.126" -VLanId "126" -VirtualSwitch "vSwitch3"
#		Set-VirtualSwitch -VirtualSwitch "vSwitch0" -NumPorts 16 -Confirm:$false
#		Get-VMHost | Get-VMHostNetwork | Set-VMHostNetwork -VMKernelGateway 144.210.207.65


		Set-VirtualSwitch -VirtualSwitch "vSwitch1" -Nic "vmnic1" -Confirm:$false
		Set-VirtualSwitch -VirtualSwitch "vSwitch2" -Nic "vmnic2" -Confirm:$false
		Set-VirtualSwitch -VirtualSwitch "vSwitch3" -Nic "vmnic3" -Confirm:$false	

		Disconnect-VIServer -Confirm:$false
		Write-Host "`n$hostname...done."
}