#!/bin/bash

export HOME=/home/vagrant
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

ssh -o StrictHostKeyChecking=no git@bitbucket.org;
ssh -o StrictHostKeyChecking=no git@github.com;

# Make icommons_lti_tools virtualenv
mkvirtualenv -a /home/vagrant/icommons_lti_tools icommons_lti_tools
workon icommons_lti_tools
pip install -r /home/vagrant/icommons_lti_tools/icommons_lti_tools/requirements/local.txt
pip install -r /vagrant/vagrant/requirements/base.txt

# Make ab-testing-tool virtualenv
mkvirtualenv -a /home/vagrant/ab_testing_tool ab_testing_tool
workon ab_testing_tool
pip install -r /home/vagrant/ab_testing_tool/ab_testing_tool/requirements/local.txt
pip install -r /vagrant/vagrant/requirements/base.txt
