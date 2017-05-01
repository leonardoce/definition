#!/usr/bin/env bash

# Common requirements for a working environment
install_common() {
	apt-get install -y \
		vim-nox emacs-nox build-essential git \
		chromium-browser

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

	apt-get install -y virtualenv python3-virtualenv python3-dev python-dev libssl-dev
	tar -C /opt -xf pycharm.tar.gz
}

# Install the database
install_database() {
	apt-get install -y postgresql-9.6 libpq-dev
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

# Start all the stuff
install_common
install_python
install_database
install_php
install_virtualization
install_containers
