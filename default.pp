# This class manage an NVM installation for a certain
# user.
class nvm_development ( $username, $home_directory ) {
  exec { "nvm_install":
    command => "/usr/bin/curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash",
    creates => "${home_directory}/.nvm",
    user => $username,
    cwd => "${home_directory}",
    environment => [ "HOME=$home_directory" ],
    require => User[$username],
  } -> file_line { 'nvm_initialize_sh':
    path => "${home_directory}/.bashrc",
    line => 'export NVM_DIR=$HOME/.nvm && [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"',
  }
}

# This class manage a PyEnv installation to create a
# Python development environment
class pyenv_development (
  $username,
  $home_directory,
  $install_packages = true,
  $python_versions = ["3.6.1", "3.5.3", "2.7.13"],
) {
  exec { "pyenv_install":
    command => "/usr/bin/git clone http://github.com/pyenv/pyenv .pyenv",
    cwd => "${home_directory}",
    user => "${username}",
    creates => "${home_directory}/.pyenv",
    require => [Package['git'], User[$username]]
  } -> exec { "pyenv_virtualenv_install":
    command => "/usr/bin/git clone http://github.com/pyenv/pyenv-virtualenv .pyenv/plugins/pyenv-virtualenv",
    cwd => "${home_directory}",
    user => "${username}",
    creates => "${home_directory}/.pyenv/plugins/pyenv-virtualenv",
    require => Package['git']
  } -> file_line { 'pyenv_root_environment':
    path => "${home_directory}/.bashrc",
    line => 'export PYENV_ROOT="$HOME/.pyenv"',
  } -> file_line { 'pyenv_in_path':
    path => "${home_directory}/.bashrc",
    line => 'export PATH="$PYENV_ROOT/bin:$PATH"',
  } -> file_line { 'pyenv_init':
    path => "${home_directory}/.bashrc",
    line => 'eval "$(pyenv init -)"',
  } -> file_line { 'pyenv_virtualenv_init':
    path => "${home_directory}/.bashrc",
    line => 'eval "$(pyenv virtualenv-init -)"',
  }

  if ($install_packages) {
    package { 'make': ensure => 'present' }
    package { 'build-essential': ensure => 'present' }
    package { 'libssl-dev': ensure => 'present' }
    package { 'zlib1g-dev': ensure => 'present' }
    package { 'libbz2-dev': ensure => 'present' }
    package { 'libreadline-dev': ensure => 'present' }
    package { 'libsqlite3-dev': ensure => 'present' }
    package { 'wget': ensure => 'present' }
    package { 'curl': ensure => 'present' }
    package { 'llvm': ensure => 'present' }
    package { 'libncurses5-dev': ensure => 'present' }
    package { 'xz-utils': ensure => 'present' }
    package { 'tk-dev': ensure => 'present' }
  }

  $python_versions.each |$python_version| {
    exec { "pyenv_install_python_${python_version}":
      command => "${home_directory}/.pyenv/bin/pyenv install ${python_version}",
      cwd => "${home_directory}",
      user => "${username}",
      environment => [ "PYENV_ROOT=${home_directory}/.pyenv" ],
      timeout => 1800,
      creates => "${home_directory}/.pyenv/versions/${python_version}",
      require => Exec['pyenv_install']
    }
  }
}

# Pgenv installation
class pgenv_development (
  $username,
  $home_directory,
  $install_packages = true,
  $postgres_version = "master") {

  exec { "pgenv_install":
    command => "/usr/bin/git clone https://github.com/leonardoce/pgenv ${home_directory}/pgsql",
    cwd => "${home_directory}",
    user => "${username}",
    creates => "${home_directory}/pgsql",
    require => [Package['git'], User[$username]],
  } -> exec { "postgresql_clone":
    command => "/usr/bin/git clone git://git.postgresql.org/git/postgresql.git ${home_directory}/pgsql/master",
    user => "${username}",
    creates => "${home_directory}/pgsql/master",
    timeout => 3000,
  } -> file_line { 'pgenv_initialize_sh':
    path => "${home_directory}/.bashrc",
    line => "source ${home_directory}/pgsql/pgenv.sh",
  }

  if ($install_packages) {
    package { "tcl-dev": ensure => "present" }
    package { "libssl-dev": ensure => "present" }
    package { "build-essential": ensure => "present" }
    package { "bison": ensure => "present" }
    package { "flex": ensure => "present" }
    package { "libreadline-dev": ensure => "present" }
    package { "libxml2-dev": ensure => "present" }
  }

  exec { "pgenv_configure_master":
    command => "${home_directory}/pgsql/configure-all.sh master",
    cwd => "${home_directory}/pgsql/",
    user => "${username}",
    creates => "${home_directory}/pgsql/master/config.log",
    environment => [ "HOME=${home_directory}" ],
  } -> exec { "pgenv_compile_master":
    command => "${home_directory}/pgsql/install-all.sh master",
    cwd => "${home_directory}/pgsql/",
    user => "${username}",
    creates => "${home_directory}/.pgenv/versions/master",
    environment => [ "HOME=${home_directory}" ],
  }
}

