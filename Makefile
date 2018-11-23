UBUNTU_CODENAME = $(shell lsb_release -cs)

TERRAFORM_VERSION = '0.11.10'
VAGRANT_VERSION = '2.2.1'
PACKER_VERSION = '1.3.2'

.PHONY:  update upgrade clean prepare fonts

update:
	sudo apt update --fix-missing
	sudo apt dist-upgrade

upgrade:
	sudo apt dist-upgrade -y
	sudo snap refresh
	sudo flatpak update

clean:
	sudo apt autoremove -y && sudo apt autoclean -y && sudo apt clean all -y

# Essentials

prepare:
	sudo apt install vim curl wget git git libssl-dev apt-transport-https ca-certificates software-properties-common unzip

fonts:
	echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo debconf-set-selections
	sudo apt install -y ttf-mscorefonts-installer

	mkdir -p ~/.fonts
	wget --content-disposition https://raw.githubusercontent.com/todylu/monaco.ttf/master/monaco.ttf -P ~/.fonts/
	fc-cache -v

python:
	sudo -H apt -y install python-pip
	sudo -H pip install --upgrade pip
	
tmux: files/tmux.conf
	sudo apt install -y tmux
	
	cp files/tmux.conf ~/.tmux.conf
	cp files/terminalrc ~/.config/xfce4/terminal

zsh: files/zshrc
	make tmux
	sudo apt install -y zsh
	curl -L git.io/antigen > ~/.local-antigen.zsh
	cp files/zshrc ~/.zshrc
	sudo chsh --shell /usr/bin/zsh

# Development

vscode: 
	wget https://go.microsoft.com/fwlink/?LinkID=760868 -O vscode.deb
	sudo dpkg -i vscode.deb
	rm vscode.deb

atom:
	wget https://atom.io/download/deb -O atom.deb
	sudo apt install -y gconf2 gvfs-bin
	sudo dpkg -i atom.deb
	rm atom.deb

nvm:
	nvm install stable

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
