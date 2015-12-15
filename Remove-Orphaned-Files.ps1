function Remove-OrphanedData {
<#
.SYNOPSIS   Remove orphaned folders and VMDK files
.DESCRIPTION   The function searches orphaned folders and VMDK files
   on one or more datastores and reports its findings.
   Optionally the function removes  the orphaned folders   and VMDK files
.NOTES   Author:  Luc Dekens
.PARAMETER Datastore
   One or more datastores.
   The default is to investigate all shared VMFS datastores
.PARAMETER Delete
   A switch that indicates if you want to remove the folders
   and VMDK files
.EXAMPLE
   PS> Remove-OrphanedData -Datastore ds1
.EXAMPLE
  PS> Get-Datastore ds* | Remove-OrphanedData
.EXAMPLE
  PS> Remove-OrphanedData -Datastore $ds -Delete
#>
 
  [CmdletBinding(SupportsShouldProcess=$true)]

  param(
  [parameter(Mandatory=$true,ValueFromPipeline=$true)]
  [PSObject[]]$Datastore,
  [switch]$Delete
  )
 
  begin{
    $fldList = @{}
    $hdList = @{}
 
    $fileMgr = Get-View FileManager
  }
 
  process{
    foreach($ds in $Datastore){
      if($ds.GetType().Name -eq "String"){
        $ds = Get-Datastore -Name $ds
      }
      if($ds.Type -eq "VMFS" -and $ds.ExtensionData.Summary.MultipleHostAccess){
        Get-VM -Datastore $ds | %{
          $_.Extensiondata.LayoutEx.File | where{"diskDescriptor","diskExtent" -contains $_.Type} | %{
            $fldList[$_.Name.Split('/')[0]] = $_.Name
            $hdList[$_.Name] = $_.Name
          }
        }
        Get-Template | where {$_.DatastoreIdList -contains $ds.Id} | %{
          $_.Extensiondata.LayoutEx.File | where{"diskDescriptor","diskExtent" -contains $_.Type} | %{
            $fldList[$_.Name.Split('/')[0]] = $_.Name
            $hdList[$_.Name] = $_.Name
          }
        }
 
        $dc = $ds.Datacenter.Extensiondata
 
        $flags = New-Object VMware.Vim.FileQueryFlags
        $flags.FileSize = $true
        $flags.FileType = $true
 
        $disk = New-Object VMware.Vim.VmDiskFileQuery
        $disk.details = New-Object VMware.Vim.VmDiskFileQueryFlags
        $disk.details.capacityKb = $true
        $disk.details.diskExtents = $true
        $disk.details.diskType = $true
        $disk.details.thin = $true
 
        $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
        $searchSpec.details = $flags
        $searchSpec.Query += $disk
        $searchSpec.sortFoldersFirst = $true
 
        $dsBrowser = Get-View $ds.ExtensionData.browser
        $rootPath = "[" + $ds.Name + "]"
        $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)
        foreach($folder in $searchResult){
          if($fldList.ContainsKey($folder.FolderPath.TrimEnd('/'))){
            foreach ($file in $folder.File){
              if(!$hdList.ContainsKey($folder.FolderPath + $file.Path)){
                New-Object PSObject -Property @{
                  Folder = $folder.FolderPath
                  Name = $file.Path
                  Size = $file.FileSize
                  CapacityKB = $file.CapacityKb
                  Thin = $file.Thin
                  Extents = [string]::Join(',',($file.DiskExtents))
                }
                if($Delete){
                  If ($PSCmdlet.ShouldProcess(($folder.FolderPath + " " + $file.Path),"Remove VMDK")){
                    $dsBrowser.DeleteFile($folder.FolderPath + $file.Path)
                  }
                }
              }
            }
          }
          elseif($folder.File | where {"cos.vmdk","esxconsole.vmdk" -notcontains $_.Path}){
            $folder.File | %{
              New-Object PSObject -Property @{
                Folder = $folder.FolderPath
                Name = $_.Path
                Size = $_.FileSize
                CapacityKB = $_.CapacityKB
                Thin = $_.Thin
                Extents = [String]::Join(',',($_.DiskExtents))
              }
            }
            if($Delete){
              if($folder.FolderPath -eq $rootPath){
                $folder.File | %{
                  If ($PSCmdlet.ShouldProcess(($folder.FolderPath + " " + $_.Path),"Remove VMDK")){
                    $dsBrowser.DeleteFile($folder.FolderPath + $_.Path)
                  }
                }
              }
              else{
                If ($PSCmdlet.ShouldProcess($folder.FolderPath,"Remove Folder")){
                  $fileMgr.DeleteDatastoreFile($folder.FolderPath,$dc.MoRef)
                }
              }
            }
          }
        }
      }
    }
  }
}