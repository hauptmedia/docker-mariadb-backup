# docker-mariadb-backup

This image can be used to backup mariadb galera clusters.

## remote-galera-xtrabackup-v2

Backups a galera cluster via a remote connection using xtrabackup-v2 sst method.

It creates a listening socket for receiving the state snapshot transfer
and launches a galera arbitrator which connects to the cluster, triggers
a state snapshot transfer and disconnects from the cluster.

*Please note: The donor cluster node must be able to connect to connect to
the listen address (which may be specified using the -l option)*

Example usage:

```bash
docker run -i -t --rm \
-v /tmp/mysqlbackup:/var/lib/mysql \
hauptmedia/mariadb-backup \
backup-galera-xtrabackup-v2 \
-a gcomm://172.17.0.19:4567 \
-g MyClusterName 
```
