#!/bin/bash

python_version=3.10.6                                   # python version to be installed by pyenv
microblogpub_app="$install_dir/app"                     # path to microblog.pub istself
microblogpub_venv="$install_dir/venv"                   # path to microblog.pubs venvsa
microblogpub_src_pyenv="$install_dir/pyenv.src"         # path to microblog.pubs pyenv sources
microblogpub_pyenv="$install_dir/pyenv"                 # path to microblog.pubs python version
microblogpub_bin_pyenv="${microblogpub_pyenv}/versions/${python_version}/bin" # pyenv exectutablesa
microblogpub_active_venv='not_found'                    # initialize path to active venv

microblogpub_set_active_venv() {
    # poetry installs the venv to a path that cannot be given to it
    # https://github.com/python-poetry/poetry/issues/2003
    # we set the path to the active venv installed through poetry by
    # using the apropriate poetry command: `env info --path`
    microblogpub_active_venv=$(
        export PATH="${microblogpub_bin_pyenv}:$PATH"
        export POETRY_VIRTUALENVS_PATH=${microblogpub_venv}
        cd ${microblogpub_app}
        poetry env info --path
    )
}

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
        export PATH="${microblogpub_bin_pyenv}:$PATH"
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
        export PATH="${microblogpub_bin_pyenv}:$PATH"
        cd ${microblogpub_app}
        export POETRY_VIRTUALENVS_PATH=${microblogpub_venv}
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
        export PATH="${microblogpub_bin_pyenv}:$PATH"
        cd ${microblogpub_app}
        export POETRY_VIRTUALENVS_PATH=${microblogpub_venv}
        poetry run inv yunohost-config --domain="${domain}" --username="${username}" --name="${name}" --summary="${summary}" --password="${password}"
    )
}
