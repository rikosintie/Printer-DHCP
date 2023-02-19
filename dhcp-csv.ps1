param ([string]$filename = "filename")
$a = Import-Csv $filename
foreach ($item in $a) {
$ip=$($item."IP Address")
$mac=$($item.MAC)
$server =$($item.DHCP_server)
$scope=$($item.DHCP_scope)
#remove colons/dashes since MS DHCP can't deal with a real mac address
$mac=$mac-replace'[:]'
$mac=$mac-replace'[-]'
$name = $($item."Camera Labels")
$description = $($item."Camera location")
write-host "netsh dhcp server $server scope $scope add reservedip $ip $mac $name $description"
}