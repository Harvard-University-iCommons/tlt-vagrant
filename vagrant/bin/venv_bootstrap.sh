#!/bin/bash

export HOME=/home/vagrant
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

mkvirtualenv -a /home/vagrant/tlt/$1 $1 \
	&& workon $1 \
	&& pip install -r /home/vagrant/tlt/${1}/${1}/requirements/local.txt
