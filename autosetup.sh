#!/bin/bash

##################################################################################################
# Original Author: Shubham Pathak 								 #
# Edits for autosetup-rpi by Fred Owsley 							 #
# Description: Auto setup bash script to setup required programs after doing fresh install.      # 
# Tested against Raspbian Stretch and Buster					                 #        
##################################################################################################

c='\e[32m' # Coloured echo (Green)
r='tput sgr0' #Reset colour after echo

# Required dependencies for all softwares (important)
echo -e "${c}Installing complete dependencies pack."; $r
sudo apt install -y software-properties-common apt-transport-https build-essential checkinstall \
libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev \
autoconf automake libtool make g++ unzip flex bison gcc libyaml-dev libreadline-dev zlib1g zlib1g-dev \
libncurses5-dev libffi-dev libgdbm-dev libpq-dev libpcap-dev libmagickwand-dev libappindicator3-1 \
libindicator3-7 imagemagick xdg-utils

# Upgrade and Update Command
echo -e "${c}Updating and upgrading before performing further operations."; $r
sudo apt update && sudo apt upgrade -y
sudo apt --fix-broken install -y

#Setting up Git
echo -e "${c}Do you want to install snap? (y/n)"; $r
read -p ": " -r;
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	#Snap Installation & Setup
	echo -e "${c}Installing Snap & setting up."; $r
	sudo apt install -y snapd
	sudo systemctl start snapd
	sudo systemctl enable snapd
	sudo systemctl start apparmor
	sudo systemctl enable apparmor
	export PATH=$PATH:/snap/bin
	sudo snap refresh
else
	echo -e "${c}Skipping!"; $r && :
fi

#Setting up Git
read -p "${c}Do you want to setup Git global config? (y/n): " -r; $r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo -e "${c}Setting up Git"; $r
	(set -x; git --version )
	echo -e "${c}Setting up global git config at ~/.gitconfig"; $r
	git config --global color.ui true
	read -p "Enter Your Full Name: " name
	read -p "Enter Your Email: " email
	git config --global user.name "$name"
	git config --global user.email "$email"
	echo -e "${c}Git Setup Successfully!"; $r
else
	echo -e "${c}Skipping!"; $r && :
fi

#Installing curl and wget
echo -e "${c}Installing Curl and wget"; $r
sudo apt-get install -y wget curl

#Installing dig
echo -e "${c}Installing DNS Utils"; $r
sudo apt install -y dnsutils

#Creating Directory Inside $HOME
echo -e "${c}Creating Directory named 'tools' inside $HOME directory."; $r
cd
mkdir -p tools

#Downloading SecLists
read -p "${c}Do you want to download Daniel Miessler's SecLists (quite useful during recon)?: " -r; $r
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo -e "${c}Downloading SecLists in $HOME/tools"; $r
	cd && cd tools 
	git clone --depth 1 https://github.com/danielmiessler/SecLists.git
else
 	echo -e "${c}Skipping!"; $r && :
fi

