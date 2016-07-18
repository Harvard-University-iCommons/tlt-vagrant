# puppet manifest

include apt

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
}

# add extra apt sources
apt::source { 'mongodb-apt-source':
    location => 'http://repo.mongodb.org/apt/ubuntu',
    release => 'trusty/mongodb-org/3.0',
    repos => 'multiverse',
    key => {
        id => '7F0CEB10',
        server => 'keyserver.ubuntu.com',
    },
}

apt::source { 'postgresql-apt-source':
    location => 'http://apt.postgresql.org/pub/repos/apt/',
    release => 'trusty-pgdg',
    repos => 'main',
    key => {
        'id' => 'B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8',
        'source' => 'https://www.postgresql.org/media/keys/ACCC4CF8.asc',
    },
}

apt::source { 'nodesource-apt-source':
    location => 'https://deb.nodesource.com/node_0.12',
    release => 'trusty',
    repos => 'main',
    key => {
        'id' => '9FD3B784BC1C6FC31A8A0A1C1655A0AB68576280',
        'source' => 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key',
    },
}

# Refresh the catalog of repositories from which packages can be installed:
exec {'apt-get-update':
    command => 'apt-get update',
    require => [
        Apt::Source['mongodb-apt-source'],
        Apt::Source['postgresql-apt-source'],
        Apt::Source['nodesource-apt-source'],
    ],
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

package {'nfs-common':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'portmap':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'zlib1g-dev':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'ruby1.9.1-dev':
    ensure => installed,
    require => Exec['apt-get-update'],
}

package {'libsqlite3-dev':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package{'libffi-dev':
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

package {'vim':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'htop':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'nodejs':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'ntp':
    ensure => latest,
    require => Exec['apt-get-update'],
} 

service {'ntp':
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package['ntp'],
}

# needed for selenium tests
package {'xvfb':
    ensure => latest,
    require => Exec['apt-get-update'],
}

package {'firefox':
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
    command => 'sudo -u postgres psql -c "CREATE ROLE vagrant SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN PASSWORD \'vagrant\'"',
    unless => 'sudo -u postgres psql -qt -c "select 1 from pg_roles where rolname=\'vagrant\'" | grep -q 1',
}

# Create vagrant db for postgresql
exec {'create-postgresql-db':
    require => Exec['create-postgresql-user'],
    command => 'sudo -u postgres createdb vagrant',
    unless => 'sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -wq vagrant',
}

# ensure the postgresql config allows connections from vagrant host
# NOTE: this will need updating if we change postgresql minor versions

file {'/etc/postgresql/9.5/main/postgresql.conf':
    require => Package['postgresql'],
    ensure => 'present',
}

file_line {'postgresql-conf-listen':
    require => [Package['postgresql'],
                File['/etc/postgresql/9.5/main/postgresql.conf']],
    path => '/etc/postgresql/9.5/main/postgresql.conf',
    line => "listen_addresses = '*'",
    notify => Service['postgresql'],
}

file {'/etc/postgresql/9.5/main/pg_hba.conf':
    require => Package['postgresql'],
    ensure => 'present',
}

file_line {'pg-hba-conf-listen':
    require => [Package['postgresql'],
                File['/etc/postgresql/9.5/main/pg_hba.conf']],
    path => '/etc/postgresql/9.5/main/pg_hba.conf',
    line => 'host    all     all     0.0.0.0/0       md5',
    notify => Service['postgresql'],
}

service {'postgresql':
    ensure => running,
    enable => true,
    hasrestart => true,
    require => Package['postgresql'],
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

# Install less
exec {'install_less':
    provider => 'shell',
    command => 'npm install -g less',
    require => Package['nodejs'],
    creates => '/usr/bin/lessc',
}

# Install coffeescript
exec {'install_coffeescript':
    provider => 'shell',
    command => 'npm install -g coffee-script',
    require => Package['nodejs'],
    creates => '/usr/bin/coffee',
}

# Install karma
exec {'install_karma_cli':
    provider => 'shell',
    command => 'npm install -g karma-cli',
    require => Package['nodejs'],
    creates => '/usr/bin/karma',
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
    provider => 'yuavpip',
    require => [ Package['python-pip'], ],
}

package {'virtualenvwrapper':
    ensure => latest,
    provider => 'yuavpip',
    require => [ Package['python-pip'], ],
}

file {'/etc/profile.d/venvwrapper.sh':
    ensure => file,
    content => 'source `which virtualenvwrapper.sh`',
    mode => '755',
    require => Package['virtualenvwrapper'],
}

file {'/home/vagrant/.virtualenvs':
    ensure => 'directory',
    owner => 'vagrant',
}

file {'/home/vagrant/.virtualenvs/postactivate':
    owner => 'vagrant',
    content => '
#!/bin/bash
# This hook is sourced after every virtualenv is activated.

export DJANGO_SETTINGS_MODULE=`basename $VIRTUAL_ENV`.settings.local
    ',
    require => File['/home/vagrant/.virtualenvs'],
}

define create_virtualenv($project=$title) {
    exec {
        "create_virtualenv_${project}":
            provider => 'shell',
            user => 'vagrant',
            group => 'vagrant',
            require => [
                Package['virtualenvwrapper'],
                File['/etc/profile.d/oracle.sh'],
                File['/etc/profile.d/venvwrapper.sh'],
                Exec['known_hosts'],
            ],
            environment => [
                'HOME=/home/vagrant',
                'LD_LIBRARY_PATH=/opt/oracle/instantclient_11_2',
                'ORACLE_HOME=/opt/oracle/instantclient_11_2',
                'WORKON_HOME=/home/vagrant/.virtualenvs',
            ],
            command => "/vagrant/vagrant/bin/venv_bootstrap.sh ${project}",
            creates => "/home/vagrant/.virtualenvs/${project}",
            onlyif => "test -f /home/vagrant/tlt/${project}/${project}/requirements/local.txt",
            timeout => 600,
    }
}

# Store results of a per-line listing of the tlt directory in a string
$project_strs = generate("/bin/ls", "-1", "/home/vagrant/tlt")

# Convert string to array
$projects = split($project_strs, "[\n\r]")

# Pass array along to the create_virtualenv function
create_virtualenv { $projects: }

file {'/home/vagrant/.git_completion.sh':
    owner => 'vagrant',
    source => '/vagrant/vagrant/bin/.git_completion.sh',
}

file {'/home/vagrant/.bash_profile':
    owner => 'vagrant',
    content => '
if [ -f ~/.git_completion.bash ]; then
  . ~/.git_completion.bash
fi

# Show git repo branch at bash prompt
parse_git_branch() {
    git branch 2> /dev/null | sed -e \'/^[^*]/d\' -e \'s/* \(.*\)/(\1)/\'
}
PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$(parse_git_branch) $ "

# if we got a project in $TLT_PROJECT, activate its virtualenv
if [[ "$TLT_PROJECT" != "" && -d ~/tlt/$TLT_PROJECT ]]; then
        workon $TLT_PROJECT
fi
    ',
}
