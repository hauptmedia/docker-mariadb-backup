# docker-mariadb-backup

This container can be used to periodically backup MySQL, MariaDB, and MariaDB Galera cluster instances.

Example usage which will backup the database every day at 03:00. You can check the last run with the integrated HTTP server on port 18080:

```bash
docker run -d \
-v /var/backups:/var/backups \
-p 18080:18080 \
-e TIMEZONE="Europe/Berlin" \
-e SCHEDULE="0 0 3 * *" \
-e BACKUP_METHOD="mysqldump" \
-e BACKUP_OPTS="-u root -p test -h 172.17.0.68" \
hauptmedia/mariadb-backup
```

# Available backup methods

## mysqldump

Backups a MySQL/MariaDB database via mysqldump.

Example standalone run:

```bash
docker run -i -t --rm \
-v /var/backups:/var/backups \
hauptmedia/mariadb-backup \
backup-mysqldump \
-u root -p test -h 172.17.0.19
```

```
Usage: /usr/local/bin/backup-mysqldump -u mysqluser -p mysqlpassword -h mysqlhost

  -u  Specifies the MySQL user (required)
  -p  Specifies the MySQL password (required)
  -h  Specifies the MySQL host (required)
  -P  Specifies the MySQL port (optional)
  -d  Specifies the backup file where to put the backup (default: /var/backups/CURRENT_DATETIME_MYSQLHOST_mysqldump)
```

## galera-xtrabackup-v2

Backups a galera cluster via a remote connection using xtrabackup-v2 sst method.

It creates a listening socket for receiving the state snapshot transfer
and launches a galera arbitrator which connects to the cluster, triggers
a state snapshot transfer and disconnects from the cluster.

*Please note: The donor cluster node must be able to connect to
the listen address (which may be specified using the -l option)*

Example standalone run:

```bash
docker run -i -t --rm \
-v /tmp/mysqlbackup:/var/lib/mysql \
hauptmedia/mariadb-backup \
backup-galera-xtrabackup-v2 \
-a gcomm://172.17.0.19:4567 \
-g MyClusterName 
```

```
Usage: /usr/local/bin/backup-galera-xtrabackup-v2 -a gcomm://ip:4567,ip:4567 -g MyClusterName

  -a  Specifies the galera cluster address (required)
  -g  Specifies the galera cluster name (required)
  -l  Specifies the ip and port where to listen for the state snapshot transfer (default: public-ip:4444)
  -d  Specifies the data directory where to put the backup (default: /var/lib/mysql)
  -n  Specifies the donor node which should be use (optional)
```
