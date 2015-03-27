# puppet manifest

# Make sure the correct directories are in the path:
Exec {
    path => [
    '/usr/local/sbin',
    '/usr/local/bin',
    '/usr/sbin',
    '/usr/bin',
    '/sbin',
    '/bin',
    ],
    logoutput => true,
}

# Refresh the catalog of repositories from which packages can be installed:
exec {'apt-get-update':
    command => 'apt-get update'
}

# make sure we have some basic tools and libraries available

package {'redis-server':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'libxslt1-dev':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'build-essential':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'python-dev':
    ensure => installed,
    require => Exec['apt-get-update']
}

package {'python-pip':
    ensure => installed,
    require => Package['python-dev']
}

package {'libaio1':
    ensure => installed,
    require => Exec['apt-get-update']
}

package {'libaio-dev':
    ensure => installed,
    require => Exec['apt-get-update']
}

package {'libpq-dev':
    ensure => installed,
    require => Exec['apt-get-update']
}

package {'git':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'unzip':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'curl':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'wget':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'libcurl4-openssl-dev':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'openssl':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'zlib1g-dev':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'libsqlite3-dev':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'sqlite3':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'mongodb-org':
    ensure => latest,
    require => Exec['apt-get-update'],
}

# Install Postgresql
package {'postgresql':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'postgresql-contrib':
    ensure => latest,
    require => Exec['apt-get-update'],
}

# Create vagrant user for postgresql
exec {'create-postgresql-user':
    require => Package['postgresql'],
    command => 'sudo -u postgres createuser --superuser vagrant'
}

# Create vagrant db for postgresql
exec {'create-postgresql-db':
    require => Exec['create-postgresql-user'],
    command => 'sudo -u postgres createdb vagrant'
}

# Install the Oracle instant client

# This is a helper function to retrieve files from URLs:
define download ($uri, $timeout = 300) {
  exec {
      "download $uri":
          command => "wget -q '$uri' -O $name",
          creates => $name,
          timeout => $timeout,
          require => Package['wget'],
  }
}

# Using the helper function above, download the Oracle instantclient zip files:
download {
  "/tmp/instantclient-basiclite-linux.x64-11.2.0.3.0.zip":
      uri => "https://s3.amazonaws.com/icommons-static/oracle/instantclient-basiclite-linux.x64-11.2.0.3.0.zip",
      timeout => 900;
}

download {
  "/tmp/instantclient-sqlplus-linux.x64-11.2.0.3.0.zip":
      uri => "https://s3.amazonaws.com/icommons-static/oracle/instantclient-sqlplus-linux.x64-11.2.0.3.0.zip",
      timeout => 900;
}

download {
  "/tmp/instantclient-sdk-linux.x64-11.2.0.3.0.zip":
      uri => "https://s3.amazonaws.com/icommons-static/oracle/instantclient-sdk-linux.x64-11.2.0.3.0.zip",
      timeout => 900;
}

# Create the directory where the Oracle instantclient will be installed
file {'/opt/oracle':
    ensure => directory,
}

# Unzip the three Oracle zip files that we downloaded earlier:
exec {'instantclient-basiclite':
    require => [ Download['/tmp/instantclient-basiclite-linux.x64-11.2.0.3.0.zip'], File['/opt/oracle'], Package['unzip'] ],
    cwd => '/opt/oracle',
    command => 'unzip /tmp/instantclient-basiclite-linux.x64-11.2.0.3.0.zip',
    creates => '/opt/oracle/instantclient_11_2/BASIC_LITE_README',
}

exec {'instantclient-sqlplus':
    require => [ Download['/tmp/instantclient-sqlplus-linux.x64-11.2.0.3.0.zip'], File['/opt/oracle'], Package['unzip'] ],
    cwd => '/opt/oracle',
    command => 'unzip /tmp/instantclient-sqlplus-linux.x64-11.2.0.3.0.zip',
    creates => '/opt/oracle/instantclient_11_2/sqlplus',
}

exec {'instantclient-sdk':
    require => [ Download['/tmp/instantclient-sdk-linux.x64-11.2.0.3.0.zip'], File['/opt/oracle'], Package['unzip'] ],
    cwd => '/opt/oracle',
    command => 'unzip /tmp/instantclient-sdk-linux.x64-11.2.0.3.0.zip',
    creates => '/opt/oracle/instantclient_11_2/sdk',
}

