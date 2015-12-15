############################# INFORMATION #######################################
# VMWare Capacity & Performance Report
# Marc Vincent Davoli (Find me on LinkedIn! http://ca.linkedin.com/in/marcvincentdavoli/)
# PREREQUISITES for this script: Powershell V2, PowerCLI 5.0, Microsoft Chart Controls for .NET Framework (download from this link: 
# http://www.microsoft.com/en-us/download/details.aspx?id=14422)
# INPUT for this script: vCenter server IP/hostname, vCenter server credentials, SMTP server IP/hostname
# OUTPUT for this script: E-mailed Report, Report.HTML and Attachments, 1 for each chart (in the working directory)
# Notice 1 : CPU and Memory provisioning potential is calculated by removing 1 host
# Notice 2 : Datastore space provisioning potential is calculated by removing removing 5%


############################# CHANGELOG #######################################
# February 2013		First version
# April 2013		Bugfixes, Added Per Cluster report
# July 2013			Bugfixes, Added Cluster Resilience & Provisionning Potential reports, other minor code adjustements
# January 2014		Added Consolidation ratio, ESXi Hardware & Software Information table, vCenter version, Print Computer name and script version
# May 2015			Fixed issue with Cluster charts not appearing in e-mail report, cause by a space in the cluster name

################################ CONSTANTS ######################################

Write-Host Loading...

#-------------------------CHANGE THESE VALUES--------------------------------
$SMTPServer = "omaedcmgw002.interpublic.com" #"webmail.interpublic.com"
$vCenterServerName = "test-vcsa6"
$ToAddress = "andru.estes@interpublic.com"
#$ToAddress = "destinationadress1@company.com", "destinationadress2@company.com", "destinationadress3@company.com"
#-----------------------------------------------------------------------------

$ScriptVersion = "v2.1 - Community Edition" # Included in the Runtime info in $HTMLFooter
$Subject = "VMware Capacity & Performance Report for " + $vCenterServerName
#$FromAddress = $vCenterServerName + "@interpublic.com"
$FromAddress = "andru.estes@interpublic.com"

$ColorArray = "Red", "Orange", "Purple", "Blue", "Olive", "SlateGrey", "Orange", "Purple", "Blue", "Olive"
$ColorArrayIndex = 0

$HTMLHeader = "<HTML><TITLE> VMware Capacity & Performance Report for " + $vCenterServerName + "</TITLE>"
$HTMLFooter = "Made with CPReport Script Version " + $ScriptVersion + " running on server " + $env:COMPUTERNAME + "</HTML>"

############################# GLOBAL VARIABLES ####################################

$global:ArrayOfNames = @()
$global:ArrayOfValues = @()
$Attachments = @()


############################## PREPROCESSING ####################################

Write-Host Preprocessing...

# Create a folder for temporary image files
#IF ((Test-Path -path .\Temp) -ne $True) {$TempFolder = New-Item .\Temp -type directory} else {$TempFolder = ".\Temp"}


Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Connect-VIServer $vCenterServerName

$DC = Get-Datacenter | Sort-Object -Property Name #| Select-Object -First 2
$Clusters = Get-Cluster | Sort-Object -Property Name #| Select-Object -First 1
$VMHosts = Get-VMHost | Sort-Object -Property Name #| Select-Object -First 1
$VM = Get-VM | Sort-Object -Property Name #| Select-Object -First 2
$Datastores = Get-Datastore | Sort-Object -Property Name #| Select-Object -First 1
$Templates = Get-Template | Sort-Object -Property Name #| Select-Object -First 2
$ResourcePools = Get-ResourcePool | Sort-Object -Property Name #| Select-Object -First 2
$Snapshots = $VM | Get-Snapshot #| Select-Object -First 2
$Date = Get-Date | Sort-Object -Property Name #| Select-Object -First 2

################################ FUNCTIONS ######################################

Function GetTotalCPUCyclesInGhz ($VMHostsTemp) {

	$TotalCPUCyclesInGHz = $VMHostsTemp | Measure-Object -Property CpuTotalMhz -Sum # Count total CPU in Mhz
	$TotalCPUCyclesInGHz = $TotalCPUCyclesInGHz.Sum -as [int] # Convert from String to Int
	$TotalCPUCyclesInGHz = $TotalCPUCyclesInGHz / 1000 # Divide by 1000 to convert from MHz to GHz
	$TotalCPUCyclesInGHz = [system.math]::ceiling($TotalCPUCyclesInGHz) # Round down
	return $TotalCPUCyclesInGHz
}

Function GetTotalNumberofCPUs ($VMHostsTemp){

	$TotalCPU = $VMHostsTemp | Measure-Object -Property NumCpu -Sum # Count total RAM in MB
	$TotalCPU = $TotalCPU.Sum
	return $TotalCPU
}

Function GetTotalMemoryInGB ($VMHostsTemp){

	$TotalRAMinGB = $VMHostsTemp | Measure-Object -Property MemoryTotalMB -Sum # Count total RAM in MB
	$TotalRAMinGB = $TotalRAMinGB.Sum -as [int] # Convert from String to Int
	$TotalRAMinGB = $TotalRAMinGB / 1024 # Divide by 1024 to convert from MB to GB
	$TotalRAMinGB = [system.math]::ceiling($TotalRAMinGB) # Round down
	return $TotalRAMinGB
}

Function GetTotalDatastoreDiskSpaceinGB ($DatastoresTemp) {

	$TotalDatastoreDiskSpaceinGB = $DatastoresTemp | Measure-Object -Property FreeSpaceMB -Sum # Count total  MB
	$TotalDatastoreDiskSpaceinGB = $TotalDatastoreDiskSpaceinGB.Sum -as [int] # Convert from String to Int
	$TotalDatastoreDiskSpaceinGB = $TotalDatastoreDiskSpaceinGB / 1024 # Divide by 1024 to convert from MB to GB
	$TotalDatastoreDiskSpaceinGB = [system.math]::ceiling($TotalDatastoreDiskSpaceinGB) # Round down
	return $TotalDatastoreDiskSpaceinGB
}


Function GetVMHostMemoryinGB ($vmhosttemp){

	$TempVMHostRAMinGB = $vmhosttemp.MemoryTotalMB -as [int] # Convert from String to Int
	$TempVMHostRAMinGB = $TempVMHostRAMinGB / 1024 # Divide by 1024 to convert from MB to GB
	$TempVMHostRAMinGB = [system.math]::ceiling($TempVMHostRAMinGB) # Round down
	return $TempVMHostRAMinGB
}

Function GetVMHostAverageCPUUsagePercentage ($vmhosttemp) { #For the last 30 days

	$AverageCPUUsagePercentage = Get-Stat -Entity ($vmhosttemp)-start (get-date).AddDays(-30) -Finish (Get-Date)-MaxSamples 31 -stat cpu.usage.average
	$AverageCPUUsagePercentage = $AverageCPUUsagePercentage | Measure-Object -Property value -Average
	$AverageCPUUsagePercentage = $AverageCPUUsagePercentage.Average	
	$AverageCPUUsagePercentage = [system.math]::ceiling($AverageCPUUsagePercentage) # Round up
	return $AverageCPUUsagePercentage
}

