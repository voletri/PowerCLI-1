<######################################################################
Menu-driven PowerCLI script to delete, add, and update DNS and NTP on
VMware ESXi hosts.
**Save as set-ntp.ps1
**Switch to directory ps1 is saved in and run
** MAKE SURE LOCAL SYSTEM TIME IS CORRECT!!!!
v1.0    27 February 2014:   Initial draft
v1.1	27 February 2014:	Changed menu option 1 to dark gray cause no worky.
Written By Josh Townsend
All Code provided as is and used at your own risk.
######################################################################>
$xAppName    = "set-ntpd"
[BOOLEAN]$global:xExitSession=$false

# Add PowerCLI snapin if not already loaded
if ((Get-PSSnapin -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) -eq $null ) {Add-PsSnapin VMware.VimAutomation.Core; $bSnapinAdded = $true}

# Prompt for vCenter or ESXi server
$vCenter = Read-host "Enter the name of your vCenter Server or ESXi host" 
$domain = Read-host "Domain name (leave blank if using local ESXi account)"
$user = Read-host "vCenter or ESXi user account"
$password = Read-host -Prompt "Enter password" -AsSecureString
$decodedpassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password))
Connect-VIServer $vCenter -user $domain\$user -Password $decodedpassword

#Some other connection options:
#Option 1 - Show menu of recently used ESXi or vCenter Servers
#Write-host "Choose from the list below or enter the name of your vCenter Server or ESXi Host, then enter credentials as prompted" -ForegroundColor Yellow
#Connect-VIServer -Menu $true
#option 2 - Hard code it.  This leaves your password in plain text.  Consider using the new-VICredentialStore option to securely store your credentials!
#Connect-VIServer -Server 10.10.10.10 -User root -Password vmware

$esxHosts = get-VMHost

Function Clear-DNS{
#foreach ($esx in $esxHosts) #{
#Write-Host "Deleting existing DNS servers from $esx" -ForegroundColor Green
# Get Current Values for required properties
#$currenthostname = Get-VMHost | Get-VMHostNetwork | select hostname
#$currentdomainName = Get-VMHost | Get-VMHostNetwork | select domainname

# ------- UpdateDnsConfig -------
#$config = New-Object VMware.Vim.HostDnsConfig
#$config.dhcp = $false
#$config.hostName = $currenthostname
#$config.domainName = $domainname

#$_this = Get-View -Id 'HostNetworkSystem-networkSystem'
#$_this.UpdateDnsConfig($config)
#}
    #Write-Host "Old DNS Values Cleared! Press any key to return to menu..." -ForegroundColor Green
    Write-Host "Sorry, this function not supported because we cannot delete or write null values for DNS Server Addresses using PowerCLI. `nUse the Add Additional menu option to overwrite existing DNS servers. `nPress any key to return to the menu." -ForegroundColor Magenta
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    LoadMenuSystem
   }

Function Clear-NTP{
   foreach ($esx in $esxHosts) {
     Write-Host "Deleting existing NTP servers from $esx" -ForegroundColor Green
     $existingNTParray = $esxhosts | Get-VMHostNTPServer
     Remove-VMHostNTPServer -NtpServer $existingNTParray -Confirm:$false
   }
    Write-Host "Old NTP Values Cleared! Press any key to return to menu..." -ForegroundColor Green
    $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    LoadMenuSystem
}

Function Clear-NTPDNS{
   Clear-NTP
   Clear-DNS

   Write-Host "Done!  Press any key to return to menu...." -ForegroundColor Green
   $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   LoadMenuSystem
}

Function Manual-Time{
   # First set all hosts in vCenter to use time of local system to prevent too large drift for NTP to correct
   Write-Host "Updating manual time on $esx to match local system time" -ForegroundColor Green
   $esxhosts | Where-Object {
     $t = Get-Date
     $dst = $_ | %{ Get-View $_.ExtensionData.ConfigManager.DateTimeSystem }
     $dst.UpdateDateTime((Get-Date($t.ToUniversalTime()) -format u))
    }
   Write-Host "Done!  Press any key to return to menu...." -ForegroundColor Green
   $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   LoadMenuSystem
}

