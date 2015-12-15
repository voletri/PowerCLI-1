# Upgrade VMTools on VMs from a CSV
# Created by Zach Milleson
# Revision 1.0

#Connect to vCenter
D:\Script_Repo\Connect_to_DRS_vCenter.ps1

    #Send Start Email
    D:\Script_Repo\Update_Tools\StartedEmail.ps1

$vms = Import-CSV "D:\Script_Repo\Update_Tools\UpdateTools.csv"
foreach ($vm in $vms){
      Get-VM $vm.name | Update-Tools -NoReboot
}

	#Send Finish Email
    D:\Script_Repo\Update_Tools\CompletedEmail.ps1
	
#Disconnect from vCentre
D:\Script_Repo\Disconnect_from_vCenter.ps1