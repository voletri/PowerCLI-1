Connect-VIServer -Server omaedcvcs001 -Protocol HTTPS -User "ipgna\esb.service" -Password "Password1"
$vmcsv = import-csv "D:\hardening.csv"
$vmx01 = “isolation.tools.diskShrink.disable”
$value2 = "True"
$vmx01part2 = “isolation.tools.diskWiper.disable”
$value3 = "True"
$vmx02 = "RemoteDisplay.maxConnections"
$value4 = "1"
$vmx11 = "isolation.device.connectable.disable"
$value5 = "true"
$vmx11part2 = "isolation.device.edit.disable"
$value6 = "true"
$vmx12 = "vmci0.unrestricted"
$value7 = "false"
$vmx20 = "log.rotateSize"
$value8 = "1000000"
$vmx20part2 = "log.keepOld"
$value9 = "10"
$vmx21 = "tools.setInfo.sizeLimit"
$value10 = "1048576"
$vmx23 = "isolation.tools.hgfsSeverSet.disable"
$value11 = "TRUE"
$vmx30 = "guest.command.enabled"
$value12 = "FALSE"
$vmx31 = "tools.guestlib.enableHostInfo"
$value13 = "FALSE"



foreach ($vmguest in $vmcsv){
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx01
     $vmConfigSpec.extraconfig[0].Value=$value2
     
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx01part2
     $vmConfigSpec.extraconfig[0].Value=$value3
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx02
     $vmConfigSpec.extraconfig[0].Value=$value4
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx11
     $vmConfigSpec.extraconfig[0].Value=$value5
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx11part2
     $vmConfigSpec.extraconfig[0].Value=$value6
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx12
     $vmConfigSpec.extraconfig[0].Value=$value7
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx20
     $vmConfigSpec.extraconfig[0].Value=$value8
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx20part2
     $vmConfigSpec.extraconfig[0].Value=$value9
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx21
     $vmConfigSpec.extraconfig[0].Value=$value10
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx23
     $vmConfigSpec.extraconfig[0].Value=$value11
     $vm.ReconfigVM($vmConfigSpec)
     
     $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx30
     $vmConfigSpec.extraconfig[0].Value=$value12
     $vm.ReconfigVM($vmConfigSpec)
     
          $vm = Get-VM $vmguest.vm | Get-View
     $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
     $vmConfigSpec.extraconfig += New-Object VMware.Vim.optionvalue
     $vmConfigSpec.extraconfig[0].Key=$vmx31
     $vmConfigSpec.extraconfig[0].Value=$value13
     $vm.ReconfigVM($vmConfigSpec)
}