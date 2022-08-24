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
    local final_path="/opt/yunohost/${YNH_APP_INSTANCE_NAME}"
    # Install/update pyenv
    ynh_setup_source --dest_dir="$final_path/.pyenv" --source_id=pyenv
    export PYENV_ROOT=${final_path}/pyenv

    if [ -d "$final_path/pyenv/versions" ]; then
        old_python_version=`ls $final_path/pyenv/versions`
        if [ ! -z "${old_python_version}" ]; then
            if [ "${old_python_version}" != "${python_version}" ]; then
                old_python_version_path="${final_path}/pyenv/versions/${old_python_version}"
                if [ -d "${old_python_version_path}" ]; then
                    ynh_print_info --message="Deleting Python ${old_python_version}"
                    ynh_secure_remove --file="${old_python_version_path}"
                fi
            fi
        fi
    fi

    if [ ! -d "${final_path}/pyenv/versions/${python_version}" ]; then
        ynh_print_info --message="Installing Python ${python_version}"
        $final_path/.pyenv/bin/pyenv install $python_version
        ynh_app_setting_set --app=$YNH_APP_INSTANCE_NAME --key=python_version --value=$python_version
    else
        ynh_print_info --message="Python ${python_version} is already installed"
    fi 
}

microblogpub_install_deps () {
    ynh_print_info --message="Installing deps with poetry"
    local final_path="/opt/yunohost/${YNH_APP_INSTANCE_NAME}"
    (
        export PATH="${final_path}/pyenv/versions/${python_version}/bin:$PATH"
        pip install poetry
        export POETRY_VIRTUALENVS_PATH=${final_path}/venv
        cd $final_path/microblogpub
        poetry install
    )
}

microblogpub_update () {
    ynh_print_info --message="Updating microblogpub"
    local final_path="/opt/yunohost/${YNH_APP_INSTANCE_NAME}"
    (
        export PATH="${final_path}/pyenv/versions/${python_version}/bin:$PATH"
        cd ${final_path}/microblogpub
        export POETRY_VIRTUALENVS_PATH=${final_path}/venv
        poetry run inv update
    )
}

microblogpub_set_version() {
    local final_path="/opt/yunohost/${YNH_APP_INSTANCE_NAME}"
    version_file="${final_path}/microblogpub/app/_version.py"
    touch $version_file
    local version=ynh_app_upstream_version
    local package_version=ynh_app_package_version
    ynh_write_var_in_file --file=$version_file --key="VERSION" --value="${version}+ynh${package_version}"
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
