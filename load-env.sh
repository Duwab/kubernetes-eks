#!/bin/bash

set -e

INITIAL_DIR=$(pwd)

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ ! -f .env ]; then
    cp .env.example .env
    vi .env
    echo -e "\nℹ️  File created: $(pwd)/.env \n"
fi

set -a
. .env
set +a
printenv | grep AWS

cd $INITIAL_DIR