# Create some symlinks that are missing:
file {'/opt/oracle/instantclient_11_2/libclntsh.so':
    ensure => link,
    target => 'libclntsh.so.11.1',
    require => Exec['instantclient-basiclite'],
}

file {'/opt/oracle/instantclient_11_2/libocci.so':
    ensure => link,
    target => 'libocci.so.11.1',
    require => Exec['instantclient-basiclite'],
}

# Make sure that the ORACLE_HOME, PATH, and LD_LIBRARY_PATH environment variables are set properly:
file {'/etc/profile.d/oracle.sh':
    ensure => file,
    content => 'export ORACLE_HOME=/opt/oracle/instantclient_11_2; export PATH=$ORACLE_HOME:$PATH; export LD_LIBRARY_PATH=$ORACLE_HOME',
    mode => '755',
    require => Exec['instantclient-basiclite'],
}

# Ensure github.com ssh public key is in the .ssh/known_hosts file so
# pip won't try to prompt on the terminal to accept it
file {'/home/vagrant/.ssh':
    ensure => directory,
    mode => 0700,
}

exec {'known_hosts':
    provider => 'shell',
    user => 'vagrant',
    group => 'vagrant',
    command => 'ssh-keyscan github.com >> /home/vagrant/.ssh/known_hosts',
    unless => 'grep -sq github.com /home/vagrant/.ssh/known_hosts',
    require => [ File['/home/vagrant/.ssh'], ],
}

file {'/home/vagrant/.ssh/known_hosts':
    ensure => file,
    mode => 0744,
    require => [ Exec['known_hosts'], ],
}

# install virtualenv and virtualenvwrapper - depends on pip

package {'virtualenv':
    ensure => latest,
    provider => 'pip',
    require => [ Package['python-pip'], ],
}

package {'virtualenvwrapper':
    ensure => latest,
    provider => 'pip',
    require => [ Package['python-pip'], ],
}

file {'/etc/profile.d/venvwrapper.sh':
    ensure => file,
    content => 'source `which virtualenvwrapper.sh`',
    mode => '755',
    require => Package['virtualenvwrapper'],
}

# Create a virtualenv for <project_name>
exec {'create-virtualenv':
    provider => 'shell',
    user => 'vagrant',
    group => 'vagrant',
    require => [ Package['virtualenvwrapper'], File['/etc/profile.d/oracle.sh'], File['/etc/profile.d/venvwrapper.sh'], Exec['known_hosts'] ],
    environment => ["ORACLE_HOME=/opt/oracle/instantclient_11_2","LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2","HOME=/home/vagrant","WORKON_HOME=/home/vagrant/.virtualenvs"],
    command => '/vagrant/vagrant/bin/venv_bootstrap.sh',
    creates => '/home/vagrant/.virtualenvs/icommons_lti_tools',
}

# Set up git hooks
file {'/home/vagrant/icommons_lti_tools/.git/hooks/pre-commit':
    ensure => link,
    target => '/home/vagrant/icommons_lti_tools/.git_template/hooks/pre-commit',
    require => Exec['create-virtualenv'],
}

file {'/home/vagrant/ab_testing_tool/.git/hooks/pre-commit':
    ensure => link,
    target => '/home/vagrant/ab_testing_tool/.git_template/hooks/pre-commit',
    require => Exec['create-virtualenv'],
}

# Add virtualenvwrapper postactivate hook to customize the virtualenv
file {'/home/vagrant/.virtualenvs/postactivate':
    owner => 'vagrant',
    content => '
#!/bin/bash
# This hook is sourced after every virtualenv is activated.

export DJANGO_SETTINGS_MODULE=`basename $VIRTUAL_ENV`.settings.local

# Show git repo branch and active virtualenv at bash prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e \'/^[^*]/d\' -e \'s/* \(.*\)/(\1)/\'
}
PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w(`basename \"$VIRTUAL_ENV\"`)\$(parse_git_branch) $ "
    ',
    require => Exec['create-virtualenv'],
}

file {'/home/vagrant/.git_completion.sh':
    ensure => present,
    source => '/vagrant/bin/.git_completion.sh',
    mode => '755'
}

# Activate icommons_lti_tools virtualenv upon login
# Add git branch to terminal prompt
file {'/home/vagrant/.bash_profile':
    owner => 'vagrant',
    content => '
echo "Activating python virtual environment \"icommons_lti_tools\""
workon icommons_lti_tools

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
    ',
    require => [ File['/home/vagrant/.virtualenvs/postactivate'], File['/home/vagrant/.git_completion.sh'] ]
}
