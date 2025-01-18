#!/usr/bin/env bash

cmd=$1
(
    export PATH=__PATH_WITH_PYTHON__
    cd "__INSTALL_DIR__/app"
    export POETRY_VIRTUALENVS_PATH="__INSTALL_DIR__/venv"
    poetry run inv $cmd
)
