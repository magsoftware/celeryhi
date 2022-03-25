#!/bin/bash

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR=${SCRIPTDIR}/..

VENVDIR=$(pipenv --venv)
APPNAME="tasks:app"

rm -fr ${BASEDIR}/{log,run,etc}