# Rust development environment
class rust_development (
  $username,
  $home_directory
) {
  exec { 'download_rustup':
    creates => '/tmp/rustup_init.sh',
    command => '/usr/bin/curl -o /tmp/rustup_init.sh https://sh.rustup.rs/',
  } -> exec { "install_rustup_for_${username}":
    creates => "${home_directory}/.cargo",
    command => '/bin/bash /tmp/rustup_init.sh -y',
    user => $username,
  } -> file_line { "rustup_in_bashrc_for_${username}":
    path => "${home_directory}/.bashrc",
    line => "source ${home_directory}/.cargo/env",
  } -> exec { "install_rust_toolchain_for_${username}":
    user => $username,
    command => "${home_directory}/.cargo/bin/rustup toolchain install stable",
    creates => "${home_directory}/.rustup/toolchains/stable-x86_64-unknown-linux-gnu",
  }
}

# Tool composing my development environment
class development_environment ( $username, $home_directory ) {
  if $::os['family'] == 'Archlinux' {
    package { 'base-devel': ensure => 'present' }
    package { 'go': ensure => 'present' }
    package { 'bzip2': ensure => 'present' }
    package { 'ncurses': ensure => 'present' }
    package { 'readline': ensure => 'present' }
    package { 'sqlite': ensure => 'present' }
    package { 'openssl': ensure => 'present' }
    package { 'libxml2': ensure => 'present' }
    package { 'tcl': ensure => 'present' }
    package { 'tk': ensure => 'present' }
    package { 'xz': ensure => 'present' }
  } elsif $::os['family'] == 'RedHat' {
    package { 'golang': ensure => 'present' }
    package { 'bzip2-devel': ensure => 'present' }
    package { 'ncurses-devel': ensure => 'present' }
    package { 'readline-devel': ensure => 'present' }
    package { 'sqlite-devel': ensure => 'present' }
    package { 'openssl-devel': ensure => 'present' }
    package { 'libxml2-devel': ensure => 'present' }
    package { 'tcl-devel': ensure => 'present' }
    package { 'tk-devel': ensure => 'present' }
    package { 'xz-devel': ensure => 'present' }
  } else {
    package { 'golang': ensure => 'present' }
    package { 'build-essential': ensure => 'present' }
    package { 'libbz2-dev': ensure => 'present' }
    package { 'libncurses5-dev': ensure => 'present' }
    package { 'libreadline-dev': ensure => 'present' }
    package { 'libsqlite3-dev': ensure => 'present' }
    package { 'libssl-dev': ensure => 'present' }
    package { 'libxml2-dev': ensure => 'present' }
    package { 'tcl-dev': ensure => 'present' }
    package { 'tk-dev': ensure => 'present' }
    package { 'xz-utils': ensure => 'present' }
  }
  package { 'curl': ensure => 'present' }
  package { 'emacs-nox': ensure => 'present' }
  package { 'flex': ensure => 'present' }
  package { 'git': ensure => 'present' }
  package { 'llvm': ensure => 'present' }
  package { 'make': ensure => 'present' }
  package { 'sudo': ensure => 'present' }
  package { 'tig': ensure => 'present' }
  package { 'vim': ensure => 'present' }
  package { 'wget': ensure => 'present' }

  if $::os['family'] == 'Archlinux' {
    package { 'zlib': ensure => 'present' }
  } elsif $::os['family'] == 'RedHat' {
    package { 'zlib-devel': ensure => 'present' }
  } else {
    package { 'zlib1g-dev': ensure => 'present' }
  }

  # Development environment
  class { "nvm_development":
    username => $username,
    home_directory => $home_directory
  }
  class { "pyenv_development":
    username => $username,
    home_directory => $home_directory,
    install_packages => false,
  }
  class { "pgenv_development":
    username => $username,
    home_directory => $home_directory,
    install_packages => false,
  }
  class { "rust_development":
    username => $username,
    home_directory => $home_directory,
  }

