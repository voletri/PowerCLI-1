# Update VM-Tools on all Windows VMs in a datacenter
# Created by: Zach Milleson
#
# Step 1 - Disable DRS on each cluster and gather VMs on individual hosts

	#Connect to vCenter
	Connect-VIServer -Server 144.210.196.99 -User "ipgna\esb.service" -Password Password1
		# Disable DRS on gen cluster
		Set-Cluster -Cluster "DRSEDC4" -DrsEnabled:$false -Confirm:$false
        # Disable DRS on SAP cluster
		Set-Cluster -Cluster "DRSSAP4" -DrsEnabled:$false -Confirm:$false
           
			#Gather VMs on the hosts
			$MyVMHosts = Get-Datacenter "DRSEDC" | Get-VMHost
            foreach ($line in $MyVMHosts) {
			#Retrieve guests on each host
            Get-VMHost -Name $line.name | get-vm | %{get-view $_.ID} | where {$_.guest.GuestFamily -eq "windowsGuest"} | select Name | export-csv D:\Script_Repo\CSVs\DRS\$line.csv 
			}
			
			#Disconnect from vCenter
	Disconnect-VIServer -Confirm:$false
	

#Step 2 - Connect to one host at a time and update tools on all Windows VMs

			Connect-VIServer -Server "144.210.196.101" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx001.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.120" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx020.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.102" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx002.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
			Connect-VIServer -Server "144.210.196.121" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx021.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.103" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx003.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.122" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx022.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.104" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx004.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.123" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx023.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.105" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx005.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.106" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx006.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
		
		Start-Sleep -Seconds 480	
			
			Connect-VIServer -Server "144.210.196.107" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx007.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
			
		Start-Sleep -Seconds 480
			
			Connect-VIServer -Server "144.210.196.108" -User root -Password "D1s@st3r"
				$vms = Import-CSV "D:\Script_Repo\CSVs\DRS\drsedcvmx008.ilo.interpublic.com.csv"
					foreach ($vm in $vms){
					Get-VM $vm.name | Update-Tools -NoReboot -RunAsync
					}
				Clear-Variable -Name vms -Force
			Disconnect-VIServer -Confirm:$false
				
				
	#Connect to vCenter
	Connect-VIServer -Server 144.210.196.99 -User "ipgna\esb.service" -Password Password1
		# Disable DRS on gen cluster
		Set-Cluster -Cluster "DRSEDC4" -DrsEnabled:$true -Confirm:$false
        # Disable DRS on SAP cluster
		Set-Cluster -Cluster "DRSSAP4" -DrsEnabled:$true -Confirm:$false
	Disconnect-VIServer -Confirm:$false