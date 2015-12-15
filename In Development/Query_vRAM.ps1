Connect-VIServer -Server 144.210.224.5 -User "ipgna\esb.service" -Password "Password1"

function Get-vRAMInfo{
  $vRAMtab = @{
    "esxEssentials"=24;
    "esxEssentialsPlus"=24;
    "esxStandard"=24;
    "esxAdvanced"=32;
    "esxEnterprise"=32;
    "esxEnterprisePlus"=48
  }

  $licMgr = Get-View LicenseManager
  $licAssignMgr = Get-View $licMgr.LicenseAssignmentManager

  $totals = @{}

  Get-VMHost | %{
    $lic = $licAssignMgr.QueryAssignedLicenses($_.Extensiondata.MoRef.Value)
    $licType = $lic[0].AssignedLicense.EditionKey
    $totalvRAM = ($vRAMtab[$licType] * $_.Extensiondata.Hardware.CpuInfo.NumCpuPackages)

    $VMs = Get-VM -Location $_
    $vmRAMConfigured = ($VMs | Measure-Object -Property MemoryMB -Sum).Sum/1KB
    $vmRAMUsed = ($VMs | where {$_.PowerState -eq "PoweredOn"} | Measure-Object -Property MemoryMB -Sum).Sum/1KB

    if($totals.ContainsKey($licType)){
      $totals[$licType].vRAMEntitled += $totalvRAM
      $totals[$licType].vRAMConfigured += $vmRAMConfigured
      $totals[$licType].vRAMUsed += $vmRAMUsed
    }
    else{
      $totals[$licType] = New-Object PSObject -Property @{
        vCenter = $defaultVIServer.Name
        LicenseType = $lic[0].AssignedLicense.Name
        vRAMEntitled = $totalvRAM
        vRAMConfigured = $vmRAMConfigured
        vRAMUsed = $vmRAMUsed
      }
    }
  }
  $totals.GetEnumerator() | %{
    New-Object PSObject -Property @{
      vCenter = $_.Value.vCenter
      LicenseType = $_.Value.LicenseType
      vRAMEntitled = $_.Value.vRAMEntitled
      vRAMConfigured = [Math]::Round($_.Value.vRAMConfigured,1)
      vRAMUsed = [Math]::Round($_.Value.vRAMUsed,1)
    }
  }
}
