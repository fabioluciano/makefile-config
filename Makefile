UBUNTU_CODENAME = $(shell lsb_release -cs)

VIVALDI_DEB = $(shell curl -sS https://vivaldi.com/download/ | grep -oP  '<a *?href="\K(?<link>.*?amd64.deb)"' | sed 's/"//g' | head -1)

TERRAFORM_VERSION = '0.11.10'
VAGRANT_VERSION = '2.2.1'
PACKER_VERSION = '1.3.2'

.PHONY:  update upgrade clean prepare fonts

update:
	sudo apt update --fix-missing

upgrade:
	sudo apt dist-upgrade -y
	sudo snap refresh

clean:
	sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean all -y

# Essentials

essentials:
	make prepare
	make fonts
	make python
	make tmux
	make zsh

prepare:
	sudo apt install -y vim curl wget git git-flow libssl-dev apt-transport-https ca-certificates software-properties-common unzip bash-completion \
		 gconf-service gconf-service-backend gconf2-common libgconf-2-4

fonts:
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	sudo apt install -y ttf-mscorefonts-installer

	mkdir -p ~/.fonts
	wget --content-disposition https://raw.githubusercontent.com/todylu/monaco.ttf/master/monaco.ttf -P ~/.fonts/monaco.ttf
	chown ${USER}:${USER} ~/.fonts
	fc-cache -v

python:
	sudo -H apt -y install python-pip
	sudo -H pip install --upgrade pip
	
tmux: files/tmux.conf
	sudo apt install -y tmux
	
	cp files/tmux.conf ~/.tmux.conf
	cp files/terminalrc ~/.config/xfce4/terminal
	chown ${USER}:${USER} ~/.tmux.conf ~/.config/xfce4/terminal

zsh: files/zshrc
	sudo apt install -y zsh
	curl -L git.io/antigen > ~/.local-antigen.zsh
	cp files/zshrc ~/.zshrc
	sudo chsh --shell /usr/bin/zsh ${USER}

# Development

development:
	make vscode
	make atom
	make aws
	make ansible
	make hashicorp

vscode:
	wget https://go.microsoft.com/fwlink/?LinkID=760868 -O vscode.deb
	sudo dpkg -i vscode.deb
	rm vscode.deb

atom:
	wget https://atom.io/download/deb -O atom.deb
	sudo apt install -y gconf2 gvfs-bin
	sudo dpkg -i atom.deb
	rm atom.deb

java:
	sudo add-apt-repository ppa:linuxuprising/java -y
	echo oracle-java11-installer shared/accepted-oracle-license-v1-2 select true | sudo /usr/bin/debconf-set-selections
	sudo apt install -y oracle-java11-installer oracle-java11-set-default

aws:
	pip install awscli --upgrade --user

ansible:
	pip install ansible --upgrade --user

docker:
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(UBUNTU_CODENAME) stable"
	sudo apt install -y docker-ce

hashicorp:
	make terraform
	make vagrant
	make packer

terraform:
	wget https://releases.hashicorp.com/terraform/$(TERRAFORM_VERSION)/terraform_$(TERRAFORM_VERSION)_linux_amd64.zip -O terraform.zip
	unzip terraform.zip
	sudo mv terraform /usr/local/bin
	rm terraform.zip

vagrant:
	wget https://releases.hashicorp.com/vagrant/$(VAGRANT_VERSION)/vagrant_$(VAGRANT_VERSION)_x86_64.deb -O vagrant.deb
	sudo dpkg -i vagrant.deb
	rm vagrant.deb

packer:
	wget https://releases.hashicorp.com/packer/$(PACKER_VERSION)/packer_$(PACKER_VERSION)_linux_amd64.zip -O packer.zip
	unzip packer.zip
	sudo mv packer /usr/local/bin
	rm packer.zip


browsers:
	make firefox
	make chrome
	make vivaldi
	make opera

vivaldi:
	wget $(VIVALDI_DEB) -O  vivaldi.deb
	sudo dpkg -i vivaldi.deb
	rm vivaldi.deb

chrome:
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -O chrome.deb
	sudo dpkg -i chrome.deb
	rm chrome.deb

opera:
	wget http://download4.operacdn.com/ftp/pub/opera/desktop/56.0.3051.99/linux/opera-stable_56.0.3051.99_amd64.deb -O opera.deb
	sudo dpkg -i opera.deb
	rm opera.deb

firefox:
	sudo apt install -y firefox

tweaks:
	make synapse

synapse:
	sudo add-apt-repository ppa:synapse-core/testing -y
	sudo apt install -y synapse
