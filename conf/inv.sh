cmd=$1
(
    export PATH="__INSTALL_DIR__/pyenv/versions/__PYTHON_VERSION__/bin:$PATH"
    cd __INSTALL_DIR__/microblogpub
    export POETRY_VIRTUALENVS_PATH=__INSTALL_DIR__/venv
    poetry run inv $cmd
)
