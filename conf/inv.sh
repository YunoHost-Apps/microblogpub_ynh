cmd=$1
(
    export PATH="__MICROBLOGPUB_BIN_PYENV__:$PATH"
    cd "__MICROBLOGPUB_APP__"
    export POETRY_VIRTUALENVS_PATH="__MICROBLOGPUB_VENV__"
    poetry run inv $cmd
)
