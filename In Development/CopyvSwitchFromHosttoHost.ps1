#Copy vSwitch from Host to Host v.1
#This script will clone a vSwitch from one host to another.
#
#Written by Eric Tekrony
#
#v.1 1/13/2012


#Connect to Source Host
#$sourcehost = Read-Host "Please enter the SOURCE host"
#Connect-VIServer -Server $sourcehost -User "root" -Password "H0me*Brew3r"

#Get and export port groups for source vSwitch
#$vSwitch = Read-Host "Which vSwitch would you like to copy"

#Get-VirtualSwitch -Name $vSwitch | Get-VirtualPortGroup | Foreach {
#	Get-VirtualPortGroup | Export-Csv -Path "D:\Script_Repo\CSVs\exported-vlans.csv"
#}

#Disconnect-VIServer

$newhost = Read-Host "Please enter the NEW host"
Connect-VIServer -Server omaedcapp099 -User "ipgna\esb.service" -Password "Password1"

$vSwitch = Read-Host "Name of new vSwitch"

$vSwitch_config = Import-Csv "D:\Script_Repo\CSVs\exported-vlans.csv"
Get-Host $newhost
Get-VirtualSwitch -Name $vSwitch

Foreach ($portgroup in $vSwitch_config) {
	#Write-Host "Creating Portgroup $portgroup.Name"
	Get-VirtualSwitch -Name $vSwitch | New-VirtualPortGroup -Name $portgroup.Name -VLanId $portgroup.VLanID
}

Disconnect-VIServer
	
#$VISRV = Connect-VIServer (Read-Host "Please enter the name of your VI SERVER")
#$BASEHost = Get-VMHost -Name (Read-Host "Please enter the name of your existing server as seen in the VI Client:")
#$NEWHost = Get-VMHost -Name (Read-Host "Please enter the name of the server to configure as seen in the VI Client:")

#$BASEHost |Get-VirtualSwitch |Foreach {
#   If (($NEWHost |Get-VirtualSwitch -Name $_.Name-ErrorAction SilentlyContinue)-eq $null){
#       Write-Host "Creating Virtual Switch $($_.Name)"
#       $NewSwitch = $NEWHost |New-VirtualSwitch -Name $_.Name-NumPorts $_.NumPorts-Mtu $_.Mtu
#       $vSwitch = $_
#    }
#   $_ |Get-VirtualPortGroup |Foreach {
#       If (($NEWHost |Get-VirtualPortGroup -Name $_.Name-ErrorAction SilentlyContinue)-eq $null){
#           Write-Host "Creating Portgroup $($_.Name)"
#           $NewPortGroup = $NEWHost |Get-VirtualSwitch -Name $vSwitch |New-VirtualPortGroup -Name $_.Name-VLanId $_.VLanID
#        }
#    }
#}

