#!/usr/bin/env bash

# Common requirements for a working environment
install_common() {
	apt-get install -y \
		vim-nox emacs-nox build-essential git \
		chromium-browser tmux keepassx htop

	# Sublime text is so nice
	if [ ! -f sublime.tar.bz2 ]; then
		curl -o sublime.tar.bz2 https://download.sublimetext.com/sublime_text_3_build_3126_x64.tar.bz2
	fi
	tar -C /opt -xf sublime.tar.bz2
}

# Install a Python working environment
install_python() {
	if [ ! -f pycharm.tar.gz ]; then
		curl -Lo pycharm.tar.gz https://download.jetbrains.com/python/pycharm-community-2017.1.2.tar.gz
	fi

	if [ ! -f pycharm_pro.tar.gz ]; then
		curl -Lo pycharm_pro.tar.gz https://download.jetbrains.com/python/pycharm-professional-2017.1.3.tar.gz
	fi

	apt-get install -y virtualenv python3-virtualenv python3-dev python-dev libssl-dev
	tar -C /opt -xf pycharm.tar.gz
	tar -C /opt -xf pycharm_pro.tar.gz
}

# Install the database
install_database() {
	echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
	wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
        apt-get update
        apt-get upgrade -y
	apt-get install -y postgresql-9.6 libpq-dev pgadmin3
}

# Install a PHP development environment
install_php() {
	if [ ! -f phpstorm.tar.gz ]; then
		curl -Lo phpstorm.tar.gz "https://data.services.jetbrains.com/products/download?code=PS&platform=linux"
	fi
	tar -C /opt -xf phpstorm.tar.gz

	if [ ! -f /usr/local/bin/symfony ]; then
		curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony
		chmod +x /usr/local/bin/symfony
	fi

	apt-get install -y php php-sqlite3 php-pgsql php-xml
}

# Virtualization environment
install_virtualization() {
	apt-get install -y virtualbox vagrant
}

# Containers
install_containers() {
	apt-get install -y docker.io
}

# Update the system
apt-get update
apt-get upgrade -y

# Start all the stuff
install_common
install_python
install_database
install_php
install_virtualization
install_containers
