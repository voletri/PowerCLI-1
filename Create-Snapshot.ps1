#: Andru Estes
#: November 2015

# Create a new snapshot of a desired VM.
# Script defaults are:  Quiescing filesystem = True	|| Memory snapshot = False.

Write-Host ""
Write-Host "Checking if connected to vCenter..." -Foreground "Yellow"


if ($Global:DefaultVIServers.count -eq 0){
	Write-Host "You are not connected, connecting now..." -Foreground "Yellow"
	Write-Host ""
	# Setting desired vCenter, user name, and secured password.
	$viServer = Read-Host "Enter vCenter Server"
	$user = Read-Host "Enter user name"
	$securePassword = Read-Host -Prompt "Enter password" -AsSecureString
	
	# Extracting the secured password to pass into automated script as plain text.
	$BSTR = `
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword)
	$PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR) 
	
	Connect-VIServer -Server $viServer -User $user -Password $PlainPassword
}
else{
	Write-Host ""
	Write-Host "You are already connected to vCenter, proceeding..." -Foreground "Yellow"
}

Write-Host ""

$snapshotName = Read-Host "Enter snapshot name"
$vm = Read-Host "Enter the target VM"
$description = Read-Host "Enter description"

New-Snapshot -Name $snapshotName -VM $vm -Description $description -Memory:$false -Quiesce:$true
