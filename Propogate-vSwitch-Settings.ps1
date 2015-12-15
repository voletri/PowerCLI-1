# Author: Virtual-Al w/ edits by Andru Estes
# Script: Copies existing vSwitch and PortGroup configurations and propogates them to a newly installed ESXi host.


#$VISRV = Connect-VIServer (Read-Host "Please enter the name of your VI SERVER")
$BASEHost = Get-VMHost -Name (Read-Host "Please enter the name of your existing server as seen in the VI Client:")
$NEWHost = Get-VMHost -Name (Read-Host "Please enter the name of the server to configure as seen in the VI Client:")
 
$BASEHost | Get-VirtualSwitch -Standard | Foreach {
   If (($NEWHost | Get-VirtualSwitch -Standard -Name $_.Name-ErrorAction SilentlyContinue)-eq $null){
       Write-Host "Creating Virtual Switch $($_.Name)"
       $NewSwitch = $NEWHost | New-VirtualSwitch -Name $_.Name-NumPorts $_.NumPorts-Mtu $_.Mtu
       $vSwitch = $_
    }
   $_ | Get-VirtualPortGroup -Standard | Foreach {
       If (($NEWHost | Get-VirtualPortGroup -Standard -Name $_.Name-ErrorAction SilentlyContinue)-eq $null){
           Write-Host "Creating Portgroup $($_.Name)"
           $NewPortGroup = $NEWHost | Get-VirtualSwitch -Standard -Name $vSwitch | New-VirtualPortGroup -Name $_.Name-VLanId $_.VLanID
        }
    }
}