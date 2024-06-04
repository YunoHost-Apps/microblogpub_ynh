#!/bin/bash

# path to microblog.pub istself
microblogpub_app="$install_dir/app"

# path to microblog.pubs venv
microblogpub_venv="$install_dir/venv"

# path to microblog.pubs pyenv sources
microblogpub_src_pyenv="$install_dir/pyenv.src"

# path to microblog.pubs pyenv (python version)
microblogpub_pyenv="$install_dir/pyenv"

# Python version to be installed by pyenv
python_version=3.10.6

microblogpub_install_python () {
    # Install/update pyenv
    ynh_setup_source --dest_dir="${microblogpub_src_pyenv}" --source_id=pyenv
    export PYENV_ROOT=${microblogpub_pyenv}

    if [ -d "${microblogpub_pyenv}/versions" ]; then
        local old_python_version=`ls ${microblogpub_pyenv}/versions`
        if [ ! -z "${old_python_version}" ]; then
            if [ "${old_python_version}" != "${python_version}" ]; then
                local old_python_version_path="${microblogpub_pyenv}/versions/${old_python_version}"
                if [ -d "${old_python_version_path}" ]; then
                    ynh_print_info --message="Deleting Python ${old_python_version}"
                    ynh_secure_remove --file="${old_python_version_path}"
                fi
            fi
        fi
    fi

    if [ ! -d "${microblogpub_pyenv}/versions/${python_version}" ]; then
        ynh_print_info --message="Installing Python ${python_version}"
        ${microblogpub_src_pyenv}/bin/pyenv install $python_version
        ynh_app_setting_set --app=$YNH_APP_INSTANCE_NAME --key=python_version --value=$python_version
    else
        ynh_print_info --message="Python ${python_version} is already installed"
    fi 
}

microblogpub_install_deps () {
    ynh_print_info --message="Installing deps with poetry"
    (
        export PATH="${microblogpub_pyenv}/versions/${python_version}/bin:$PATH"
		# pip and poetry run from the above set pyenv path and knows where to install packages
        pip install poetry
        export POETRY_VIRTUALENVS_PATH=${microblogpub_venv}
        cd ${microblogpub_app}
        poetry install
    )
}

microblogpub_update () {
    ynh_print_info --message="Updating microblogpub"
    (
        export PATH="${microblogpub_pyenv}/versions/${python_version}/bin:$PATH"
        cd ${microblogpub_app}
        export POETRY_VIRTUALENVS_PATH=${microblogpub_pyenv}
        poetry run inv update
    )
}

microblogpub_set_version() {
    version_file="${microblogpub_app}/app/_version.py"
    app_package_version=$(ynh_app_package_version)
    echo "VERSION_COMMIT = \"ynh${app_package_version}\"" > $version_file
}

microblogpub_initial_setup() {
    (
        # Setup initial configuration
        export PATH="${install_dir}/pyenv/versions/${python_version}/bin:$PATH"
        cd ${install_dir}/microblogpub
        export POETRY_VIRTUALENVS_PATH=${install_dir}/venv
        poetry run inv yunohost-config --domain="${domain}" --username="${username}" --name="${name}" --summary="${summary}" --password="${password}"
    
    )
}
