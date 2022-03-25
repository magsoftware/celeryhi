#!/bin/bash

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR=${SCRIPTDIR}/..

VENVDIR=$(pipenv --venv)
APPNAME="tasks:app"

mkdir -p ${BASEDIR}/{log,run,etc}

# Config file for Celery
cat > ${BASEDIR}/etc/celery.conf << EOF
# # Name of nodes to start
# here we have a single node
CELERYD_NODES="w1"

# or we could have three nodes:
# CELERYD_NODES="w1 w2 w3"

# Absolute or relative path to the 'celery' command:
CELERY_BIN="${VENVDIR}/bin/celery"

# App instance to use
# comment out this line if you don't use an app
CELERY_APP=${APPNAME}

# Extra command-line arguments to the worker
CELERYD_OPTS="--time-limit=300 --pool=threads --concurrency=4"

# - %n will be replaced with the first part of the nodename.
# - %I will be replaced with the current child process index
#   and is important when using the prefork pool to avoid race conditions.
CELERYD_PID_FILE="${BASEDIR}/run/%n.pid"
CELERYD_LOG_FILE="${BASEDIR}/log/%n%I.log"

CELERYD_LOG_LEVEL="INFO"

# you may wish to add these options for Celery Beat
CELERYBEAT_PID_FILE="${BASEDIR}/run/beat.pid"
CELERYBEAT_LOG_FILE="${BASEDIR}/log/beat.log"
EOF

# Celery service file
cat > ${BASEDIR}/etc/celery.service << EOF
[Unit]
Description=Celery Service
After=network.target

[Service]
Type=forking
User=firmware
Group=firmware
EnvironmentFile=${BASEDIR}/etc/celery.conf
WorkingDirectory=${BASEDIR}
ExecStart=/bin/sh -c '\${CELERY_BIN} -A \${CELERY_APP} multi start \${CELERYD_NODES} --pidfile=\${CELERYD_PID_FILE} --logfile=\${CELERYD_LOG_FILE} --loglevel=\${CELERYD_LOG_LEVEL} \${CELERYD_OPTS}'
ExecStop=/bin/sh -c '\${CELERY_BIN} multi stopwait \${CELERYD_NODES} --pidfile=\${CELERYD_PID_FILE} --logfile=\${CELERYD_LOG_FILE} --loglevel=\${CELERYD_LOG_LEVEL}'
ExecReload=/bin/sh -c '\${CELERY_BIN} -A \${CELERY_APP} multi restart \${CELERYD_NODES} --pidfile=\${CELERYD_PID_FILE} --logfile=\${CELERYD_LOG_FILE} --loglevel=\${CELERYD_LOG_LEVEL} \${CELERYD_OPTS}'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Celery Beat service file
cat > ${BASEDIR}/etc/celerybeat.service << EOF
[Unit]
Description=Celery Beat Service
After=network.target

[Service]
Type=simple
User=firmware
Group=firmware
EnvironmentFile=${BASEDIR}/etc/celery.conf
WorkingDirectory=${BASEDIR}
ExecStart=/bin/sh -c '\${CELERY_BIN} -A \${CELERY_APP} beat --pidfile=\${CELERYBEAT_PID_FILE} --logfile=\${CELERYBEAT_LOG_FILE} --loglevel=\${CELERYD_LOG_LEVEL}'
Restart=always

[Install]
WantedBy=multi-user.target
EOF
