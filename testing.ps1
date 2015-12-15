$cluster = "OMAEDC"
$esxhost = Get-Cluster $cluster | Get-VMHost

$id = Read-Host "enter id"

foreach($ds in $esxhost | `
    Get-Datastore | where{$_.Type -eq "disk"} | Get-View){

    $ds.Info.Disk.Extent | %{
         if($_.DiskName -eq $id){
            Write-Host $ds.Info.Name $_.DiskName
        }
    }
}