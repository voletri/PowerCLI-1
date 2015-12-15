# Reset Memory and CPU Limits to unlimited.
# v.1 -- 1/27/2012 -- Eric TeKrony

Get-VM | Where-Object {($_.MemLimitMB -ne "-1") -or ($_.CpuLimitMhz -ne "-1")} | `
Get-VMResourceConfiguration | Set-VMResourceConfiguration -MemLimitMB $null -CpuLimitMhz $null

