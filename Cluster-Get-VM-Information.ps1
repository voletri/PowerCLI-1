Get-Cluster | Select Name | Export-Csv C:\cl.txt -NoTypeInformation -UseCulture

Import-Csv C:\cl.txt -UseCulture | %{
    $cl=$_.Name
    Get-VM -Location (Get-Cluster -Name $cl) |
    Select-Object  @{N="Cluster";E={$cl}},
        @{Expression="VMHost"; Label="ESXi Host"},
        @{Expression="Name"; Label="VM"},
        @{Expression="Numcpu"; Label="vCPU"},
        @{Expression="MemoryGB"; Label="RAM(GB)"},
        @{ n="Volume provisionne"; e={[math]::round( $_.ProvisionedSpaceGB, 2 )}},
        @{ n="Volume utilise"; e={[math]::round( $_.UsedSpaceGB, 2 )}} |
#        @{N="IOPS/Ecriture"; E={[math]::round((Get-Stat $_ -stat "datastore.numberWriteAveraged.average" -RealTime | Select -Expand Value | measure -average).Average, 1)}},
#        @{N="IOPS/Lecture"; E={[math]::round((Get-Stat $_ -stat "datastore.numberReadAveraged.average" -RealTime | Select -Expand Value | measure -average).Average, 1)}} |
    Export-Csv -NoTypeInformation -UseCulture "C:\vm_report_$($cl).csv"
}