Function GetVMHostAverageMemoryUsagePercentage ($vmhosttemp) { #For the last 30 days

	$AverageMemoryUsagePercentage = Get-Stat -Entity ($vmhosttemp)-start (get-date).AddDays(-30) -Finish (Get-Date)-MaxSamples 31 -stat mem.usage.average
	$AverageMemoryUsagePercentage = $AverageMemoryUsagePercentage | Measure-Object -Property value -Average
	$AverageMemoryUsagePercentage = $AverageMemoryUsagePercentage.Average	
	$AverageMemoryUsagePercentage = [system.math]::ceiling($AverageMemoryUsagePercentage) # Round up
	return $AverageMemoryUsagePercentage
}

Function GetDatastoreCurrentDiskSpaceUsagePercentage ($DatastoreTemp) {

	$DatastoreFreeSpaceinMB = $DatastoreTemp.FreeSpaceMB -as [int]
	$DatastoreCapacityinMB= $DatastoreTemp.CapacityMB -as [int]
	$DatastoreCurrentDiskSpaceUsagePercentage = 100 - ($DatastoreFreeSpaceinMB / $DatastoreCapacityinMB *100)
	$DatastoreCurrentDiskSpaceUsagePercentage = [system.math]::ceiling($DatastoreCurrentDiskSpaceUsagePercentage) # Round up
	return $DatastoreCurrentDiskSpaceUsagePercentage
}


Function GetDatastoreCapacityinGB ($DatastoreTemp) {

	$DatastoreCapacityinGB = $DatastoreTemp.CapacityMB -as [int]
	$DatastoreCapacityinGB = $DatastoreCapacityinGB / 1024 # Divide by 1024 to convert from MB to GB
	$DatastoreCapacityinGB = [system.math]::ceiling($DatastoreCapacityinGB) # Round up
	return $DatastoreCapacityinGB
}

Function GetNumberofVMsInDatastore ($DatastoreTemp) {
	$DatastoreTemp = $DatastoreTemp | Get-VM | Measure-Object | Select-Object Count
	return $DatastoreTemp.Count
}

