# Export DRS rules to txt file.
# v.1 -- 1/23/2012  - Eric TeKrony

# Export DRS Rules
Get-Cluster -Name "LDNEDC4" | Get-DrsRule | Export-CliXml 'D:\Script_Repo\CSVs\DRS-LDNEDC4.xml'