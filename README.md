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
    $ cd ~/scripts
    $ ./install_canvas.sh --full

### Shut down the vagrant box ###

    $ cd ~/tlt/tlt-vagrant
    $ vagrant halt

### (Re)Create a Postgres DB for a given Django project


The optional -m flag will perform a Django migrate after the db is created, and
the assumption in that case is that the name given via the -d option corresponds
to a project/virtualenv.  NOTE: make sure the password specified during creation
is copied into the specified project's secure.py file.


    $ cd ~/tlt/tlt-vagrant
    $ vagrant ssh
    $ bash ~/scripts/init_postgres_db.sh -d [project_name] -p [db_password] -m
