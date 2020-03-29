#!/bin/bash

##################################################################################################
# Original Author: Shubham Pathak 								 #
# Edits for autosetup-rpi by Fred Owsley 							 #
# Description: Auto setup bash script to setup required programs after doing fresh install.      # 
# Tested against Raspbian Stretch and Buster					                 #        
##################################################################################################

c='\e[32m' # Coloured echo (Green)
r='tput sgr0' #Reset colour after echo

echo -e " "
echo -e "   _         _                 _                                _  "
echo -e "  /_\  _   _| |_ ___  ___  ___| |_ _   _ _ __        _ __ _ __ (_)"
echo -e " //_\\ | | | | __/ _ \/ __|/ _ \ __| | | | '_ \ _____| '__| '_ \| |"
echo -e "/  _  \ |_| | || (_) \__ \  __/ |_| |_| | |_) |_____| |  | |_) | |"
echo -e "\_/ \_/\__,_|\__\___/|___/\___|\__|\__,_| .__/      |_|  | .__/|_|"
echo -e "                                        |_|              |_|      "
                                                            
							    
# Required dependencies for all softwares (important)
echo -e "${c}Installing complete dependencies pack."; $r
sudo apt install -y software-properties-common apt-transport-https build-essential checkinstall \
libreadline-gplv2-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev \
autoconf automake libtool make g++ unzip flex bison gcc libyaml-dev zlib1g zlib1g-dev \
libncurses5-dev libffi-dev libgdbm-dev libpq-dev libpcap-dev libmagickwand-dev libappindicator3-1 \
libindicator3-7 imagemagick xdg-utils git

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
echo -e "${c}Do you want to setup Git global config? (y/n)"; $r
read -p ": " -r;
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
echo -e "${c}Do you want to download Daniel Miessler's SecLists (quite useful during recon)? (y/n)"; $r
read -p ": " -r;
if [[ $REPLY =~ ^[Yy]$ ]]; then
	echo -e "${c}Downloading SecLists in $HOME/tools"; $r
	cd && cd tools 
	git clone --depth 1 https://github.com/danielmiessler/SecLists.git
else
 	echo -e "${c}Skipping!"; $r && :
fi

calc_wt_size() {
  # NOTE: it's tempting to redirect stderr to /dev/null, so supress error 
  # output from tput. However in this case, tput detects neither stdout or 
  # stderr is a tty and so only gives default 80, 24 values
  WT_HEIGHT=40
  WT_WIDTH=$(tput cols)

  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$(($WT_HEIGHT-7))
}
do_vim() {
		echo -e "${c}Installing vim and amix's Basic .vimrc"; $r
		sudo apt install -y vim
		cd
		git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
		sh ~/.vim_runtime/install_basic_vimrc.sh

}

do_netcat() {
		echo -e "${c}Installing netcat"; $r
		sudo apt install -y netcat
}

do_py2() { 
		echo -e "${c}Installing Python2"; $r
		sudo apt install -y python-pip
		( set -x ; pip --version )
}

do_py3() {
		echo -e "${c}Installing Python3"; $r
		( set -x ; sudo add-apt-repository ppa:deadsnakes/ppa -y )
		sudo apt install -y python3
		( set -x ; python3 --version )
}

do_ipy() {
		echo -e "${c}Installing iPython"; $r
		sudo pip install ipython
}
		
do_go() { 
		echo -e "${c}Installing Go version 1.8"; $r #Change the version if you want.
		sudo apt install -y golang-1.8
		echo -e "${c}Verifying Go Installation"; $r
		( set -x ; go version )
		echo -e "${c}Go Installed Successfully."; $r
}

do_rbenv() {
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
}

do_java() {
		echo -e "${c}Setting up JRE & JDK"; $r
		sudo apt install -y default-jre
		sudo apt install -y default-jdk
		( set -x ; java -version )
		echo -e "${c}Java Installed Successfully!"; $r
}

do_mass() {
		echo -e "${c}Installing Masscan in $HOME/tools/masscan"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/robertdavidgraham/masscan
		cd masscan
		make
		echo -e "${c}Masscan Installed Successfully."; $r
}

do_chromium() {
		echo -e "${c}Installing Chromium"; $r
		sudo apt install -y chromium-browser
}

