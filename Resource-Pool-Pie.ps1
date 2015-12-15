#################################################################################
# ResourcePoolPie
#
# This script will poll look at VMs residing in a production and a test resource 
# pool and determine how to best set the custom share value in order to maintian
# a 4:1 Production:Test ratio.  Note, you must be setup in a Production and Test
# Environment inside of one cluster.  Its kind of unique to my environment and 
# may not apply to everyone elses, but feel free to change and modify what you
# need in order to make it work for you.
#
# The following variables will need to be assigned
#     
#   $vcenterserver = ip address of vcenter
#   $clustername = name of cluster containing resource pools
#   $prodname = name of production resource pool
#   $testname = name of test resource pool
#
# Created By: Mike Preston, 2011
#
#
#################################################################################


Add-PSSnapin VMware.VimAutomation.Core

# Assign appropriate values to following variables.
$vcenterserver = Read-Host "Enter vcenter server (IP or DNS)"
$clustername = Read-Host "Enter the cluster name"
$prodname = ""
$testname = ""

# establish connection to vcenter server
$connection = Connect-VIServer $vcenterserver

# get cluster information
$clus = get-Cluster -Name $clustername | get-view

# get resource pool information
$prodpool = Get-ResourcePool -Location $clustername -Name $prodname
$testpool = Get-ResourcePool -Location $clustername -Name $testname

# get a list of vms in production and test
$prodvms = get-vm -Location $prodpool | where { $_.PowerState -eq "PoweredOn" }
$testvms = get-vm -Location $testpool | where { $_.PowerState -eq "PoweredOn" }

# initialize counters to zero
$totalprodcpu = 0
$totaltestcpu = 0
$totalprodmem = 0
$totaltestmem = 0

# loop through production pool and total cpu/memory
foreach ($vm in $prodvms)
{
    $totalprodcpu = $totalprodcpu + $vm.NumCPU
    $totalprodmem = $totalprodmem + $vm.MemoryMB
}

# loop through test pool and total cpu/memory
foreach ($vm in $testvms)
{
    $totaltestcpu = $totaltestcpu + $vm.NumCPU
    $totaltestmem = $totaltestmem + $vm.MemoryMB
}

# Begin CPU calculations
Write-Host "CPU Configuration"
Write-Host "=========================================================="
write-host "Production Pool contains" $prodvms.count "Powered On VMs containing" $totalprodcpu "cpus"
write-host "Test Pool contains" $testvms.count "Powered On VMs containing" $totaltestcpu "cpus"
write-host "Cluster has" $clus.summary.effectivecpu "MHZ to hand out"

#populate variables for formula a(4w-3x) = nx

$a = $totalprodcpu
$w = $clus.summary.effectivecpu
$n = $totalprodcpu + $totaltestcpu
Write-Host ""
# lets solve x :)
Write-Host "Lets plug these numbers into our formula and solve x (Production Share)"
Write-Host "a = total number in production, w = total resources, n = total number in prod and test"
Write-Host "--------------------------------"
Write-Host "a(4w-3x) = nx) "
Write-Host "$a(4($w) - 3(x)) = $n(x)) "
# lets get some tmp vars initialized
$tmp1 = 4 * $w
Write-Host "$a($tmp1 - 3x) = $n(x)"
$tmp2 = $a * $tmp1
$tmp3 = 3 * $a
Write-Host "$tmp2 - $tmp3(x) = $n(x)"
$tmp4 = $n + $tmp3
Write-Host "$tmp4(x) = $tmp2"
$prodpoolresources = $tmp2 / $tmp4
Write-Host "x = $prodpoolresources"
Write-Host "--------------------------------"
$prodpoolresources = [Math]::Round($prodpoolresources,0)
$testpoolresources = $w - $prodpoolresources
$prodsharepercpu = $prodpoolresources / $totalprodcpu
$prodsharepercpu = [Math]::Round($prodsharepercpu,0)
$testsharepercpu = $testpoolresources / $totaltestcpu
$testsharepercpu = [Math]::Round($testsharepercpu,0)

# Display recommendations
Write-Host "Recommended Share setting for production $prodpoolresources Mhz split between" $prodvms.count "Vms with" $totalprodcpu "cpus resulting in" $prodsharepercpu "Mhz per cpu"
Write-Host "Recommended Share setting for test $testpoolresources Mhz split between" $testvms.count "Vms with" $totaltestcpu "cpus resulting in" $testsharepercpu "mhz per cpu"

# Begin calculating Memory
Write-Host "=========================================================="
Write-Host "Memory Configuration"
Write-Host "=========================================================="
write-host "Production Pool contains" $prodvms.count "Powered On VMs containing" $totalprodmem "MB of Memory"
write-host "Test Pool contains" $testvms.count "Powered On VMs containing" $totaltestmem "MB of Memory"
write-host "Cluster has" $clus.summary.effectivememory "MB of memory to hand out"

#populate variables for formula a(4w-3x) = nx

$a = $totalprodmem
$w = $clus.summary.effectivememory
$n = $totalprodmem + $totaltestmem
Write-Host ""
# lets solve x :)
Write-Host "Lets plug these numbers into our formula and solve x (Production Share)"
Write-Host "--------------------------------"
Write-Host "a(4w-3x) = nx) "
Write-Host "$a(4($w) - 3(x)) = $n(x)) "
# lets get some tmp vars initialized
$tmp1 = 4 * $w
Write-Host "$a($tmp1 - 3x) = $n(x)"
$tmp2 = $a * $tmp1
$tmp3 = 3 * $a
Write-Host "$tmp2 - $tmp3(x) = $n(x)"
$tmp4 = $n + $tmp3
Write-Host "$tmp4(x) = $tmp2"
$prodpoolresources = $tmp2 / $tmp4
Write-Host "x = $prodpoolresources"
Write-Host "--------------------------------"
$prodpoolresources = [Math]::Round($prodpoolresources,0)
$testpoolresources = $w - $prodpoolresources
$prodsharepermb = $prodpoolresources / $totalprodmem
$testsharepermb = $testpoolresources / $totaltestmem
# Output results
Write-Host "Recommended Share setting for production $prodpoolresources MB split between" $prodvms.count "Vms with" $totalprodmem " MB of RAM resulting in $prodsharepermb shares per MB"
Write-Host "Recommended Share setting for test $testpoolresources MB split between" $testvms.count "Vms with" $totaltestmem " MB of RAM resulting $testsharepermb shares per MB"
Write-Host "=========================================================="