Function Set-DNS{
# Prompt for Primary and Alternate DNS Servers
$dnspri = read-host "Enter Primary DNS"
$dnsalt = read-host "Enter Alternate DNS"

# Prompt for Domain
$domainname = read-host "Enter Domain Name"

foreach ($esx in $esxHosts) {

   Write-Host "Configuring DNS and Domain Name on $esx" -ForegroundColor Green
   Get-VMHostNetwork -VMHost $esx | Set-VMHostNetwork -DomainName $domainname -DNSAddress $dnspri , $dnsalt -Confirm:$false

   Write-Host "Done!  Press any key to return to menu...." -ForegroundColor Green
   $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   LoadMenuSystem
 }
}

Function Set-NTP{

#Prompt for NTP Servers
$ntpone = read-host "Enter NTP Server One"
$ntptwo = read-host "Enter NTP Server Two"

foreach ($esx in $esxHosts) {

   Write-Host "Configuring NTP Servers on $esx" -ForegroundColor Green
   Add-VMHostNTPServer -NtpServer $ntpone , $ntptwo -VMHost $esx -Confirm:$false

   Write-Host "Allow NTP queries outbound through the firewall on $esx" -ForegroundColor Green
   Get-VMHostFirewallException -VMHost $esx | where {$_.Name -eq "NTP client"} | Set-VMHostFirewallException -Enabled:$true

   Write-Host "Starting NTP service on $esx" -ForegroundColor Green
   Get-VmHostService -VMHost $esx | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService
   
   Write-Host "Configuring NTP Client Policy on $esx" -ForegroundColor Green
   Get-VMHostService -VMHost $esx | where{$_.Key -eq "ntpd"} | Set-VMHostService -policy "on" -Confirm:$false

   Write-Host "Restarting NTP Client on $esx" -ForegroundColor Green
   Get-VMHostService -VMHost $esx | where{$_.Key -eq "ntpd"} | Restart-VMHostService -Confirm:$false
   }
   Write-Host "Done!  Press any key to return to menu...." -ForegroundColor Green
   $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   LoadMenuSystem
}

Function Set-NTPDNS {
   Set-DNS
   Set-NTP
   
   Write-Host "Done!  Press any key to return to menu...." -ForegroundColor Green
   $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
   LoadMenuSystem
}

# Menu to select functions
function LoadMenuSystem() {
[int]$xMenuChoiceA = 0
[BOOLEAN]$xValidSelection=$false
while ( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 8 ){
CLS
# ------ Menu Choices -------
    Write-Host “Choose an option below to modify all ESXi hosts DNS and NTP settings.`n” -ForegroundColor Magenta
    Write-host "`t1. Delete all existing DNS Servers values (not working)" -ForegroundColor DarkGray
    Write-host "`t2. Delete all existing NTP Server values" -ForegroundColor Cyan
    Write-host "`t3. Delete all existing DNS & NTP Servers (not working)" -ForegroundColor Cyan
    Write-host "`t4. Manually set time on all hosts to match your local system time.*" -ForegroundColor Cyan
    Write-host "`t*This option prevents NTP sync problems due to large offset" -ForegroundColor Gray
    Write-host "`t5. Add additional DNS Server values**" -ForegroundColor Cyan
    Write-host "`t**This will overwrite any existing values" -ForegroundColor Gray
    Write-host "`t6. Add additional NTP Server values and set NTP to start with host.***" -ForegroundColor Cyan
    Write-host "`t***Verifyr DNS values are correct if using names instead of IPs." -ForegroundColor Gray
    Write-host "`t7. Add both NTP & DNS Server values and set NTP to start wtih host" -ForegroundColor Cyan
    Write-host "`t8. Quit and exit`n`n" -ForegroundColor Yellow
# ------ Menu Choices -------
# Get and Validate Choice
[Int]$xMenuChoiceA = read-host "Please select an option [1-8]"
if( $xMenuChoiceA -lt 1 -or $xMenuChoiceA -gt 8 ){
    Write-Host “`tInvalid Selection.`n” -Fore Red;start-Sleep -Seconds 1
   }
    
# Survey Says....

Switch( $xMenuChoiceA ){#… User has selected a valid entry.. load menu
  1{ Clear-DNS }
  2{ Clear-NTP }
  3{ Clear-NTPDNS }
  4{ Manual-Time }
  5{ Set-DNS }
  6{ Set-NTP }
  7{ set-NTPDNS }
default { $global:xExitSession=$true;break }
  }
 }
}


LoadMenuSystem
If ($xExitSession){
Exit-PSSession    #… User quit & Exit
} Else {
.\set-ntp.ps1    #… Loop the function
}