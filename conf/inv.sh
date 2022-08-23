cmd=$1
(
    export PATH="__FINALPATH__/pyenv/versions/__PYTHON_VERSION__/bin:$PATH"
    cd __FINALPATH__/microblogpub
    export POETRY_VIRTUALENVS_PATH=__FINALPATH__/venv
    poetry run inv $cmd
)
