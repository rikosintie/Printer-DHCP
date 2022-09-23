![made-with-Powershell](https://img.shields.io/badge/Made%20With-Powershell-Success)
![GitHub language count](https://img.shields.io/github/languages/count/rikosintie/nmap-python)
![Twitter Follow](https://img.shields.io/twitter/follow/rikosintie?style=social)


# Printer-DHCP
Scans for HP printers using nmap and creates MS DHCP reservations with Powershell

I needed to change the IP address scheme for a customer. They had a large number of printers using DHCP without reservations. I needed a way to organize the printers so that they could easily update the PCs after the change.

I wrote a simple nmap script, hp.nse, that scans a range of IPs for port 9100. If it finds an open port it records the IP address and mac address in a file named targets.txt.

I edited this file and changed the existing IPs to the new IPs and saved it.

Then I wrote a simple Powershell script that reads the file, removes the colons in the MAC Adresses and outputs a script to create the reservations.

Nothing Earth shattering but it saved a lot of time over point and clicking to create 50 or so reservations.


## Usage

* You must have [nmap](https://nmap.org/download.html) installed. Version 7.50 is what I used for this example.
* You have to be on the same vlan as the printer. The reason is that we need the MAC address of each device and MAC Addresses don't make it past routers
* Download the files in this repository and unzip them. If you have Git installed you can just use: 
```
git clone https://github.com/rikosintie/Printer-DHCP.git
```
To clone the scripts

**Run the nmap script**

NOTE: since the script must pull the MAC Address you need to be on the same subnet as the printers.

sudo nmap -p 9100 --script hp.nse 192.168.10.0/24

* On Linux you will need to use sudo because a syn scan is required to get the MAC address.
* On Windows do not include the sudo.

This will generate a file named targets.txt in the directory you ran the script in.

**Note:**
If you change the port from 9100 to 445 it will generate a list of Microsoft computers and save them to targets.txt.




**Run the Powershell script**
On Linux/Mac  
Open a terminal  
pwsh [enter]  

This will open a powershell session

Open Powershell on Windows
* On win7 click the start orb and type Powershell. 
* On win8-10 Google should know how to run Powershell.

**In the Powershell terminal:**

```powershell
.\printer-dhcp.ps1 -server 192.168.10.221 -scope 192.168.10.0
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.235  101f746341f5 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.236  101f746341f6 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.237  101f746341f7 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.238  101f746341f8 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.239  101f746341f9 
```

Copy the output of the script and paste it into the Powershell window.

Obviously, you need rights to create DHCP reservations on the server!

## A more generic script
I wanted to create reservations for new surveillance cameras and be able to pull the data from a csv file.  

The script `dhcp-csv.ps1` accepts the server, scope parameters but also -filename <filename.csv>  

I added the filename so that at multi-site customers I could keep separate files for each location.

Here is an example:  

```powershell
./dhcp-csv.ps1 -server 10.76.23.110 -scope 10.76.20.0 -filename ./HS-DHCP.csv
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.134 E0A7001D5C92
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.135 E0A7001D5CD7
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.136 E0A7001D5CA8
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.115 E0A7001D4E00
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.116 E0A7001D5CA5
```

Powershell makes it very easy to use parameters. Here is the complete script:  

```powershell
param ([string] $server = "server", [string]$scope = "scope", [string]$filename = "filename")
$a = Import-Csv $filename
foreach ($item in $a) {
$ip=$($item.IP)
$mac=$($item.MAC)
#remove colons since MS DHCP can't deal with a real mac address
$mac=$mac-replace'[:]'
$name = $($item."Camera Lables")
write-host "netsh dhcp server $server scope $scope add reservedip $ip $mac $name"
}
```

## References
* [Nmap Scripting API](https://nmap.org/book/nse-api.html)
* [Nmap Library stdnse](https://nmap.org/nsedoc/lib/stdnse.html#format_mac)
* [Identifying HP Printers with NMAP and then using results in Python/Perl](https://help.github.com/articles/basic-writing-and-formatting-syntax/)
* [PowerShell ABC's - P is for Parameters](https://devcentral.f5.com/articles/powershell-abcs-p-is-for-parameters)
* [How to Use Parameters in PowerShell Part I](https://www.red-gate.com/simple-talk/sysadmin/powershell/how-to-use-parameters-in-powershell/)
* [Referencing Variables and Variable Values](https://technet.microsoft.com/en-us/library/ee692790.aspx)
* [Read Data from a CSV file](https://stackoverflow.com/questions/46286784/read-data-from-csv-file-using-powershell-and-strore-each-line-data-in-an-array)
* [MS article on Powershell for DHCP deployment](https://docs.microsoft.com/en-us/windows-server/networking/technologies/dhcp/dhcp-deploy-wps#bkmk_dhcpwps)
* [MS Article on Powershell Commands for DHCP](https://techcommunity.microsoft.com/t5/itops-talk-blog/how-to-manage-dhcp-using-powershell/ba-p/744461)
