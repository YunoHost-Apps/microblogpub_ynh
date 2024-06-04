#!/bin/bash

#=================================================
# COMMON VARIABLES
#=================================================

#=================================================
# PERSONAL HELPERS
#=================================================

# Python version to be installed by pyenv
python_version=3.10.6

microblogpub_install_python () {
    # Install/update pyenv
    ynh_setup_source --dest_dir="$install_dir/.pyenv" --source_id=pyenv
    export PYENV_ROOT=${install_dir}/pyenv

    if [ -d "$install_dir/pyenv/versions" ]; then
        old_python_version=`ls $install_dir/pyenv/versions`
        if [ ! -z "${old_python_version}" ]; then
            if [ "${old_python_version}" != "${python_version}" ]; then
                old_python_version_path="${install_dir}/pyenv/versions/${old_python_version}"
                if [ -d "${old_python_version_path}" ]; then
                    ynh_print_info --message="Deleting Python ${old_python_version}"
                    ynh_secure_remove --file="${old_python_version_path}"
                fi
            fi
        fi
    fi

    if [ ! -d "${install_dir}/pyenv/versions/${python_version}" ]; then
        ynh_print_info --message="Installing Python ${python_version}"
        $install_dir/.pyenv/bin/pyenv install $python_version
        ynh_app_setting_set --app=$YNH_APP_INSTANCE_NAME --key=python_version --value=$python_version
    else
        ynh_print_info --message="Python ${python_version} is already installed"
    fi 
}

microblogpub_install_deps () {
    ynh_print_info --message="Installing deps with poetry"
    (
        export PATH="${install_dir}/pyenv/versions/${python_version}/bin:$PATH"
		# pip and poetry run from the above set pyenv path and knows where to install packages
        pip install poetry
        export POETRY_VIRTUALENVS_PATH=${install_dir}/venv
        cd $install_dir/app
        poetry install
    )
}

microblogpub_update () {
    ynh_print_info --message="Updating microblogpub"
    (
        export PATH="${install_dir}/pyenv/versions/${python_version}/bin:$PATH"
        cd ${install_dir}/app
        export POETRY_VIRTUALENVS_PATH=${install_dir}/venv
        poetry run inv update
    )
}

microblogpub_set_version() {
    version_file="${install_dir}/microblogpub/app/_version.py"
    app_package_version=$(ynh_app_package_version)
    echo "VERSION_COMMIT = \"ynh${app_package_version}\"" > $version_file
}

#=================================================
# EXPERIMENTAL HELPERS
#=================================================

#=================================================
# FUTURE OFFICIAL HELPERS
#=================================================