Function GetDatastoreAllocationPercentage ($DatastoreTemp) {
	$DatastoreTemp = $DatastoreTemp | Get-View
	$DSAllocationTemp = [math]::round(((($DatastoreTemp.Summary.Capacity - $DatastoreTemp.Summary.FreeSpace)`
						+ $DatastoreTemp.Summary.Uncommitted)*100)/$DatastoreTemp.Summary.Capacity,0)
	return $DSAllocationTemp
}

Function GetVMHostCurrentMemoryUsagePercentage ($vmhosttemp) {

	$MemoryUsageinMhz = $vmhosttemp.MemoryUsageMB -as [int]
	$MemoryTotalinMhz = $vmhosttemp.MemoryTotalMB -as [int]
	$MemoryUsagePercentage = $MemoryUsageinMhz / $MemoryTotalinMhz *100
	$MemoryUsagePercentage = [system.math]::ceiling($MemoryUsagePercentage) # Round up
	return $MemoryUsagePercentage
}


Function GetVMHostCurrentCPUUsagePercentage ($vmhosttemp) {

	$CPUUsageinMhz = $vmhosttemp.CpuUsageMhz -as [int]
	$CPUTotalinMhz = $vmhosttemp.CpuTotalMhz -as [int]
	$CPUUsagePercentage = $CPUUsageinMhz / $CPUTotalinMhz *100
	$CPUUsagePercentage = [system.math]::ceiling($CPUUsagePercentage) # Round up
	return $CPUUsagePercentage
}

Function GetVMAverageCPUUsage ($VMsTemp) {
	
	$AverageVMCPUUsage = Get-Stat -Entity ($VMsTemp) -MaxSamples 1 -stat cpu.usagemhz.average
	$AverageVMCPUUsage = $AverageVMCPUUsage | Measure-Object -Property value -Average
	$AverageVMCPUUsage = $AverageVMCPUUsage.Average	
	#$AverageVMCPUUsage = $AverageVMCPUUsage / 1000 # Divide by 1000 to convert from MHz to GHz # VALUE NOT HIGH ENOUGH
	$AverageVMCPUUsage = [system.math]::ceiling($AverageVMCPUUsage) # Round up
	return $AverageVMCPUUsage
}

Function GetVMAverageMemoryUsage ($VMsTemp) {
	
	$TotalVMMemoryinMB = $VMsTemp | Measure-Object -Property MemoryMB -Sum # Count total RAM in MB
	$TotalVMMemoryinMB = $TotalVMMemoryinMB.Sum -as [int] # Convert from String to Int
	#$TotalVMMemoryinGB = $TotalVMMemoryinMB / 1024 # Divide by 1024 to convert from MB to GB # VALUE NOT HIGH ENOUGH
	$AverageVMMemoryInGB = $TotalVMMemoryinMB / $VMsTemp.Length # Divide by number of VMs
	$AverageVMMemoryInGB = [system.math]::ceiling($AverageVMMemoryInGB) # Round down
	return $AverageVMMemoryInGB
}

Function GetVMAverageDatastoreUsage ($VMsTemp) {
	
	$TotalVMProvisionedSpaceinGB = $VMsTemp | Measure-Object -Property ProvisionedSpaceGB -Sum # Count total RAM in MB
	$TotalVMProvisionedSpaceinGB = $TotalVMProvisionedSpaceinGB.Sum -as [int] # Convert from String to Int
	$VMAverageDatastoreUsage = $TotalVMProvisionedSpaceinGB / $VMsTemp.Length # Divide by number of VMs
	$VMAverageDatastoreUsage = [system.math]::ceiling($VMAverageDatastoreUsage) # Round up
	return $VMAverageDatastoreUsage
}

Function GetVMTotalMemory ($VMsTemp) {

	$VMTotalMemory = $VMsTemp | Measure-Object -Property MemoryMB -Sum
	$VMTotalMemory = $VMTotalMemory.Sum / 1024 # Divide by 1024 to convert from MB to GB
	$VMTotalMemory = [system.math]::ceiling($VMTotalMemory)
	return $VMTotalMemory
}

Function GetVMTotalCPUs ($VMsTemp) {

	$VMTotalCPUs = $VMsTemp  | Measure-Object -Property NumCpu -Sum
	return $VMTotalCPUs.Sum
}


Function GetCPUSlotsAvailable ($VMHostsInClusterTemp, $ClusterVMAverageCPUUsageTemp) {
	
	$VMHostsTotalCPUMhz = $VMHostsInClusterTemp | Measure-Object -Property CpuTotalMhz -Sum 
	$VMHostsUsedCPUMhz = $VMHostsInClusterTemp | Measure-Object -Property CpuUsageMhz -Sum 
	$VMHostsTotalCPUMhz = $VMHostsTotalCPUMhz.Sum * 0.90 # Keep 10% available for best practice
	$VMHostsUsedCPUMhz = $VMHostsUsedCPUMhz.Sum
	$VMHostsAvailableCPUMhz = $VMHostsTotalCPUMhz - $VMHostsUsedCPUMhz
	$ClusterCPUSlots = $VMHostsAvailableCPUMhz / $ClusterVMAverageCPUUsageTemp # The rest divided by 1 CPU Slot
	$ClusterCPUSlots = [system.math]::floor($ClusterCPUSlots) # Round down
	return $ClusterCPUSlots
}



Function GetMemorySlotsAvailable ($VMHostsInClusterTemp, $ClusterVMAverageMemoryUsageTemp) {
	
	$VMHostsTotalMemoryMB = $VMHostsInClusterTemp | Measure-Object -Property MemoryTotalMB -Sum 
	$VMHostsUsedMemoryMB = $VMHostsInClusterTemp | Measure-Object -Property MemoryUsageMB -Sum 
	$VMHostsTotalMemoryMB = $VMHostsTotalMemoryMB.Sum * 0.90 # Keep 10% available for best practice
	$VMHostsUsedMemoryMB = $VMHostsUsedMemoryMB.Sum
	$VMHostsAvailableMemoryMB = $VMHostsTotalMemoryMB - $VMHostsUsedMemoryMB
	$ClusterMemorySlots = $VMHostsAvailableMemoryMB / $ClusterVMAverageMemoryUsageTemp # The rest divided by 1 Memory Slot
	$ClusterMemorySlots = [system.math]::floor($ClusterMemorySlots) # Round down
	return $ClusterMemorySlots
}


Function GetDatastoreSlotsAvailable ($DatastoresInClusterTemp, $ClusterVMAverageMemoryUsageTemp) {
	
	# Remove 5% of Datastore capacity for Best Practices
	$DatastoreCapacityTemp = $DatastoresInClusterTemp | Measure-Object -Property CapacityMB -Sum
	$DatastoreCapacityMinus5Percent = $DatastoreCapacity.Sum * 0.95
	$5PercentOfDatastoreCapacity = $DatastoreCapacity.Sum - $DatastoreCapacityMinus5Percent
	$DatastoreFreeSpaceMB = $DatastoreFreeSpaceMB - $5PercentOfDatastoreCapacity
	
	$DatastoreFreeSpaceMB = $DatastoresInClusterTemp | Measure-Object -Property FreeSpaceMB -Sum
	$DatastoreFreeSpaceMB = $DatastoreFreeSpaceMB.Sum / 1024 # Divide by 1024 to convert from MB to GB
	$DatastoreFreeSpaceMB = $DatastoreFreeSpaceMB - $5PercentOfDatastoreCapacity # Keep 5% available for best practice
	$ClusterDatastoreSlots = $DatastoreFreeSpaceMB / $ClusterVMAverageMemoryUsageTemp # Divided by 1 Memory Slot
	$ClusterDatastoreSlots = [system.math]::floor($ClusterDatastoreSlots) # Round down
	return $ClusterDatastoreSlots
}

Function GetVMProvisioningPotential ($CPUSLOTS, $MEMORYSLOTS, $DATASTORESLOTS) {
	
	if ($CPUSLOTS -le $MEMORYSLOTS -and  $CPUSLOTS -le $DATASTORESLOTS){ return ([String]$CPUSLOTS + ". CPU is your limiting factor.")}
	if ($MEMORYSLOTS -le $CPUSLOTS -and  $MEMORYSLOTS -le $DATASTORESLOTS){ return ([String]$MEMORYSLOTS + ". Memory is your limiting factor.")}
	if ($DATASTORESLOTS -le $CPUSLOTS -and  $DATASTORESLOTS -le $MEMORYSLOTS){ return ([String]$DATASTORESLOTS + ". Datastore Disk Space is your limiting factor.")}
	
}

Function CreateHeader ($text) {
	$HeaderTemp = "<hr>"
	$HeaderTemp += "<h2><b><center>" + $text + "</center></b></h2>"
	$HeaderTemp += "<hr>"
	$HeaderTemp += "<br>"
	return $HeaderTemp
}

Function ListVCenterInventory () {
	$InventoryTemp = "<h4>"
	$HostTemp = Get-VMHost | Select-Object -First 1
	$InventoryTemp += "vCenter version " + (($HostTemp | Select-Object @{N="vCenterVersion";E={$global:DefaultVIServers | where {$_.Name.ToLower() -eq ($HostTemp.ExtensionData.Client.ServiceUrl.Split('/')[2]).ToLower()} | %{"$($_.Version) Build $($_.Build)"}   }}).vCenterVersion) + "<br>"
	$InventoryTemp += [String]$DC.Count + " Datacenters <br>"
	$InventoryTemp += [String]$Clusters.Count + " Clusters <br>"
	$InventoryTemp += [String]$VMHosts.Count + " ESXi Hosts with a total of " + (GetTotalCPUCyclesInGhz ($VMHosts)) + " GHz on " + `
				 (GetTotalNumberofCPUs ($VMHosts)) + " CPUs and " + (GetTotalMemoryInGB ($VMHosts)) + " GB of RAM <br>"
	$InventoryTemp += [String]$Datastores.Count + " Datastores with a total of " + (GetTotalDatastoreDiskSpaceinGB ($Datastores)) + " GB of disk space <br>"
	$InventoryTemp += [String]$VM.Count + " Virtual Machines <br>"
	$InventoryTemp += [String]$Templates.Count + " Templates <br>"
	$InventoryTemp += [String]$ResourcePools.Count + " Resource Pools <br>"
	$InventoryTemp += [String][system.math]::floor($VM.Count / $VMHosts.Count) + ":1" + " Consolidation ratio <br>"
	$InventoryTemp += "<br>"

	$InventoryTemp += BuildESXiSoftwareAndHardwareInfoTable ($VMHosts)
	
	$InventoryTemp += "</h4>"
	return $InventoryTemp
}

Function BuildESXiSoftwareAndHardwareInfoTable ($VMHostsTemp) {
	$ESXiSoftwareAndHardwareInfoTemp = "<table border=1>"
	$ESXiSoftwareAndHardwareInfoTemp += "<tr><th colspan=6><b><center> ESXi Software and Hardware Information </center></b></th></tr>"
	$ESXiSoftwareAndHardwareInfoTemp += "<tr><td width=200><b>Host Name</b></td><td width=200><b>Server Model</b></td><td width=130><b>Number of CPUs</b></td>" `
								+ "<td width=180><b>RAM Quantity (in GB)</b></td><td width=170><b>ESXi Version</b></td><td width=80><b>Uptime</b></td></tr>"

	Write-Host "          " Gathering ESXi Hardware and Software Information...
	$ESXiSoftwareAndHardwareInfoTemp += 	$VMHostsTemp | Sort-Object name | ForEach-Object {
						"<tr><td>" + $_.Name + "</td><td>" + $_.Manufacturer + " " + $_.Model + "</td><td>" + $_.NumCpu + " CPUs </td><td>" `
						+ (GetTotalMemoryInGB ($_))	+ " GB </td><td>" + $_.Version + " Build " + $_.Build + "</td><td>" `
						+ ($_ | Get-View | select @{N="Uptime"; E={(Get-Date) - $_.Summary.Runtime.BootTime}}).Uptime.Days + " days </td>"
						}

	$ESXiSoftwareAndHardwareInfoTemp += "</table><br>"
	
	return $ESXiSoftwareAndHardwareInfoTemp
}




Function ListClusterInventory ($ClusterTemp) {

	Write-Host "          " Gathering $ClusterTemp.Name "inventory..."
	
	# Get inventory objects for this cluster only
	$VMHostsTemp = Get-Cluster $ClusterTemp.Name | Get-VMHost | Sort-Object -Property Name #| Select-Object -First 1
	$DatastoresTemp = Get-Cluster $ClusterTemp.Name | Get-VMHost | Get-Datastore | Sort-Object -Property Name #| Select-Object -First 1
	$VMTemp = Get-Cluster $ClusterTemp.Name | Get-VM | Sort-Object -Property Name #| Select-Object -First 1
	$ResourcePoolsTemp = Get-Cluster $ClusterTemp.Name | Get-ResourcePool | Sort-Object -Property Name #| Select-Object -First 1
	
	
	$InventoryTemp = "<h4>"
	$InventoryTemp += [String]$VMHostsTemp.Count + " ESXi Hosts with a total of " + (GetTotalCPUCyclesInGhz ($VMHostsTemp)) + " GHz on " + `
				 (GetTotalNumberofCPUs ($VMHostsTemp)) + " CPUs and " + (GetTotalMemoryInGB ($VMHostsTemp)) + " GB of RAM <br>"
	$InventoryTemp += [String]$DatastoresTemp.Count + " Datastores with a total of " + (GetTotalDatastoreDiskSpaceinGB ($DatastoresTemp)) + " GB of disk space <br>"
	$InventoryTemp += [String]$VMTemp.Count + " Virtual Machines <br>"
	$NbOfResourcePoolsTemp = $ResourcePoolsTemp | Measure-Object; 
	$InventoryTemp += [String]$NbOfResourcePoolsTemp.Count + " Resource Pools <br>"
	$InventoryTemp += [String][system.math]::floor($VMTemp.Count / $VMHostsTemp.Count) + ":1" + " Consolidation ratio <br>"
	$InventoryTemp += "<br>"
	$InventoryTemp += BuildESXiSoftwareAndHardwareInfoTable ($VMHostsTemp)
	
	$InventoryTemp += "</h4>"
	return $InventoryTemp
}

Function ReinitializeArrays (){ #Reinitialize variables for reuse
	Clear-Variable -Name ArrayOfNames
	Clear-Variable -Name ArrayOfValues
	$global:ArrayOfNames = @()
	$global:ArrayOfValues = @()
}

Function CreateVMHostCPUUsageTable ($VMHostsTemp){ # Builds CPU HTML Table and populates Arrays used to create chart

	$CPUTableTemp = "<table border=1>"
	$CPUTableTemp += "<tr><th colspan=4><b><center> ESXi Host CPU Usage Statistics </center></b></th></tr>"
	$CPUTableTemp += "<tr><td width=200><b>Host Name</b></td><td width=130><b>Number of CPUs</b></td><td width=200><b>Current CPU Usage %</b></td>" `
				 + "<td width=250><b>Monthly Average CPU Usage %</b></td></tr>"

	$CPUTableTemp += 	$VMHostsTemp | Sort-Object name | ForEach-Object {
						Write-Host "          " Gathering $_.Name "CPU usage statistics..."
						$tempVMHostAverageCPUUsagePercentage = (GetVMHostAverageCPUUsagePercentage $_)
						"<tr><td>" + $_.name + " </td><td>" + $_.NumCpu + " CPUs </td><td> " + (GetVMHostCurrentCPUUsagePercentage $_) `
						+ "% </td><td>" + ($tempVMHostAverageCPUUSagePercentage) + "% </td>"
						$global:ArrayOfNames += $_.Name
						$global:ArrayOfValues += ($tempVMHostAverageCPUUSagePercentage)
						}

	$CPUTableTemp += "</table>"
	return $CPUTableTemp
}

Function CreateVMHostMemoryUsageTable ($VMHostsTemp){ # Builds Memory HTML Table and populates Arrays used to create chart
	$MemoryTableTemp = "<table border=1>"
	$MemoryTableTemp += "<tr><th colspan=4><b><center> ESXi Host Memory Usage Statistics </center></b></th></tr>"
	$MemoryTableTemp += "<tr><td width=200><b>Host Name</b></td><td width=200><b>RAM Quantity (in GB)</b></td><td width=200><b>Current Memory Usage % " `
				 + "</b></td><td width=250><b>Monthly Average Memory Usage %</b></td></tr>"



	$MemoryTableTemp += $VMHostsTemp | Sort-Object name | ForEach-Object {
						Write-Host "          " Gathering $_.Name "Memory usage statistics..."
						$tempVMHostAverageMemoryUsagePercentage = (GetVMHostAverageMemoryUsagePercentage $_)
						"<tr><td>" + $_.name + " </td><td>" + (GetVMHostMemoryinGB $_) + " GB </td><td> " + (GetVMHostCurrentMemoryUsagePercentage $_) `
						+ "% </td><td>" + ($tempVMHostAverageMemoryUsagePercentage) + "% </td>"
						$global:ArrayOfNames += $_.Name
						$global:ArrayOfValues += ($tempVMHostAverageMemoryUsagePercentage)
						}
				
				
	$MemoryTableTemp += "</table>"
	return $MemoryTableTemp
}

Function CreateDatastoreUsageTable ($DatastoresTemp){ # Builds Datastore HTML Table and populates Arrays used to create chart

	$DatastoreTableTemp += "<table border=1>"
	$DatastoreTableTemp += "<tr><th colspan=5><b><center> Datastore Usage Statistics </center></b></th></tr>"
	$DatastoreTableTemp += "<tr><td width=300><b>Datastore Name</b></td><td width=200><b>Total Disk Space (in GB)</b></td>" `
				 + "<td><b>Current Usage % </b></td><td><b>Number of VMs contained</b></td><td><b>Commitment %</b></td></tr>"


	$DatastoreTableTemp += $DatastoresTemp | Sort-Object name | ForEach-Object {
				Write-Host "          " Gathering $_.Name "Datastore usage statistics..."
				"<tr><td>" + $_.name + " </td><td>" + (GetDatastoreCapacityinGB $_) + " GB </td><td> " + `
				(GetDatastoreCurrentDiskSpaceUsagePercentage $_) + "% </td><td>" + (GetNumberofVMsInDatastore $_)+  "</td>" `
				+ "<td>" + (GetDatastoreAllocationPercentage $_) + "% </tr>"
				
				$global:ArrayOfNames += $_.Name
				$global:ArrayOfValues += (GetDatastoreCurrentDiskSpaceUsagePercentage $_)
				}
				
				
	$DatastoreTableTemp += "</table>"
	return $DatastoreTableTemp
}

Function CreateClusterProvisioningPotentialTables ($ClusterTemp) {


	$VMsInClusterTemp = $ClusterTemp | Get-VM
	
	# Remove biggest host from collection
	$BiggestHostInCluster = $ClusterTemp | Get-VMHost | Sort-Object MemoryTotalMB -Descending | Select-Object -First 1
	$VMHostsInClusterMinusBiggest = $ClusterTemp | Get-VMHost | Where-Object {$_.Name -ne $BiggestHostInCluster.Name}
	$DatastoresInClusterMinusBiggestHosts = $VMHostsInClusterMinusBiggest | Get-Datastore
	
	$ClusterVMAverageCPUUsage = (GetVMAverageCPUUsage ($VMsInClusterTemp))
	$ClusterVMAverageMemoryUsage = (GetVMAverageMemoryUsage ($VMsInClusterTemp))
	$ClusterVMAverageDatastoreUsage = (GetVMAverageDatastoreUsage ($VMsInClusterTemp))
	
	$AvailableCPUSlotsInCluster = (GetCPUSlotsAvailable $VMHostsInClusterMinusBiggest $ClusterVMAverageCPUUsage)
	$AvailableMemorySlotsInCluster = (GetMemorySlotsAvailable $VMHostsInClusterMinusBiggest $ClusterVMAverageMemoryUsage)
	$AvailableDatastoreSlotsInCluster  = (GetDatastoreSlotsAvailable $DatastoresInClusterMinusBiggestHosts $ClusterVMAverageDatastoreUsage)
	
	# Average Usage Statistics Table
	$ClusterProvisioningTableTemp += "<table border=1 width=1000>"
	$ClusterProvisioningTableTemp += "<tr><th colspan=4><b><center> Virtual Machine Average Usage Statistics </center></b></th></tr>"
	$ClusterProvisioningTableTemp += "<tr><td><b>Total Number of VMs</b></td><td><b>Average VM CPU Usage</b></td><td><b>Average VM Memory Usage</b></td><td><b>Average VM Datastore Usage</b></td></tr>"
	$ClusterProvisioningTableTemp += "<tr><td>" + $VMsInCluster.Length + "</td><td>" + $ClusterVMAverageCPUUsage + " MHz </td><td>" + $ClusterVMAverageMemoryUsage + " MB </td><td>" + `
									 $ClusterVMAverageDatastoreUsage + " GB </td></tr>"
	$ClusterProvisioningTableTemp += "</table>"
	
	$ClusterProvisioningTableTemp += "<br>"
	
	# Available Resource Slots Table
	$ClusterProvisioningTableTemp += "<table border=1 width=1000>"
	$ClusterProvisioningTableTemp += "<tr><th colspan=4><b><center> Available Virtual Machine Resource Slots </center></b></th></tr>"
	$ClusterProvisioningTableTemp += "<tr><td>1 Slot = Average VM allocation</td><td><b>CPU Slots Available</b></td><td><b>Memory Slots Available</b></td><td><b>Datastore Slots Available</b></td></tr>"
	$ClusterProvisioningTableTemp += "<tr><td></td><td>" + $AvailableCPUSlotsInCluster + "</td><td>" + $AvailableMemorySlotsInCluster `
				  					 + "</td><td>" + $AvailableDatastoreSlotsInCluster + "</td></tr>"
	$ClusterProvisioningTableTemp += "</table>"
	
	$ClusterProvisioningTableTemp += "<br>"
	
	# Provisioning potential Table
	$ClusterProvisioningTableTemp += "<table border=1 width=1000>"
	$ClusterProvisioningTableTemp += "<tr><th colspan=4><b><center> Virtual Machine Provisioning Potential </center></b></th></tr>"
	$ClusterProvisioningTableTemp += "<tr><th colspan=4><center> <font color=red>The <u>approximate</u> number of Virtual Machines you can provision safely in this cluster is " + `
				 (GetVMProvisioningPotential $AvailableCPUSlotsInCluster $AvailableMemorySlotsInCluster $AvailableDatastoreSlotsInCluster) +  "</font>*</center></th></tr>"
	
	$ClusterProvisioningTableTemp += "<tr><th colspan=4><center>*<i>Calculations are according to CPU, Memory and Datastore disk space VM average statistics. Statistics are calculated conservatively.</i></center></th></tr>"
	$ClusterProvisioningTableTemp += "</table><br>"
	
	return $ClusterProvisioningTableTemp
 
 }
 
Function CreateClusterResilienceTable ($ClusterTemp) {

	Write-Host "          " Gathering Cluster Resilience Information for Cluster $ClusterTemp.Name

	# Get HA info
	$HAEnabled = $ClusterTemp | Select-Object HAEnabled; $HAEnabled = $HAEnabled.HAEnabled 
	$ACEnabled = $ClusterTemp | Select-Object HAAdmissionControlEnabled; $ACEnabled = $ACEnabled.HAAdmissionControlEnabled 
	$ACPolicy = "N/A" 
	$HostLossTolerance = 0
	
	# GET HA Admission Control Policy
	if ($HAEnabled -and $ACEnabled){
		
		if ((($ClusterTemp | Select-Object HAFailoverlevel).HAFailoverLevel) -eq 0){ # If protection setting is NOT a # of hosts
		
			$ClusterView = Get-View -ViewType "ClusterComputeResource" -Filter @{"Name" = $ClusterTemp.Name}
			$ACPolicyInteger = $ClusterView.configuration.dasConfig.admissionControlpolicy.cpuFailoverResourcesPercent
			$ACPolicy = [String]$ACPolicyInteger  + " % of resources reserved"
			
			
			# CHART VALUE PREPARATIONS
			$ClusterUsedMemory = ($ClusterTemp | Get-VMHost | Measure-Object MemoryUsageMB -Sum).sum
			$ClusterTotalMemory = ($ClusterTemp | Get-VMHost | Measure-Object MemoryTotalMB -Sum).sum
			$ClusterFreeMemory = $ClusterTotalMemory - $ClusterUsedMemory - $ACPolicyInteger
			$ClusterUsedMemoryPercentage = [system.math]::floor($ClusterUsedMemory * 100 / $ClusterTotalMemory)
			$ClusterFreeMemoryPercentage = [system.math]::floor($ClusterFreeMemory * 100 / $ClusterTotalMemory)
			$ClusterFreeMemoryPercentage = $ClusterFreeMemoryPercentage - $ACPolicyInteger
			
			$global:ArrayOfNames += "Used"
			$global:ArrayOfValues += $ClusterUsedMemoryPercentage
			
			$global:ArrayOfNames += "Free"
			$global:ArrayOfValues += $ClusterFreeMemoryPercentage
			
			$global:ArrayOfNames += "HA Admission Control Reservation"
			$global:ArrayOfValues += $ACPolicyInteger
			
			# Host Loss Tolerance Calculation
			$BiggestHostInCluster = $ClusterTemp | Get-VMHost | Sort-Object MemoryTotalMB -Descending | Select-Object -First 1
			$HAReservedMemory = ($ACPolicyInteger/100) * ($ClusterTemp | Get-VMHost | Measure-Object MemoryTotalMB -Sum).sum
			$HostLossTolerance = $HAReservedMemory / $BiggestHostInCluster.MemoryTotalMB
			$HostLossTolerance = [System.Math]::Round($HostLossTolerance,2)
			
			
		}else{ # If protection setting is a # of hosts
		
			$ACPolicy =  ($ClusterTemp | Select-Object HAFailoverlevel).HAFailoverLevel
			$ACPolicy = [String]$ACPolicy  + " host(s) reserved"	
			$HostLossTolerance = ($ClusterTemp | Select-Object HAFailoverlevel).HAFailoverLevel
		} 
	}
	
	# Build HTML Table
	$ClusterResilienceTableTemp += "<table border=1>"
	$ClusterResilienceTableTemp += "<tr><th colspan=3><b><center> Cluster Resilience Report </center></b></th></tr>"
	$ClusterResilienceTableTemp += "<tr><td width=300><b>HA Enabled</b></td><td width=300><b>Admission Control Enabled</b></td><td width=300><b>Admission Control Policy</b></td></tr>"
	$ClusterResilienceTableTemp += "<tr><td>" + $HAEnabled + " </td><td>" + $ACEnabled + " </td><td>" + $ACPolicy + " </td></tr>"
	$ClusterResilienceTableTemp += "<tr><th colspan=3><b><font color=red><center> This cluster can survive the loss of approximately " + $HostLossTolerance + " host(s)</center></font></b></th></tr>"
	$ClusterResilienceTableTemp += "</table><br>"
	
	return $ClusterResilienceTableTemp


}

Function CreateVirtualMachineOSTable ($VMsTemp){ # Builds VM HTML Table and populates Arrays used to create chart

	Write-Host "          " Collecting Virtual Machine Guest OS information...

	# Calculate how many of each Guest OS
	$NumberOfWindowsVMs = $VMsTemp | Where-Object {$_.Guest -like "*Windows*"} | Measure-Object
	$NumberOfWindowsVMs = $NumberOfWindowsVMs.Count
	$NumberOfLinuxVMs = $VMsTemp | Where-Object {$_.Guest -like "*inux*" -OR $_.Guest -like "*nix*"} | Measure-Object
	$NumberOfLinuxVMs = $NumberOfLinuxVMs.Count
	$NumberOfOtherVMs = [int]$VMsTemp.Length - ([int]$NumberOfWindowsVMs + [int]$NumberOfLinuxVMs)

	# Build HTML Table
	$VMTableTemp += "<table border=1>"
	$VMTableTemp += "<tr><th colspan=2><b><center> Virtual Machine Guest OS Breakdown </center></b></th></tr>"
	$VMTableTemp += "<tr><td width=200><b>Operating System Type</b></td><td width=200><b>Number of VMs</b></td></tr>"
	$VMTableTemp += "<tr><td> Windows </td><td>" + $NumberOfWindowsVMs + " </td></tr>"
	$VMTableTemp += "<tr><td> Linux/Unix </td><td>" + $NumberOfLinuxVMs + " </td></tr>"
	$VMTableTemp += "<tr><td> Other </td><td>" + $NumberOfOtherVMs + " </td></tr>"			
	$VMTableTemp += "<tr><td> TOTAL </td><td>" + $VMsTemp.Length + " </td></tr>"			
	$VMTableTemp += "</table><br>"
	
	# Populate Arrays to create Chart
	$global:ArrayOfNames += "Windows"
	$global:ArrayOfNames += "Linux/Unix"
	$global:ArrayOfNames += "Other"
	$global:ArrayOfValues += $NumberOfWindowsVMs
	$global:ArrayOfValues += $NumberOfLinuxVMs
	$global:ArrayOfValues += $NumberOfOtherVMs
	
	return $VMTableTemp
}

# Credit to Sean from Shogun Tech :
#http://www.shogan.co.uk/vmware/generating-graphical-charts-with-vmware-powercli-powershell/
Function Create-Chart() {
	
	Param(
	    [String]$ChartType,
		[String]$ChartTitle,
	    [String]$FileName,
		[String]$XAxisName,
	    [String]$YAxisName,
		[Int]$ChartWidth,
		[Int]$ChartHeight,
		[String[]]$NameArray, #Added by MVD
		[Int[]]$ValueArray #Added by MVD
	)
		
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
	[void][Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms.DataVisualization")
	
	Write-Host "          " Creating chart...
	
	#Create our chart object 
	$Chart = New-object System.Windows.Forms.DataVisualization.Charting.Chart 
	$Chart.Width = $ChartWidth
	$Chart.Height = $ChartHeight
	$Chart.Left = 10
	$Chart.Top = 10

	#Create a chartarea to draw on and add this to the chart 
	$ChartArea = New-Object System.Windows.Forms.DataVisualization.Charting.ChartArea
	$Chart.ChartAreas.Add($ChartArea) 
	[void]$Chart.Series.Add("Data") 

	$Chart.ChartAreas[0].AxisX.Interval = "1" #Set this to 1 (default is auto) and allows all X Axis values to display correctly
	$Chart.ChartAreas[0].AxisX.IsLabelAutoFit = $false;
	$Chart.ChartAreas[0].AxisX.LabelStyle.Angle = "-45"
	
	#Add the Actual Data to our Chart
	$Chart.Series["Data"].Points.DataBindXY($NameArray, $ValueArray) #Modified by MVD

	if (($ChartType -eq "Pie") -or ($ChartType -eq "pie")) {
		$ChartArea.AxisX.Title = $XAxisName
		$ChartArea.AxisY.Title = $YAxisName
		$Chart.Series["Data"].ChartType = [System.Windows.Forms.DataVisualization.Charting.SeriesChartType]::Pie
		$Chart.Series["Data"]["PieLabelStyle"] = "Outside" 
		$Chart.Series["Data"]["PieLineColor"] = "Black" 
		$Chart.Series["Data"]["PieDrawingStyle"] = "Concave" 
		#($Chart.Series["Data"].Points.FindMaxByValue())["Exploded"] = $true
		$Chart.Series["Data"].Label = "#VALX = #VALY\n" # Give an X & Y Label to the data in the plot area (useful for Pie graph) 
		#(Display both axis labels, use: Y = #VALY\nX = #VALX)
	}
	
	elseif (($ChartType -eq "Bar") -or ($ChartType -eq "bar")) {
		#$Chart.Series["Data"].Sort([System.Windows.Forms.DataVisualization.Charting.PointSortOrder]::Descending, "Y")
		$ChartArea.AxisX.Title = $XAxisName
		$ChartArea.AxisY.Title = $YAxisName
		# Find point with max/min values and change their colour
		$maxValuePoint = $Chart.Series["Data"].Points.FindMaxByValue()
		$maxValuePoint.Color = [System.Drawing.Color]::Red
		$minValuePoint = $Chart.Series["Data"].Points.FindMinByValue()
		$minValuePoint.Color = [System.Drawing.Color]::Green
		# make bars into 3d cylinders
		$Chart.Series["Data"]["DrawingStyle"] = "Cylinder"
		$Chart.Series["Data"].Label = "#VALY" # Give a Y Label to the data in the plot area (useful for Bar graph)
	}
	
	else {
		Write-Host "No Chart Type was defined. Try again and enter either Pie or Bar for the ChartType Parameter. " `
					"The chart will be created as a standard Bar Graph Chart for now." -ForegroundColor Cyan
	}

	#Set the title of the Chart to the current date and time 
	$Title = new-object System.Windows.Forms.DataVisualization.Charting.Title 
	$Chart.Titles.Add($Title) 
	$Chart.Titles[0].Text = $ChartTitle

	#Save the chart to a file
	$FullPath = ((Get-Location).Path + "\" + $FileName + ".png")
	$Chart.SaveImage($FullPath,"png")
	#Write-Host "Chart saved to $FullPath" -ForegroundColor Green

	#return $FullPath

}

################################################# OUTPUT ##########################################################

######################## INVENTORY ############################

Write-Host Step 1/6 - Collecting inventory...

$HTMLBody = "<BODY>"
$HTMLBody += "$Date<br>"
$HTMLBody += "<h1><b><center>VMWare Capacity & Performance Report for " + $vCenterServerName + "</center></b></h1>"

$HTMLBody += CreateHeader ("INVENTORY FOR <font color=green><b> vCENTER " + $vCenterServerName + "</font></b>")
$HTMLBody += ListVCenterInventory
$HTMLBody += 


######################## vCenter CPU CAPACITY REPORT ############################

Write-Host Step 2/6 - Collecting CPU statistics...

# HEADER
$HTMLBody += CreateHeader ("CPU CAPACITY REPORT FOR <font color=green><b> vCENTER " + $vCenterServerName + "</font></b>")

# INTRO TEXT
$HTMLBody += "<b>" + [String]$VMHosts.Count + " ESXi Hosts with a total of " + (GetTotalCPUCyclesInGhz ($VMHosts)) + " GHz on " +
			(GetTotalNumberofCPUs ($VMHosts)) + " CPUs </b><br><br>"

# TABLE
$HTMLBody += CreateVMHostCPUUsageTable ($VMHosts)

# CHART
Create-Chart -ChartType Bar -ChartTitle "Monthly Average Host CPU Usage Percentage" -FileName ("vCenter_CPU_Usage") -ChartWidth 750 `
-ChartHeight 650 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
$HTMLBody += "<IMG SRC=vCenter_CPU_Usage.png>"
$Attachments += "vCenter_CPU_Usage.png"

# CLEANUP
ReinitializeArrays

 
######################## vCenter MEMORY CAPACITY REPORT ############################

Write-Host Step 3/6 - Collecting Memory information...
# HEADER
$HTMLBody += CreateHeader ("MEMORY CAPACITY REPORT FOR <font color=green><b> vCENTER " + $vCenterServerName + "</font></b>")

# INTRO TEXT
$HTMLBody += "<b>" + [String]$VMHosts.Count + " ESXi Hosts with a total of " + (GetTotalMemoryInGB ($VMHosts)) + " GB of RAM </b><br><br>"

# TABLE
$HTMLBody += CreateVMHostMemoryUsageTable ($VMHosts)

# CHART
Create-Chart -ChartType Bar -ChartTitle "Monthly Average Host Memory Usage Percentage" -FileName ("vCenter_Memory_Usage") -ChartWidth 750 `
-ChartHeight 650 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
$HTMLBody += "<IMG SRC=vCenter_Memory_Usage.png>"
$Attachments += "vCenter_Memory_Usage.png"

# CLEANUP
ReinitializeArrays


######################## vCenter DATASTORE CAPACITY REPORT ############################

Write-Host Step 4/6 - Collecting Datastore information...

# HEADER
$HTMLBody += CreateHeader ("DATASTORE CAPACITY REPORT FOR <font color=green><b> vCENTER " + $vCenterServerName + "</font></b>")

# INTRO TEXT
$HTMLBody += "<b>" + [String]$Datastores.Count + " Datastores with a total of " + (GetTotalDatastoreDiskSpaceinGB ($Datastores)) + `
			 " GB of disk space</b><br><br>"

# TABLE
$HTMLBody += CreateDatastoreUsageTable ($Datastores)

# CHART
Create-Chart -ChartType Bar -ChartTitle "Datastore Usage Percentage " -FileName ("vCenter_Datastore_Usage") -ChartWidth 1200 `
-ChartHeight 650 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
$HTMLBody += "<IMG SRC=vCenter_Datastore_Usage.png>"
$Attachments += "vCenter_Datastore_Usage.png"

# CLEANUP
ReinitializeArrays


######################## vCenter VIRTUAL MACHINE REPORT ############################

Write-Host Step 5/6 - Collecting Virtual Machine information...

# HEADER
$HTMLBody += CreateHeader ("VIRTUAL MACHINE REPORT FOR <font color=green><b> vCENTER " + $vCenterServerName + "</font></b>")

# INTRO TEXT
$HTMLBody += "<b>" + [String]$VM.Count + " Virtual Machines</b><br><br>"
		 
# TABLE
$HTMLBody += CreateVirtualMachineOSTable ($VM)

# CHART
Create-Chart -ChartType Pie -ChartTitle "VM Operating System Report" -FileName ("vCenter_VM_OS_Report") -ChartWidth 750 `
-ChartHeight 650 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
$HTMLBody += "<IMG SRC=vCenter_VM_OS_Report.png>"
$Attachments += "vCenter_VM_OS_Report.png"

# CLEANUP
ReinitializeArrays



########################  PER CLUSTER REPORT ############################

Write-Host Step 6/6 - Collecting Cluster information...

# Loop through all clusters
ForEach ($ClusterTemp in ($Clusters)){
	
	$NumberOfVMHostsInCluster = $ClusterTemp | Get-VMHost | Measure-Object
	$NumberOfVMHostsInCluster = $NumberOfVMHostsInCluster.Count
	
	If ($NumberOfVMHostsInCluster -gt 1){ #Ignore Clusters with no ESXi hosts in it
	
		Write-Host "          " Gathering $ClusterTemp.Name "usage statistics..."
		
		
		$VMHostsInCluster = $ClusterTemp | Get-VMHost
		$DatastoresInCluster = $ClusterTemp | Get-VMHost | Get-Datastore
		$VMsInCluster = $ClusterTemp | Get-VM
		
		################################# PER CLUSTER INVENTORY  ##########################
		
		# HEADER
		$HTMLBody += CreateHeader ("INVENTORY FOR <font color=" + $ColorArray[$ColorArrayIndex] + "><b> CLUSTER " + $ClusterTemp.Name + "</b></font>")
		
		# INVENTORY
		$HTMLBody += ListClusterInventory ($ClusterTemp)

		################################# PER CLUSTER CPU REPORT ##########################
		# HEADER
		$HTMLBody += CreateHeader ("CPU CAPACITY REPORT FOR <font color=" + $ColorArray[$ColorArrayIndex] + "><b> CLUSTER " + $ClusterTemp.Name + "</b></font>")

		# INTRO TEXT
		$HTMLBody += "<b>" + [String]$VMHostsInCluster.Count + " ESXi Hosts with a total of " + (GetTotalCPUCyclesInGhz ($VMHostsInCluster)) + " GHz on " +
					(GetTotalNumberofCPUs ($VMHostsInCluster)) + " CPUs </b><br><br>"

		# TABLE
		$HTMLBody += CreateVMHostCPUUsageTable ($VMHostsInCluster)

		# CHART
		Create-Chart -ChartType Bar -ChartTitle "Monthly Average Host CPU Usage Percentage" -FileName ("Cluster_" + `
		($ClusterTemp.Name -replace " ", "-") + "_CPU_Usage") -ChartWidth 750 -ChartHeight 650 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
		$HTMLBody += "<IMG SRC=Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_CPU_Usage.png>"
		$Attachments += "Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_CPU_Usage.png"

		# CLEANUP
		ReinitializeArrays
		
		################################# PER CLUSTER MEMORY REPORT ##########################
		
		# HEADER
		$HTMLBody += CreateHeader ("MEMORY CAPACITY REPORT FOR <font color=" + $ColorArray[$ColorArrayIndex] + "><b> CLUSTER " + $ClusterTemp.Name + "</b></font>")

		# INTRO TEXT
		$HTMLBody += "<b>" + [String]$VMHostsInCluster.Count + " ESXi Hosts with a total of " + (GetTotalMemoryInGB ($VMHostsInCluster)) + " GB of RAM </b><br><br>"

		# TABLE
		$HTMLBody += CreateVMHostMemoryUsageTable ($VMHostsInCluster)

		# CHART
		Create-Chart -ChartType Bar -ChartTitle "Monthly Average Host Memory Usage Percentage" -FileName ("Cluster_" + `
		($ClusterTemp.Name -replace " ", "-") + "_Memory_Usage") -ChartWidth 750 -ChartHeight 650 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
		$HTMLBody += "<IMG SRC=Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_Memory_Usage.png>"
		$Attachments += "Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_Memory_Usage.png"
		
		# CLEANUP
		ReinitializeArrays
		
		################################# PER CLUSTER DATASTORE REPORT ##########################
		
		# HEADER
		$HTMLBody += CreateHeader ("DATASTORE CAPACITY REPORT FOR <font color=" + $ColorArray[$ColorArrayIndex] + "><b> CLUSTER " + $ClusterTemp.Name + "</b></font>")

		# INTRO TEXT
		$HTMLBody += "<b>" + [String]$DatastoresInCluster.Count + " Datastores with a total of " + (GetTotalDatastoreDiskSpaceinGB ($DatastoresInCluster)) + `
					 " GB of disk space</b><br><br>"

		# TABLE
		$HTMLBody += CreateDatastoreUsageTable ($DatastoresInCluster)

		# CHART
		Create-Chart -ChartType Bar -ChartTitle "Datastore Usage Percentage " -FileName ("Cluster_" + ($ClusterTemp.Name -replace " ", "-") + `
		"_Datastore_Usage") -ChartWidth 850 -ChartHeight 650 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
		$HTMLBody += "<IMG SRC=Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_Datastore_Usage.png>"
		$Attachments += "Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_Datastore_Usage.png"

		# CLEANUP
		ReinitializeArrays
		
		
		################################# PER CLUSTER PROVISONING POTENTIAL REPORT ##########################
		
		
		# HEADER
		$HTMLBody += CreateHeader ("PROVISIONING POTENTIAL REPORT FOR <font color=" + $ColorArray[$ColorArrayIndex] + "><b> CLUSTER " + $ClusterTemp.Name + "</b></font>")

		# INTRO TEXT
		$HTMLBody += "<b>" + [String]$VMsInCluster.Length + " Virtual Machines with a total of " + (GetVMTotalCPUs ($VMsInCluster)) + " vCPUs and " + `
					(GetVMTotalMemory ($VMsInCluster)) + " GB of vRAM</b><br><br>"

		Write-Host "          " Calculating Virtual Machine Average Usage Statistics for Cluster $ClusterTemp.Name
		
		# TABLE
		$HTMLBody += CreateClusterProvisioningPotentialTables ($ClusterTemp)
		
		
		
		################################# PER CLUSTER RESILIENCE REPORT ##########################
		
		# HEADER
		$HTMLBody += CreateHeader ("CLUSTER RESILIENCE REPORT FOR <font color=" + $ColorArray[$ColorArrayIndex] + "><b> CLUSTER " + $ClusterTemp.Name + "</b></font>")

		# INTRO TEXT
		$HTMLBody += "<b>" + [String]$VMHostsInCluster.Count + " ESXi Hosts with a total of " + (GetTotalCPUCyclesInGhz ($VMHostsInCluster)) + " GHz on " +
					(GetTotalNumberofCPUs ($VMHostsInCluster)) + " CPUs and " + (GetTotalMemoryInGB ($VMHostsInCluster)) + " GB of RAM </b><br>"
		$HTMLBody += "<b>" + [String]$DatastoresInCluster.Count + " Datastores with a total of " + (GetTotalDatastoreDiskSpaceinGB ($DatastoresInCluster)) + `
					 " GB of disk space</b><br><br>"
		
		#TABLE
		$HTMLBody += CreateClusterResilienceTable ($ClusterTemp)
		
		
		# CHART
		if ($global:ArrayOfNames.count -gt 0){ # If HA Admission Control is set to a %, create a pie chart
			Create-Chart -ChartType Pie -ChartTitle "Cluster Resilience Report" -FileName ("Cluster_" + ($ClusterTemp.Name -replace " ", "-") + `
			"_Resilience_Report") -ChartWidth 850 -ChartHeight 750 -NameArray $global:ArrayOfNames -ValueArray $global:ArrayOfValues
			$HTMLBody += "<IMG SRC=Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_Resilience_Report.png>"
			$Attachments += "Cluster_" + ($ClusterTemp.Name -replace " ", "-") + "_Resilience_Report.png"
		}
			
		# CLEANUP
		ReinitializeArrays
		
		#-----------------------------------------------------------------------------------------------
		# Change the color of the Header for the next Cluster
		$ColorArrayIndex++
		
	}
}



########################### SEND REPORT BY E-MAIL #################################
$HTMLBody += "</BODY>" # Close HTML Body
$HTMLPage = $HTMLHeader + $HTMLBody + $HTMLFooter
$HTMLPage | Out-File ((Get-Location).Path + "\report.html") # Export locally to html file
Write-Host "Report has exported to HTML file " + ((Get-Location).Path + "\report.html")
Send-Mailmessage -From $FromAddress -To $ToAddress -Subject $Subject -Attachments $Attachments -BodyAsHTML -Body $HTMLPage -Priority Normal -SmtpServer $SMTPServer -UseSSL -Credential (Get-Credential)
Write-Host "Report has been sent by E-mail to " $ToAddress " from " $FromAddress

Exit