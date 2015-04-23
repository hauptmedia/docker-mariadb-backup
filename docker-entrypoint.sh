#!/bin/sh
set -e 

if [ $1 = "go-cron" ]; then

	if [ -z "$SCHEDULE" ]; then
		echo Missing SCHEDULE environment variable 2>&1
		echo Example -e SCHEDULE=\"\*/10 \* \* \* \* \*\" 2>&1
		exit 1
	fi

	exec go-cron -s "${SCHEDULE}" -- /usr/local/bin/backup-run
fi

exec "$@"