do_nmap () {
		echo -e "${c}Installing NMAP"; $r
		sudo apt install -y nmap
}

do_hping() {
		echo -e "${c}Installing hping3"; $r
		sudo apt install -y hping3
}

do_ang() {
		echo -e "${c}Installing Aircrack-ng"; $r
		sudo apt install -y aircrack-ng
}

do_etc() {
		echo -e "${c}Installing Ettercap"; $r
		sudo apt install -y ettercap-graphical
}

do_sqlmap() {
		echo -e "${c}Downloading SQLMAP"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git sqlmap-dev
		echo -e "${c}SQLMAP Downloaded Successfully. Go to $HOME/tools/sqlmap-dev to run it."; $r
}

do_yara() {
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
}

do_i3() {
		echo -e "${c}Installing i3 Window Manager"; $r
		sudo apt install -y i3
}

do_eyew() {
		echo -e "${c}Installing EyeWitness"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/FortyNorthSecurity/EyeWitness.git
		cd EyeWitness/setup
		sudo ./setup.sh
		echo -e "${c}EyeWitness Installed Successfully in $HOME/tools/EyeWitness."; $r
}

do_kismet() {
		echo -e "${c}Installing Kismet"; $r
		cd && cd tools
		git clone https://www.kismetwireless.net/git/kismet.git
		cd kismet
		sudo ./configure
		sudo make -j 2
		sudo make suidinstall
		sudo usermod -aG kismet $USER
		echo -e "${c}Kistmet Installed in $HOME/tools/kismet - LOGOUT/IN before using"; $r
}

do_yer() {
		echo -e "${c}Installing Yersinia"; $r
		sudo apt install -y yersinia
		echo -e "${c}Yersinia Installed Successfully."; $r
}

do_mac() {
		echo -e "${c}Installing Macchanger"; $r
		sudo apt install -y macchanger
}

do_ws() {
		echo -e "${c}Installing Wireshark"; $r
		sudo apt install -y wireshark
		sudo dpkg-reconfigure wireshark-common 
		echo -e "${c}Adding user to wireshark group."; $r
		sudo usermod -aG wireshark $USER
		echo -e "${c}Wireshark Installed Successfully."; $r
}

do_amass() {
		echo -e "${c}Installing Amass"; $r
		sudo snap install amass
}

do_kno() {
		echo -e "${c}Installing Knockpy in $HOME/tools"; $r
		cd && cd tools
		sudo apt install -y python-dnspython
		git clone --depth 1 https://github.com/guelfoweb/knock.git
		cd knock
		sudo python setup.py install
		echo -e "${c}Knockpy Installed Successfully."; $r
}

do_dir() {
		echo -e "${c}Downloading Dirsearch in $HOME/tools"; $r
 		cd && cd tools
 		git clone --depth 1 https://github.com/maurosoria/dirsearch.git
 		echo -e "${c}Dirsearch Downloaded."; $r
 }

do_lf() {
 
 		echo -e "${c}Installing LinkFinder in $HOME/tools"; $r
       		cd && cd tools
        	git clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git
        	cd LinkFinder
        	sudo pip install argparse jsbeautifier
        	sudo python setup.py install
        	echo -e "${c}LinkFinder Installed Successfully."; $r
 }

do_meta() {
		echo -e "${c}Installing Metasploit"; $r
		cd && cd tools
		git clone --depth 1 https://github.com/rapid7/metasploit-framework.git
		sudo chown -R `whoami` metasploit-framework
		cd metasploit-framework 
		gem install bundler
		bundle install
		echo -e "${c}Metasploit Installed Successfully."; $r
}

do_pix() {
		echo -e "${c}Installing Pixiewps"; $r
		sudo apt install -y pixiewps
		echo -e "${c}Pixiewps Installed Successfully."; $r
}
		
do_air() {
		echo -e "${c}Installing Airgeddon"; $r
		cd && cd tools
		git clone -depth 1 https://github.com/v1s1t0r1sh3r3/airgeddon.git
		echo -e "${c}Airgeddon Installed Successfully."; $r
}
		
do_osme() {		
		echo -e "${c}Installing Osmedeus"; $r
		cd && cd tools
		git clone -depth 1 https://github.com/j3ssie/Osmedeus
		cd Osmedeus
		sudo ./install.sh
		echo -e "${c}Osmedeus Installed Successfully."; $r
}

