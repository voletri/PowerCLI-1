# Import DRS rules from txt file.
# v.1 -- 1/23/2012  - Eric TeKrony

# Import DRS
ForEach ($rule in (Import-CliXml 'D:\Script_Repo\CSVs\DRS-LDNEDC4.xml')){
    New-DrsRule -Cluster (Get-Cluster -Name "LDNEDC4") `
    -Name $rule.Name -Enabled $rule.Enabled `
    -KeepTogether $rule.KeepTogether `
    -VM (Get-VM -Id $rule.VmIds)}