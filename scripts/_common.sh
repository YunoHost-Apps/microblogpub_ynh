#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

# dependencies used by the app
pkg_dependencies="python3 python3-dev libxml2-dev libxslt-dev gcc libjpeg-dev zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev liblzma-dev"

#=================================================
# PERSONAL HELPERS
#=================================================
python_version=3.10.6

microblogpub_install_python () {
    # TODO: delete old Python version
    local final_path="$1"
    if [ ! -d "${final_path}/pyenv/versions/${python_version}" ]; then
        ynh_print_info --message="Installing Python ${python_version}"
        export PYENV_ROOT=${final_path}/pyenv
        ${final_path}/.pyenv/bin/pyenv install $python_version
    else
        ynh_print_info --message="Python ${python_version} already installed"
    fi 
}

microblogpub_install_deps () {
    local final_path="$1"
    export PATH="${final_path}/pyenv/versions/${python_version}/bin:$PATH"
    pip install poetry
    export POETRY_VIRTUALENVS_PATH=${final_path}/venv
    cd ${final_path}/microblogpub
    poetry install
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
