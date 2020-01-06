# autosetup-rpi
Autosetup-rpi is a Raspberry Pi-focused fork of Auto Setup, a simple bash script (compatible with Debian based distributions like Ubuntu and Kali) to install and setup necessary softwares/tools after doing Fresh Install.

> Script is completely based on InfoSec/Bug Bounty reconnaissance tools as well as some apps I use regularly like Skype, Chrome etc.
> You can Modify it according to your need.

![AutoSetup.sh](https://user-images.githubusercontent.com/20816337/58801810-399ecb80-8629-11e9-8dd7-eb6169195a9b.png)

## Usage

```bash
git clone https://github.com/fredowsley/autosetup-rpi.git
cd autosetup-rpi
chmod +x autosetup.sh
./autosetup.sh
```
## Structure

Script will show a dialogbox (whiptail), where you can select the software(s) you want to install. 

But, before opening the dialogbox, it'll perform the following operations:

1. Install Snap, Curl, wget, DNS-Utils.
2. Setup Git Global Config. (It'll ask for your name and email)*
3. Install all the required dependencies needed for the list of softwares.
4. Download [Daniel Miessler's SecLists](https://github.com/danielmiessler/SecLists) in $HOME/tools. (Useful duing recon and hunting)*

* You can skip 2 & 4 if you want.

## List

* Netcat
* Python2 and iPython
* Python3
* GoLang 1.8
* Rbenv
* JRE & JDK
* Masscan
* Chromium
* NMAP
* hping3
* Aircrack-NG
* Ettercap
* SQLMAP
* Yara
* i3 Window Manager
* EyeWitness
* Kismet
* Yersinia
* Macchanger
* Wireshark
* Amass
* Knockpy
* Dirsearch
* LinkFinder
* Metasploit
* Pixiewps
* Airgeddon

## Note

Tested on Raspbian Linux 9 (Stretch), Raspbian Buster, Ubuntu 16.04, Ubuntu 18.04, Kali Linux Vagrant boxes, but it should work with other Debian based distributions as well.


## Contributions

We hope that you will consider contributing to autosetup. Please read this short overview [Contribution Guidelines](https://github.com/shubhampathak/autosetup/blob/master/CONTRIBUTING.md) for some information about how to get started 

