# This class manage an NVM installation for a certain
# user.
class nvm_development ( $username, $home_directory ) {
  exec { "nvm_install":
    command => "/usr/bin/curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.2/install.sh | bash",
    creates => "${home_directory}/.nvm",
    user => $username,
    cwd => "${home_directory}",
    environment => [ "HOME=$home_directory" ]
  }

  file_line { 'nvm_initialize_sh':
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
  $python_version = "3.6.1"
) {
  exec { "pyenv_install":
    command => "/usr/bin/git clone http://github.com/pyenv/pyenv .pyenv",
    cwd => "${home_directory}",
    user => "${username}",
    creates => "${home_directory}/.pyenv",
    require => Package['git']
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

  file_line { 'pyenv_root_environment':
    path => "${home_directory}/.bashrc",
    line => 'export PYENV_ROOT="$HOME/.pyenv"',
  }

  file_line { 'pyenv_in_path':
    path => "${home_directory}/.bashrc",
    line => 'export PATH="$PYENV_ROOT/bin:$PATH"',
    #require => FileLine['pyenv_root_environment']
  }

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

# Tool composing a development environment
class leonardo_development ( $username, $home_directory ) {
  class { "nvm_development":
    username => $username,
    home_directory => $home_directory
  }
  class { "pyenv_development":
    username => $username,
    home_directory => $home_directory
  }
  package { "git": ensure => "present" }
  package { "vim": ensure => "present" }
  package { "emacs-nox": ensure => "present" }

  # Installing Spacemacs
  exec { "install_spacemacs":
    command => "/usr/bin/git clone http://github.com/syl20bnr/spacemacs .emacs.d",
    cwd => "${home_directory}",
    user => "${username}",
    creates => "${home_directory}/.emacs.d",
    require => Package['git']
  }
}

# Graphical interface configuration
class leonardo_gui {
  package { "i3": ensure => "present" }
  package { "i3status": ensure => "present" }
  package { "dmenu": ensure => "present" }
  package { "xterm": ensure => "present" }
  package { "feh": ensure => "present" }

  package { "chromium-browser": ensure => "present" }
  package { "firefox": ensure => "present" }
}

# Actual development machine configuration
# ----------------------------------------

class { "leonardo_development" :
  username => "leonardo",
  home_directory => "/home/leonardo"
}

class { "leonardo_gui" : }