# Multi-node Multi-core R / Shiny

## Instructions for a Local Setup: Windows master / Ubuntu slave

#### Test Setup

The following setup was used for testing purposes. Compare it with your setup and make
adjustments as necessary.

- Host: Windows 7 with a hyper-threaded quad-core and 24 GB RAM 
(minimum needed for this experiment 4 virtual CPUs and 8GB RAM)

- **R 3.1.3** and **RStudio** installed on the Windows host. Download them from  
http://cran.rstudio.com/  
http://www.rstudio.com/products/rstudio/download/

- **PuTTY**, **Plink**, **PuTTYgen**  
http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html  
Any other SSH client for Windows should do, but they are not covered here.  
MobaXterm: http://mobaxterm.mobatek.net/  
Cygwin: https://www.cygwin.com/

- Virtual Box 4.3.26  
https://www.virtualbox.org/wiki/Downloads

- Ubuntu Server 14.04.02 LTS - ISO image  
http://www.ubuntu.com/download/server


#### Goal: create an **R** cluster on the local computer using 2 vCPUs on Windows and 2 vCPUs on Ubuntu

Some of the instructions might be too detailed / obvious - 
feel free to create a setup that works best for you.

1) Create an Ubuntu 64 bit VM with:

- 4GB memory
- 2 vCPU
- 10GB HDD (check SSD if needed)
- CD linked to the downloaded **ubuntu-14.04.2-server-amd64.iso** image
- Bridged networking with the correct network adapter (or Host-only networking, but **not NAT**).  
Note that you might have to re-select the network adapter if you switch between wired / wireless.  
Also, Bridge networking will expose your Ubuntu VM to the local network - depending on your
environment, use it with care.
- Disable audio (optional). 

2) Install Ubuntu Server with default settings

- hostname: [your choice] something unique since many others will have the same setup
- username: ubuntu (this is what Amazon EC2 uses)
- password: [your choice]
- do not encrypt your home directory (this is just a test machine)
- partition: Guided - use entire disk (this is just a test machine)
- select "install security updates automatically"
- select [*] OpenSSH server
- Install GRUB [Yes]

Let it reboot. Also, I did not install Virtual Box Guest Additions.


3) We need to connect to Ubuntu using **ssh**. For this, we need to generate a key pair on Windows.

- open **puttygen.exe**
- press **Generate**
- move the mouse
- enter a Key comment
- do not enter a Key passphrase
- save the private key as a **.ppk file**
- leave the **puttygen.exe** window open


4) Find Ubuntu's local IP address

- login in the Virtual Box console and type
```
$ ifconfig
```
- note the IP address for **eht0** (maybe something like 192.168.x.x)

Use this step later on if you need to find the IP after you restart Virtual Box.  
Host names should work too, but IP addresses work with certainty.


5) Connect with **PuTTY** and create the **authorized_keys** file

- open **PuTTY**
- create a connection to Ubuntu IP address
- create **authorized_keys** file and open it using
```
$ mkdir ~/.ssh
$ chmod 700 ~/.ssh
$ vi ~/.ssh/authorized_keys
```
- on Windows, from the **puttygen.exe** window (top box), copy (Ctrl-V) the Public Key
- go to back the **PuTTY** window where **vi** is open
- switch to insert mode (command **i**)
- paste (Shift-Insert) the key into **vi**
- save and close **vi** using the command sequence **ESC**, **:w** and **:q**
- change the permissions on **authorized_keys** to read + write by owner only
```
$ chmod 600 ~/.ssh/authorized_keys
$ exit
```
- close **puttygen.exe**
- Restart **PuTTY**
  * enter Ubuntu IP address
  * go to Connection > SSH > Auth > Private key file ... 
  * browse and select the saved **.ppk file** 
  * save session settings (optional)
- test the connection

From now on, we will not be using the password to make a connection to the Ubuntu VM.


6) Install Ubuntu updates and **R**

- run basic updates:
```
$ sudo apt-get update
$ sudo apt-get upgrade
$ sudo apt-get dist-upgrade
```

- add CRAN repository to get the latest **R** version
```
$ sudo vi /etc/apt/sources.list
```

- add the following line at the end (use command **i**)
```
deb http://cran.rstudio.com/bin/linux/ubuntu trusty/
```

- save and close **vi** using the command sequence **ESC**, **:w** and **:q**

- install **R** and reboot
```
$ sudo apt-get update
$ sudo apt-get install r-base
$ sudo reboot
```
After apt-get update, you should see a message saying that public key 
is not available. It's safe to ignore it.   
Answer yes (Y/y) when installing r-base.

- re-login with **PuTTY** and test **R** 
```
$ R
> library(parallel)
> detectCores()
[1] 2
> q()
```

#### If successful, you have completed the steps needed for the local setup.
