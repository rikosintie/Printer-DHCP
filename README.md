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

The script `dhcp-csv.ps1` accepts -filename <filename.csv> as the input file.

The CSV file needs the following column headers:
* DHCP_server --- IP address of the DHCP server
* DHCP_scope --- The IP subnet of the scope
* Camera Labels - The description for hte reservation
* MAC ----------- The MAC Address. It can have ":" or "-" separators
* IP Address ----- IP address to assign to the reservation


Here is an example of the output:  

```powershell
./dhcp-csv.ps1 -filename ./HS-DHCP.csv
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.113 E0A7002E2C63 HS/MS-CAM 13
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.114 E0A7002377F9 HS/MS-CAM 14
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.115 E0A700237725 HS/MS-CAM 15
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.116 E0A7001D4E2F HS/MS-CAM 16
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.117 E0A7001D4E00 HS/MS-CAM 17
netsh dhcp server 10.76.23.110 scope 10.76.20.0 add reservedip 10.76.20.118 E0A7001D5CA5 HS/MS-CAM 18
```

Powershell makes it very easy to use parameters. Here is the complete script:  

```powershell
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
write-host "netsh dhcp server $server scope $scope add reservedip $ip $mac $name"
```

Mac/Linux users
You can create the following alias in your .bashrc or .zshrc file and then quickly display CSV files on the terminal:  

I find it very useful when deveoloping scripts to be able to display the CSV file so easily.  

```#Display csv data at the terminal
alias csv='ls *.csv | pbcopy ; sed s/,/,:/g $(pbpaste) | column -t -s: | sed s/,//g | cut -c-180'
```

Here is a sample:  

```
csv
Item  Camera Labels         MAC         IP Address    DHCP_Server   DHCP_Scope
13    HS/MS-CAM 13   E0-A7-00-2E-2C-63  10.76.20.113  10.76.23.110  10.76.20.0
14    HS/MS-CAM 14   E0-A7-00-23-77-F9  10.76.20.114  10.76.23.110  10.76.20.0
15    HS/MS-CAM 15   E0-A7-00-23-77-25  10.76.20.115  10.76.23.110  10.76.20.0
16    HS/MS-CAM 16   E0-A7-00-1D-4E-2F  10.76.20.116  10.76.23.110  10.76.20.0
17    HS/MS-CAM 17   E0-A7-00-1D-4E-00  10.76.20.117  10.76.23.110  10.76.20.0
18    HS/MS-CAM 18   E0-A7-00-1D-5C-A5  10.76.20.118  10.76.23.110  10.76.20.0
```

For macOS there is also a simple gui tool called [Table Tool](https://github.com/jakob/TableTool) that is free on the Mac Store.  



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
