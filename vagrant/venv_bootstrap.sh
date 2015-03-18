#!/bin/bash
export HOME=/home/vagrant
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

# Make icommons_lti_tools virtualenv
mkvirtualenv -a /home/vagrant/icommons_lti_tools icommons_lti_tools
workon icommons_lti_tools
#pip install -r /home/vagrant/icommons_lti_tools/icommons_lti_tools/requirements/base.txt
pip install -r /vagrant/requirements/icommons_lti_tools.txt

# Make ab-testing-tool virtualenv
mkvirtualenv -a /home/vagrant/ab-testing-tool ab-testing-tool
workon ab-testing-tool
#pip install -r /home/vagrant/ab-testing-tool/ab-testing-tool/requirements/base.txt
#pip install -r requirements/ab-testing-tool.txt
