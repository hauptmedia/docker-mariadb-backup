#!/bin/sh
set -e 

if [ -z "$SCHEDULE" ]; then
	echo Missing SCHEDULE environment variable 2>&1
	echo Example -e SCHEDULE="*/10 * * * * *" 2>&1
	exit 1
fi

exec go-cron -s "${SCHEDULE}" -- /bin/bash -c "echo hello"
