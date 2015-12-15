$server = "144.210.196.99"
$user = "ipgna\esb.service"
$pwd = "Password1"

Connect-VIServer $server -User $user -Password $pwd

Get-cluster DRSSAP4 | get-vm | % { get-view $_.ID } | where {$_.guest.toolsstatus -eq "toolsOld"} | select Name, 
  @{ Name="ToolsStatus"; Expression={$_.guest.toolsstatus}}, @{ Name="ToolsVersion"; Expression={$_.config.tools.toolsVersion}}