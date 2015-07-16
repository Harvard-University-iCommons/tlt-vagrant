# README #

## Vagrant Box Development Environment ##

### Quick summary ###

This project provides a Vagrant box development environment setup for TLT development. We use Puppet
to configure a base Ubuntu Precise 64 box.

~/tlt is shared with the Vagrant box to allow for the use of GUI development tools on the local machine.
Ports 3000, 8000, 8001, 8002 are forwarded from the local machine to the Vagrant box to allow access 
to multiple applications running on the box.

## Setup ##

### Clone tlt-vagrant repository ###

    $ mkdir ~/tlt
    $ cd ~/tlt
    $ git clone git@github.com:Harvard-University-iCommons/tlt-vagrant.git

### Start/Provision Vagrant box ###

    $ cd ~/tlt/tlt-vagrant
    $ vagrant up

### Access the Vagrant box shell ###

    $ cd ~/tlt/tlt-vagrant
    $ vagrant ssh

### Install Canvas ###

    $ cd ~/tlt/tlt-vagrant
    $ vagrant ssh
    $ cd ~/tlt/tlt-vagrant/vagrant/bin
    $ ./CODES.sh --full

### Shut down the vagrant box ###

    $ cd ~/tlt/tlt-vagrant
    $ vagrant halt