#Executing Install Dialog
dialogbox=(whiptail --separate-output --ok-button "Install" --title "Auto Setup Script" --checklist "\nPlease select required software(s):\n(Press 'Space' to Select/Deselect, 'Enter' to Install and 'Esc' to Cancel)" 30 80 20)
options=(
		 1 "Netcat" off
		 2 "Python2 and iPython" off
		 3 "Python3" off
		 4 "Go v1.8" off
		 5 "Rbenv" off
		 6 "JRE & JDK" off
		 7 "Masscan" off
		 8 "Chromium" off
		 9 "NMAP" off
		 10 "hping3" off
		 11 "Aircrack-NG" off
		 12 "Ettercap" off
		 13 "SQLMAP" off
		 14 "Yara" off
		 15 "i3 Window Manager" off
		 16 "EyeWitness" off
		 17 "Kismet" off
		 18 "Yersinia" off
		 19 "Macchanger" off
		 20 "Wireshark" off
         	 21 "Amass" off
         	 22 "Knockpy" off
         	 23 "Dirsearch" off
         	 24 "LinkFinder" off
         	 25 "Metasploit" off
		 26 "Pixiewps" off
		 27 "Airgeddon" off
		 28 "Osmedeus" off
		 29 "Android Utils, ADB, fastboot" off

selected=$("${dialogbox[@]}" "${options[@]}" 2>&1 >/dev/tty)

for choices in $selected
do
	case $choices in
		1) 
		echo -e "${c}Installing netcat"; $r
		sudo apt install -y netcat
		;;

		2) 
		echo -e "${c}Installing Python2 and iPython"; $r
		sudo apt install -y python-pip
		( set -x ; pip --version )
		sudo pip install ipython
		;;

		3) 
		echo -e "${c}Installing Python3"; $r
		( set -x ; sudo add-apt-repository ppa:deadsnakes/ppa -y )
		sudo apt install -y python3
		( set -x ; python3 --version )
		;;

		4) 
		echo -e "${c}Installing Go version 1.8"; $r #Change the version if you want.
		sudo apt install -y golang-1.8
		echo -e "${c}Verifying Go Installation"; $r
		( set -x ; go version )
		echo -e "${c}Go Installed Successfully."; $r
		;;

		5) 
		echo -e "${c}Installing & Setting up rbenv"; $r
		cd
		sudo rm -rf .rbenv/
		git clone https://github.com/rbenv/rbenv.git ~/.rbenv
		echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
		echo 'eval "$(rbenv init -)"' >> ~/.bashrc
		export PATH="$HOME/.rbenv/bin:$PATH"
		eval "$(rbenv init -)"
		source ~/.bashrc
		type rbenv
		git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
		echo 'export PATH="$HOME/.rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
		source ~/.bashrc
		rbenv install 2.6.4 #Installing required version of Ruby
		( set -x ; ruby -v )
		echo -e "${c}rbenv and defined ruby version setup Successfully."; $r
		;;

		6) 
		echo -e "${c}Setting up JRE & JDK"; $r
		sudo apt install -y default-jre
		sudo apt install -y default-jdk
		( set -x ; java -version )
		echo -e "${c}Java Installed Successfully!"; $r
		;;

		7) 
		echo -e "${c}Installing Masscan in $HOME/tools/masscan"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/robertdavidgraham/masscan
		cd masscan
		make
		echo -e "${c}Masscan Installed Successfully."; $r
		;;

		8) 
		echo -e "${c}Installing Chromium"; $r
		sudo apt install -y chromium-browser
		;;

		9) 
		echo -e "${c}Installing NMAP"; $r
		sudo apt install -y nmap
		;;

		10) 
		echo -e "${c}Installing hping3"; $r
		sudo apt install -y hping3
		;;

		11) 
		echo -e "${c}Installing Aircrack-ng"; $r
		sudo apt install -y aircrack-ng
		;;

		12) 
		echo -e "${c}Installing Ettercap"; $r
		sudo apt install -y ettercap-graphical
		;;

		13) 
		echo -e "${c}Downloading SQLMAP"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
		echo -e "${c}SQLMAP Downloaded Successfully. Go to $HOME/tools/sqlmap-dev to run it."; $r
		;;

		14) 
		echo -e "${c}Installing Yara v3.10.0"; $r
		cd && cd tools
		wget https://github.com/VirusTotal/yara/archive/v3.10.0.tar.gz
		tar -zxf v3.10.0.tar.gz
		rm -f v3.10.0.tar.gz
		cd yara-3.10.0
		sudo ./bootstrap.sh
		sudo ./configure --with-crypto
		sudo make
		sudo make check
		sudo make install
		echo -e "${c}Yara Setup Successfully."; $r
		;;

		15) 
		echo -e "${c}Installing i3 Window Manager"; $r
		sudo apt install -y i3
		;;

		16) 
		echo -e "${c}Installing EyeWitness"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/FortyNorthSecurity/EyeWitness.git
		cd EyeWitness/setup
		sudo ./setup.sh
		echo -e "${c}EyeWitness Installed Successfully in $HOME/tools/EyeWitness."; $r
		;;

		17) 
		echo -e "${c}Installing Kismet"; $r
		cd && cd tools
		git clone https://www.kismetwireless.net/git/kismet.git
		cd kismet
		sudo ./configure
		sudo make -j 2
		sudo make suidinstall
		sudo usermod -aG kismet $USER
		echo -e "${c}Kistmet Installed in $HOME/tools/kismet - LOGOUT/IN before using"; $r
		;;

		18) 
		echo -e "${c}Installing Yersinia"; $r
		sudo apt install -y yersinia
		echo -e "${c}Yersinia Installed Successfully."; $r
		;;

		19) 
		echo -e "${c}Installing Macchanger"; $r
		sudo apt install -y macchanger
		;;

		20) 
		echo -e "${c}Installing Wireshark"; $r
		sudo apt install -y wireshark
		sudo dpkg-reconfigure wireshark-common 
		echo -e "${c}Adding user to wireshark group."; $r
		sudo usermod -aG wireshark $USER
		echo -e "${c}Wireshark Installed Successfully."; $r
		;;

		21)
		echo -e "${c}Installing Amass"; $r
		sudo snap install amass
		;;

		22)
		echo -e "${c}Installing Knockpy in $HOME/tools"; $r
		cd && cd tools
		sudo apt install -y python-dnspython
		git clone --depth 1 https://github.com/guelfoweb/knock.git
		cd knock
		sudo python setup.py install
		echo -e "${c}Knockpy Installed Successfully."; $r
		;;

		23)
 		echo -e "${c}Downloading Dirsearch in $HOME/tools"; $r
 		cd && cd tools
 		git clone --depth 1 https://github.com/maurosoria/dirsearch.git
 		echo -e "${c}Dirsearch Downloaded."; $r
 		;;

 		24)
        	echo -e "${c}Installing LinkFinder in $HOME/tools"; $r
       		cd && cd tools
        	git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git
        	cd LinkFinder
        	sudo pip install argparse jsbeautifier
        	sudo python setup.py install
        	echo -e "${c}LinkFinder Installed Successfully."; $r
        	;;

		25)
		echo -e "${c}Installing Metasploit"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/rapid7/metasploit-framework.git
		sudo chown -R `whoami` metasploit-framework
		cd metasploit-framework 
		gem install bundler
		bundle install
		echo -e "${c}Metasploit Installed Successfully."; $r
		;;	
		
		26)
		echo -e "${c}Installing Pixiewps"; $r
		sudo apt install -y pixiewps
		echo -e "${c}Pixiewps Installed Successfully."; $r
		;;
		
		27)
		echo -e "${c}Installing Airgeddon"; $r
		cd && cd tools
		git clone -depth 1 https://github.com/v1s1t0r1sh3r3/airgeddon.git
		echo -e "${c}Airgeddon Installed Successfully."; $r
		;;
		
		28)
		echo -e "${c}Installing Osmedeus"; $r
		cd && cd tools
		git clone -depth 1 https://github.com/j3ssie/Osmedeus
		cd Osmedeus
		sudo ./install.sh
		echo -e "${c}Osmedeus Installed Successfully."; $r
		;;
		
		29)
		echo -e "${c}Installing Android Tools"; $r
		#Installing ADB and Fastboot
		#echo -e "${c}Installing ADB and Fastboot"; $r
		#sudo apt install -y android-tools-adb android-tools-fastboot
		echo -e "${c}Android Tools Installed Successfully."; $r
		;;
	esac
done

# Final Upgrade and Update Command
echo -e "${c}Updating and upgrading to finish auto-setup script."; $r
sudo apt update && sudo apt upgrade -y
sudo apt --fix-broken install -y
