#!/bin/bash

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR=$(dirname ${SCRIPTDIR})

rm -fr ${BASEDIR}/{log,run,etc}
