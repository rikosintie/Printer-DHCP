param([string]$server = "server", [string]$scope = "scope")
$a = Import-Csv DHCP.csv
foreach ($item in $a) {
$ip=$($item.IP)
$mac=$($item.MAC)
#remove colons since MS DHCP can't deal with a real mac address
$mac=$mac-replace'[:]'
$name = $($item."AP-Name")
write-host "netsh dhcp server $server scope $scope add reservedip $ip $mac $name"
}