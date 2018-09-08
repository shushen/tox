#!/bin/bash

PYTHON_VERSIONS=(2.7.15 3.4.9 3.5.6 3.6.6 3.7.0)
PYTHON_GLOBAL_VERSION=3.7.0

# Install pyenv
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer -o /pyenv-installer
touch /root/.bashrc
/bin/ln -s /root/.bashrc /root/.bash_profile
/bin/bash /pyenv-installer
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

# Install all python versions
for v in "${PYTHON_VERSIONS[@]}"; do
    pyenv install -v $v &
done
wait

# Install pip in all python versions
for v in "${PYTHON_VERSIONS[@]}"; do
    pyenv shell $v
    pip install -U pip &
done
wait

# Install tox in all python versions
for v in "${PYTHON_VERSIONS[@]}"; do
    pyenv shell $v
    pip install -U tox &
done
wait

# Set global python version
pyenv global $PYTHON_GLOBAL_VERSION "${PYTHON_VERSIONS[@]}"

# Cleanup
rm /pyenv-installer
rm -rf /tmp/python*
rm -rf /tmp/pip*
