Get-VM | Get-NetworkAdapter | 
Where-object {$_.Type -ne "Vmxnet3"} | 
Select @{N="VM";E={$_.Parent.Name}},Name,Type |
export-Csv  c:\Network_Interface.csv -NoTypeInformation