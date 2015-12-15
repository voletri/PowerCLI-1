[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 

$cluster = Read-Host "Enter Cluster"
$datastores = Get-Cluster $cluster | Get-Datastore | Select Name
$vm = Read-Host "Enter desired VM"

###############################################
###       Creating Form for Input           ###
###############################################

$objForm = New-Object System.Windows.Forms.Form 
$objForm.Text = "Select a Computer"
$objForm.Size = New-Object System.Drawing.Size(300,200) 
$objForm.StartPosition = "CenterScreen"

$objForm.KeyPreview = $True
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
    {$x=$objListBox.SelectedItem;$objForm.Close()}})
$objForm.Add_KeyDown({if ($_.KeyCode -eq "Escape") 
    {$objForm.Close()}})

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Size(75,140)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = "OK"
$OKButton.Add_Click({$x=$objListBox.SelectedItem;$objForm.Close()})
$objForm.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Size(150,140)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click({$objForm.Close()})
$objForm.Controls.Add($CancelButton)

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,40) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "Please select a datastore:"
$objForm.Controls.Add($objLabel) 

$objLabel = New-Object System.Windows.Forms.Label
$objLabel.Location = New-Object System.Drawing.Size(10,20) 
$objLabel.Size = New-Object System.Drawing.Size(280,20) 
$objLabel.Text = "VM Name: $vm"
$objForm.Controls.Add($objLabel) 


$objListBox = New-Object System.Windows.Forms.ListBox 
$objListBox.Location = New-Object System.Drawing.Size(10,60) 
$objListBox.Size = New-Object System.Drawing.Size(260,20) 
$objListBox.Height = 80

ForEach($ds in $datastores){
    [void] $objListBox.Items.Add($ds)
    }

<#
[void] $objListBox.Items.Add("atl-dc-001")
[void] $objListBox.Items.Add("atl-dc-002")
[void] $objListBox.Items.Add("atl-dc-003")
[void] $objListBox.Items.Add("atl-dc-004")
[void] $objListBox.Items.Add("atl-dc-005")
[void] $objListBox.Items.Add("atl-dc-006")
[void] $objListBox.Items.Add("atl-dc-007")
#>

$objForm.Controls.Add($objListBox) 

$objForm.Topmost = $True

$objForm.Add_Shown({$objForm.Activate()})
[void] $objForm.ShowDialog()

###################################
###       Ending Form           ###
###################################

$x