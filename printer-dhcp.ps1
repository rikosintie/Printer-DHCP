param([string]$server = "server", [string]$scope = "scope")
$a = Get-Content targets.txt
$counter = 0
while ($counter -lt $a.count) {
$ip=$a[$counter]
#Write-Host $ip
$counter = $counter + 1
$mac=$a[$counter]
#remove colons since MS DHCP can't deal with a real mac address
$mac=$mac-replace'[:]'
#write-host $mac
write-host "netsh dhcp server $server scope $scope add reservedip $ip $mac"
$counter=$counter+1
}
