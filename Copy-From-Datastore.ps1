#: Andru Estes
#: December 01, 2015
#: Purpose of script is to list available datastores, allow the user to select one to copy items from and assign it drive letter 'ds:'
#: Allows the option to download files that may have a lock on them, not possible in the web client.

#########################
#	Set variables here.	#
#########################

$server = "test-vcsa6"
$user = 'administrator@vsphere.local'
$pass = 'Gn0moAr!'
$drive = "ds"

#####################
#	End variables	#
#####################

Write-Host ""
Write-Host "Checking vCenter server connection..." -Foreground "Yellow"

# Checks the current connection status and connects if needed.
if ($Global:DefaultVIServers.count -eq 0){
	Write-Host "Not connected to vCenter, connecting now..." -ForegroundColor Yellow
	Connect-VIServer -Server $server -User $user -Password $pass
}
else{
	Write-Host "Connected to vCenter already, continuing..." -Foreground "Yellow"
	Write-Host ""
}

Write-Host ""
Write-Host "=============================="
Write-Host "vCenter Server = " $Global:DefaultVIServers[0] -ForegroundColor Cyan
Write-Host "=============================="

# Listing possible datastores to use, displays Name, Free Space, and Capacity.
Write-Host ""
Write-Host "Here are the available datastores..."
Get-Datastore | Sort Name | Select Name, FreeSpaceGB, CapacityGB | FT -AutoSize

# Set datastore using input from user.
Write-Host "Enter target datastore name: " -Fore Green -NoNewLine
$targetDatastore = Read-Host
$finalDatastore = Get-Datastore $targetDatastore

# Set new PSDrive to use for copying desired files.  Set with variable at top of script.
New-PSDrive -Location $finalDatastore -Name $drive -PSProvider VimDatastore -Root "\" -Scope "Global"
sl ds:

# Providing format to save desired file.  Also serves reminder to remove the drive when done.
Write-Host "Syntax for copying file is:"
Write-Host ""
Write-Host "Copy-DatastoreItem -Item <SourceDatastoreItem(s)> [-Destination DestinationLocation] [-Force] [-Recurse] [-Confirm]" -Fore Magenta
Write-Host ""
Write-Host "!! Run 'Remove-PSDrive ds' command after you are finished !!" -ForegroundColor Red
Write-Host ""
