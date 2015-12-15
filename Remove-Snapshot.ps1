# Remove all snapshots on the VM called PROD1

#Connect-VIServer MYVISERVER
 
$vm = Read-Host "Enter VM name"
Write-Host " "
 
Get-VM $vm | Get-Snapshot | Remove-Snapshot -confirm:$True 

Write-Host " "