do_and() {
		echo -e "${c}Installing Android Tools"; $r
		#Installing ADB and Fastboot
		#echo -e "${c}Installing ADB and Fastboot"; $r
		#sudo apt install -y android-tools-adb android-tools-fastboot
		echo -e "${c}Android Tools Installed Successfully."; $r
}		
do_btmon() {
		echo -e "${c}Installing Bluetooth Monitor"; $r
		cd && cd tools
		sudo apt install -y pi-bluetooth bluez-hcidump bc
		wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
		sudo apt-key add mosquitto-repo.gpg.key
		cd /etc/apt/sources.list.d/
		sudo wget http://repo.mosquitto.org/debian/mosquitto-buster.list
		cd && cd tools
		sudo apt install -y libmosquitto-dev mosquitto mosquitto-clients libmosquitto1
		git clone git://github.com/andrewjfreyer/monitor
		cd monitor
		echo -e "${c}run 'sudo bash monitor.sh'"
		echo -e "${c}Bluetooth Monitor Installed Successfully."; $r
}

# Final Upgrade and Update Command
#echo -e "${c}Updating and upgrading to finish auto-setup script."; $r
#sudo apt update && sudo apt upgrade -y
#sudo apt --fix-broken install -y

#
# Interactive Loop
#

calc_wt_size
while true; do
  FUN=$(whiptail --title "Autosetup.sh Rapspberry Pi Edition" --menu "Installation Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
    "1 vim" "vim and amix's Basic .vimrc" \
    "2 Netcat" "The TCP/IP swiss army knife." \
    "3 Python2" "Hiss" \
    "4 Python3" "Hisss" \
    "5 iPython" "iPython" \
    "6 Rbenv" "Ruby" \
    "7 Go v1.8" "Go." \
    "8 Masscan" "Massscan" \
    "9 Chromium" "Chrome clone" \
    "10 NMAP" "Network Mapper" \
    "11 hping3" "hping" \
    "12 Aircrack-NG" "Aircrack" \
    "13 Ettercap" "Ettercap" \
    "14 SQLMAP" "SQL Mapper" \
    "15 Yara" "Yet Another Rule Analyzer" \
    "16 i3 Window Manager" "Small Window Manager" \
    "17 EyeWitness" "EyeWitness" \
    "18 Kismet" "The wireless scanner." \
    "19 Yersinia" "Yersinia" \
    "20 Macchanger" "MAC Address changer" \
    "21 Wireshark" "Wireshark, aka Ethereal" \
    "22 Amass" "Amass" \
    "23 Knockpy" "Knockpy" \
    "24 Dirsearch" "Directory Searcher" \
    "25 LinkFinder" "Link Finder" \
    "26 Metasploit" "Popping Shells like its 2001" \
    "27 Pixiewps" "Pixie WPS attack" \
    "28 Airgeddon" "All the wifi tools in one place" \
    "29 Osmedeus" "Osmedeus" \
    "30 Android" "Android Utils, ADB, fastboot, etc." \
    "31 Bluetooth Monitor" "BT Presense monitor (https://github.com/andrewjfreyer/monitor)" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    echo "done"
    exit 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) do_vim ;; 
      2\ *) do_netcat ;;
      3\ *) do_py2 ;;
      4\ *) do_py3 ;;
      5\ *) do_ipy ;;
      6\ *) do_rbenv ;;
      7\ *) do_go ;;
      8\ *) do_mass ;;
      9\ *) do_chromium ;;
      10\ *) do_nmap ;;
      11\ *) do_hping ;;
      12\ *) do_ang ;;
      13\ *) do_etc ;;
      14\ *) do_sqlmap ;;
      15\ *) do_yara ;;
      16\ *) do_i3 ;;
      17\ *) do_eyew ;;
      18\ *) do_kismet ;;
      19\ *) do_yer ;;
      20\ *) do_mac ;;
      21\ *) do_ws ;;
      22\ *) do_amass ;;
      23\ *) do_kno ;;
      24\ *) do_dir ;;
      25\ *) do_lf ;;
      26\ *) do_meta ;;
      27\ *) do_pix ;;
      28\ *) do_air ;;
      29\ *) do_osme ;;
      30\ *) do_and ;;
      31\ *) do_btmon ;;
      
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
done
