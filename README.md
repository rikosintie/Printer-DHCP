# Printer-DHCP
Scan for HP printers using nmap and create MS DHCP reservations with Powershell

I needed to change the IP address scheme for a customer. They had a large number of printers using DHCP on the scope without reservations. I needed a way to organize the printers so that they could easily update the PCs after the change.

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

sudo nmap -p 9100 --script hp.nse 192.168.10.0/24

* On Linux you will need to use sudo because a syn scan is required to get the MAC address.
* On Windows do not include the sudo.

This will generate a file named targets.txt in the directory you ran the script in.

**Note:**
If you change the port from 9100 to 445 it will generate a list of Microsoft computers and save them to targets.txt.




**Run the Powershell script**

Open Powershell on Windows
* On win7 click the start orb and type Powershell. 
* On win8-10 Google should know how to run Powershell.

**In the Powershell window:**
```
.\printer-dhcp.ps1 -server 192.168.10.221 -scope 192.168.10.0
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.235  101f746341f5 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.236  101f746341f6 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.237  101f746341f7 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.238  101f746341f8 
netsh dhcp server 192.168.10.221 scope 192.168.10.0 add reservedip 192.168.10.239  101f746341f9 
```

Copy the output of the script and paste it into the Powershell window.

Obviously, you need rights to create DHCP reservations on the server!

## References
* [Nmap Scripting API](https://nmap.org/book/nse-api.html)
* [Nmap Library stdnse](https://nmap.org/nsedoc/lib/stdnse.html#format_mac)
* [Identifying HP Printers with NMAP and then using results in Python/Perl](https://help.github.com/articles/basic-writing-and-formatting-syntax/)
* [PowerShell ABC's - P is for Parameters](https://devcentral.f5.com/articles/powershell-abcs-p-is-for-parameters)
*[Referencing Variables and Variable Values](https://technet.microsoft.com/en-us/library/ee692790.aspx)


