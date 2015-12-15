####################################
#
#: Title: DataCenter-Get-VM-Storage
#: Author: Andru Estes.
#: Date October 27th, 2015
#
####################################

# Seting the datacenter by using the specific DataCenter name.  
# Uses user input data.

$title = "Datacenter choice..."
$message = "Which datacenter would you like to use? (Enter first letter)"

# Setting the different DataCenter options.  Letting the user choose.
$dc1 = New-Object System.Management.Automation.Host.ChoiceDescription "&OMA", "OMA"
$dc2 = New-Object System.Management.Automation.Host.ChoiceDescription "&LDN", "LDN"
$dc3 = New-Object System.Management.Automation.Host.ChoiceDescription "&CHI", "CHI"
$dcOptions = [System.Management.Automation.Host.ChoiceDescription[]]($dc1, $dc2, $dc3)
$chosenDC = $host.ui.PromptForChoice($title, $message, $dcOptions, 0)

# Using if statements to check which option the user chose, passing it to global variable vDC for later processing. 
if($chosenDC -eq "0"){
	$global:vDC = "OMA"
	}
elseif($chosenDC -eq "1"){
	$global:vDC = "LDN"
	}
elseif($chosenDC -eq "2"){
	$global:vDC = "CHI"
	}

$clusterOptions = Get-Datacenter $global:vDC | Get-Cluster

""

Write-Host "Below are your cluster choices..."

foreach($cluster in $clusterOptions){
	$cluster
}

""

$clusterChoice = Read-Host "Specify the cluster if desired, otherwise enter q"	

if($clusterChoice -ne "q"){
	Get-Datacenter -Name $global:vDC |
	Get-Cluster -Name $clusterChoice |
	Get-VM |
	Select Name,
	@{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}},
	#@{N="UsedSpaceGB";E={[math]::Round($_.UsedSpaceGB,1)}},
	@{N="ProvisionedSpaceGB";E={[math]::Round($_.ProvisionedSpaceGB,1)}},
	@{N="Folder";E={$_.Folder.Name}} |
	Export-Csv C:\${clusterChoice}-VM-Storage-report.csv -NoTypeInformation -UseCulture
	exit
}

elseif($clusterChoice -eq "q"){
	Get-Datacenter -Name $global:vDC | 
	Get-VM |
	Select Name,
	@{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}},
	#@{N="UsedSpaceGB";E={[math]::Round($_.UsedSpaceGB,1)}},
	@{N="ProvisionedSpaceGB";E={[math]::Round($_.ProvisionedSpaceGB,1)}},
	@{N="Folder";E={$_.Folder.Name}} |
	Export-Csv C:\${global:vDC}-VM-Storage-report.csv -NoTypeInformation -UseCulture
}

