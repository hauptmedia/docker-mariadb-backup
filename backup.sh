#!/bin/sh

wsrep_sst_xtrabackup-v2 --role joiner --auth test:test --datadir /var/lib/mysql --address 127.0.0.1:4444 --defaults-file /etc/mysql/my.cnf --parent '2391'

