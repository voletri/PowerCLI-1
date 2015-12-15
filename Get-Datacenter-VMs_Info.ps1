#: Author: 	Andru Estes (with PowerCLI community help)
#: Date: 	November 03, 2015
#: Use:		Takes user input for chosen datacenter and creates a VM report calculating VM Name, Datastore location, Provisioned/Used Space, and Folder.


# Seting the datacenter by using the specific DataCenter name.  
""
$dataCenter = Read-Host "Please enter the datacenter choice (OMA, CHI, LDN)"

#Check the user entered a valid dataCenter choice.  If not, it breaks them out of the script;.
if($dataCenter -eq "OMA" -or $dataCenter -eq "CHI" -or $dataCenter -eq "LDN"){
	Write-Host " "
	Write-Host "Creating CSV report under C:\ ..."
	
	Get-Datacenter -Name $dataCenter | 
	Get-VM |
	Select Name,
	@{N="Datastore";E={[string]::Join(',',(Get-Datastore -Id $_.DatastoreIdList | Select -ExpandProperty Name))}},
	@{N="UsedSpaceGB";E={[math]::Round($_.UsedSpaceGB,1)}},
	@{N="ProvisionedSpaceGB";E={[math]::Round($_.ProvisionedSpaceGB,1)}},
	@{N="Folder";E={$_.Folder.Name}} |
	Export-Csv C:\${dataCenter}-vm-report.csv -NoTypeInformation -UseCulture
}
else{
	"Sorry, that is not a valid option.  Please try the script again..."
	"The three options are: OMA, CHI, LDN"
	""
	}
	