#!/bin/bash

python_version=3.10.6                                   # python version to be installed by pyenv
microblogpub_app="$install_dir/app"                     # path to microblog.pub istself
microblogpub_venv="$install_dir/venv"                   # path to microblog.pubs venvsa
microblogpub_src_pyenv="$install_dir/pyenv.src"         # path to microblog.pubs pyenv sources
microblogpub_pyenv="$install_dir/pyenv"                 # path to microblog.pubs python version
microblogpub_bin_pyenv="${microblogpub_pyenv}/versions/${python_version}/bin" # pyenv exectutablesa
microblogpub_active_venv='not_found'                    # initialize path to active venv
#REMOVEME? Everything about fpm_usage is removed in helpers2.1... | fpm_usage=medium

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

microblogpub_set_filepermissions() {
    local dir
    chmod 750 "$install_dir" "$data_dir"
    chmod -R o-rwx "$install_dir" "$data_dir"
    chown -R $app:www-data "$install_dir" "$data_dir"
    chmod u+x $install_dir/inv.sh
    #REMOVEME? Assuming ynh_config_add_logrotate is called, the proper chmod/chowns are now already applied and it shouldn't be necessary to tweak perms | chown -R $app:www-data "/var/log/$app"
}

microblogpub_install_python() {
    # Install/update pyenv
    ynh_setup_source --dest_dir="${microblogpub_src_pyenv}" --source_id=pyenv
    export PYENV_ROOT=${microblogpub_pyenv}

    if [ -d "${microblogpub_pyenv}/versions" ]; then
        local old_python_version=`ls ${microblogpub_pyenv}/versions`
        if [ ! -z "${old_python_version}" ]; then
            if [ "${old_python_version}" != "${python_version}" ]; then
                local old_python_version_path="${microblogpub_pyenv}/versions/${old_python_version}"
                if [ -d "${old_python_version_path}" ]; then
                    ynh_print_info "Deleting Python ${old_python_version}"
                    ynh_safe_rm "${old_python_version_path}"
                fi
            fi
        fi
    fi

    if [ ! -d "${microblogpub_pyenv}/versions/${python_version}" ]; then
        ynh_print_info "Installing Python ${python_version}"
        ${microblogpub_src_pyenv}/bin/pyenv install $python_version 2>&1
        ynh_app_setting_set --app=$YNH_APP_INSTANCE_NAME --key=python_version --value=$python_version
    else
        ynh_print_info "Python ${python_version} is already installed"
    fi
}

microblogpub_install_deps () {
    ynh_print_info "Installing dependencies with poetry"
    (
        export PATH="${microblogpub_bin_pyenv}:$PATH"
		# pip and poetry run from the above set pyenv path and knows where to install packages
        pip --quiet install poetry 2>&1
        export POETRY_VIRTUALENVS_PATH=${microblogpub_venv}
        cd ${microblogpub_app}
        poetry install --no-root 2>&1
    )
}

microblogpub_initialize_db() {
    (
        export PATH="${microblogpub_bin_pyenv}:$PATH"
        cd ${microblogpub_app}
        export POETRY_VIRTUALENVS_PATH=${microblogpub_venv}
        poetry run inv migrate-db 2>&1
    )
}

# updates python environment and initializes/updates database
microblogpub_update () {
    ynh_print_info "Updating microblogpub"
    (
        export PATH="${microblogpub_bin_pyenv}:$PATH"
        cd ${microblogpub_app}
        export POETRY_VIRTUALENVS_PATH=${microblogpub_venv}
        poetry run inv update 2>&1
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

        # CI fails when key.pem or profile.toml exist already
        # TODO: https://git.sr.ht/~tsileo/microblog.pub/tree/v2/item/app/utils/yunohost.py#L25 ff.
        # there's no message for the case that key.pem already exists - open an issue/pr for that
        if [[ -s "${microblogpub_app}/data/key.pem" ]] && [[ -s "${microblogpub_app}/data/profile.toml" ]]
        then
            ynh_print_warn "key.pem and profile.toml exist. No new config generated"
        elif [[ -s "${microblogpub_app}/data/key.pem" ]] || [[ -s "${microblogpub_app}/data/profile.toml" ]]
        then
            ynh_die "key.pem OR profile.toml exist already, but the other one is missing."
        else
             poetry run inv yunohost-config --domain="${domain}" --username="${username}" \
                --name="${display_name}" --summary="${summary}" --password="${password}" 2>&1
        fi
        poetry run inv compile-scss 2>&1

        ## the following worked, but left the rest of the data in the app/data directory
        ## "data" as part of the path to microblog.pubs data directory seems hardcoded.
        ## symlinking to the the data directory seems to work, so I'll stop this as an
        ## attempt to move the database only
        ## it might come in handy later when trying to move the database to mariadb
        ##
        ## the yunohost app configuration wizard does not contain sqlalchemy_database (yet)
        # echo "sqlalchemy_database = \"$data_dir/microblogpub.db\"" >> ${microblogpub_app}/data/profile.toml
    )
}

# At the moment the data dir for microblog.pub cannot be configured and is hard coded into the
# scripts. So we'll move it and symlink it.
microblogpub_move_data() {
    # if $data_dir empty move data
    if [[ $(ls $data_dir | wc -l) -eq 0 ]]; then
        mv ${microblogpub_app}/data/* "${data_dir}"
        if [[ -e "${microblogpub_app}/data/.gitignore" ]]; then
            rm "${microblogpub_app}/data/.gitignore"
        fi
        rmdir "${microblogpub_app}/data"
    else
        ynh_print_info "Directory $data_dir not empty - re-using old data"
        # TODO this will eventually leave some data-<date> directories that need to
        # be cleaned up → https://todo.sr.ht/~chrichri/microblog.pub_ynh_v2/6
        mv "${microblogpub_app}/data" "${microblogpub_app}/data-$(date '+%Y-%m-%d_%H-%M-%S_%N')"
    fi
    # after moving or deleting symlink
    ln -s "${data_dir}" "${microblogpub_app}/data"
}