  # Emacs prelude installation
  exec { "install_prelude":
    command => "/usr/bin/git clone http://github.com/bbatsov/prelude .emacs.d",
    cwd => "${home_directory}",
    user => "${username}",
    creates => "${home_directory}/.emacs.d",
    require => User[$username],
  }

  # PyCharm installation
  exec { 'download_pycharm':
    command => "/usr/bin/curl --continue - -L -o /tmp/pycharm.tar.gz https://download.jetbrains.com/python/pycharm-professional-2017.1.5.tar.gz",
    creates => "/opt/pycharm-2017.1.5",
    timeout => 1800,
  } -> exec { 'extract_pycharm':
    command => "/bin/tar -C /opt -xvzf /tmp/pycharm.tar.gz",
    creates => "/opt/pycharm-2017.1.5"
  }


  $gitconfig = @(GITCONFIG)
  [user]
  email = leonardoce@interfree.it
  name = Leonardo Cecchi
  | GITCONFIG
  
  $tmuxconfig = @(TMUXCONFIG)
  set -g escape-time 0
  set -g mode-keys vi
  set -g status-style bg=blue
  
  set -g prefix C-a
  bind-key C-a send-prefix
  | TMUXCONFIG
  
  $vimconfig = @(VIMCONFIG)
  set nocompatible
  syntax on
  set ai
  
  set expandtab
  set shiftwidth=4
  set tabstop=4
  | VIMCONFIG
  
  user { $username:
    ensure => "present",
    managehome => true,
    shell => "/bin/bash",
    require => Group['docker'],
    groups => ["docker", "wheel"],
  } -> file { "${home_directory}/.gitconfig" :
    owner => "${username}",
    group => "${username}",
    content => $gitconfig,
    ensure => "present",
  } -> file { "${home_directory}/.tmux.conf" :
    owner => "${username}",
    group => "${username}",
    content => $tmuxconfig,
  } -> file { "${home_directory}/.vimrc" :
    owner => "${username}",
    group => "${username}",
    content => $vimconfig,
  } -> file_line { 'editor_in_bashrc':
    path => "${home_directory}/.bashrc",
    line => "export EDITOR=vim",
  }
}

# Graphical interface configuration
# ---------------------------------
class desktop_interface {
  if ($::os['family'] == 'Archlinux') {
    package { "xorg": ensure => 'present' }
    package { "xorg-apps": ensure => 'present' }
    package { "xorg-drivers": ensure => 'present' }
    package { "xorg-fonts": ensure => 'present' }
    package { "xorg-xinit": ensure => 'present' }
  }

  package { "i3": ensure => "present" }
  package { "i3status": ensure => "present" }
  package { "dmenu": ensure => "present" }
  package { "xterm": ensure => "present" }
  package { "feh": ensure => "present" }

  if ($::os['family'] == 'Archlinux') {
    package { "ttf-dejavu": ensure => "present" }
    package { "chromium": ensure => "present" }
    package { "evince": ensure => "present" }
    package { "vlc": ensure => "present" }
  } elsif ($::os['family'] == 'RedHat') {
    package { "chromium": ensure => "present" }
    package { "evince": ensure => "present" }
  } else {
    package { "vlc": ensure => "present" }
    package { "chromium-browser": ensure => "present" }
  }
  package { "firefox": ensure => "present" }
}

# Virtualization
# --------------
class virtualization_support {
  package { "vagrant": ensure => "present" }
  package { "virtualbox": ensure => "present" }
}

# Linux containers
# ----------------
class containers_support {
  if ($::os['family'] == 'Archlinux') {
    package { "docker": ensure => "present" }
  } elsif ($::os['family'] == 'RedHat') {
    package { "docker": ensure => "present" }
  } else {
    package { "docker.io": ensure => "present" }
  }

  group { "docker":
    ensure => "present"
  }
}


# ----------------------------------------
# Actual development machine configuration
# ----------------------------------------

class { "development_environment" :
  username => "leonardo",
  home_directory => "/home/leonardo"
}

class { "containers_support" : }

if (! $facts['is_virtual']) {
  class { "virtualization_support" : }
  class { "desktop_interface" : }
}

# Useful packages
if $::os['family'] == 'Archlinux' {
  package { "openssh": ensure => "present" }
} else {
  package { "openssh-server": ensure => "present" }
}
package { "tmux": ensure => "present" }
package { "iotop": ensure => "present" }
package { "iftop": ensure => "present" }
package { "htop": ensure => "present" }
package { "powertop": ensure => "present" }

# TODO: Install haskell compiler
