# Usage: .\changeUUID.ps1

if ($args[0].length -gt 0) {
connect-viserver $args[0]
$VMs = get-vm
foreach ($vm in $VMs){
$date = get-date -format "dd hh mm ss"ù
$newUuid = "56 4d 50 2e 9e df e5 e4-a7 f4 21 3b "ù + $date
echo "VM: "ù $VM.name "New UUID: "ù $newuuid
$spec = New-Object VMware.Vim.VirtualMachineConfigSpec
$spec.uuid = $newUuid
$vm.Extensiondata.ReconfigVM_Task($spec)
start-sleep -s 2
}
}
else {Echo "Must supply IP address of ESX host. e.g. .changeUUID.ps1 192.168.0.10"}