#!/usr/bin/env bash

set -ex

# Install pyenv
curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer -o /tmp/pyenv-installer
touch ~/.bashrc
/bin/ln -s ~/.bashrc ~/.bash_profile || true
/bin/bash /tmp/pyenv-installer
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bash_profile
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"


# Find latest versions
readarray -t PYTHON_VERSIONS < PYTHON_VERSIONS

VERSIONS=()
pyenv install -l > /tmp/all_pyenv_versions
for v in "${PYTHON_VERSIONS[@]}"; do
    MAJOR=$(echo $v | awk -F. '{print $1}')
    MINOR=$(echo $v | awk -F. '{print $2}')
    MICRO=$(cat /tmp/all_pyenv_versions | sed -n "s/^[ tab]\+${MAJOR}\.${MINOR}\.\([0-9]\+\)/\1/p" |sort -rgu | head -1)
    VERSIONS+=("${MAJOR}.${MINOR}.${MICRO}")
done

# Install all python versions
for v in "${VERSIONS[@]}"; do
    pyenv install $v
done

# Install pip in all python versions
for v in "${VERSIONS[@]}"; do
    pyenv shell $v
    pip install -U pip &
done
wait

# Install tox in all python versions
for v in "${VERSIONS[@]}"; do
    pyenv shell $v
    pip install -U tox &
done
wait

# Set global python version
pyenv global "${VERSIONS[@]}"

# Cleanup
rm /tmp/pyenv-installer
rm -rf /tmp/python*
rm -rf /tmp/pip*
rm -rf /tmp/all_pyenv_versions
