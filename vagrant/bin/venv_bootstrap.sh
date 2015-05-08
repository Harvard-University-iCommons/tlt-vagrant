#!/bin/bash

export HOME=/home/vagrant
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

# Make icommons_lti_tools virtualenv
mkvirtualenv -a /home/vagrant/tlt/icommons_lti_tools icommons_lti_tools
workon icommons_lti_tools
pip install -r /home/vagrant/tlt/icommons_lti_tools/icommons_lti_tools/requirements/local.txt
pip install -r /vagrant/vagrant/requirements/base.txt

# Make ab-testing-tool virtualenv
mkvirtualenv -a /home/vagrant/tlt/ab_testing_tool ab_testing_tool
workon ab_testing_tool
pip install -r /home/vagrant/tlt/ab_testing_tool/ab_testing_tool/requirements/local.txt
pip install -r /vagrant/vagrant/requirements/base.txt

# Make lti_emailer virtualenv
mkvirtualenv -a /home/vagrant/tlt/lti_emailer lti_emailer
workon lti_emailer
pip install -r /home/vagrant/tlt/lti_emailer/lti_emailer/requirements/local.txt
pip install -r /vagrant/vagrant/requirements/base.txt

# Make icommons_tools virtualenv
mkvirtualenv -a /home/vagrant/tlt/icommons_tools icommons_tools
workon icommons_tools
pip install -r /home/vagrant/tlt/icommons_tools/icommons_tools/requirements/local.txt
pip install -r /vagrant/vagrant/requirements/base.txt
