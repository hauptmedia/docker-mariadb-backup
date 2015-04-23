#!/bin/bash

PID=$$
XTRABACKUP_LOG=/tmp/$$-xtrabackup
DATADIR=/var/lib/mysql
CLUSTER_ADDRESS=

while getopts ":a:" opt; do
  case $opt in
    a)
      CLUSTER_ADDRESS=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ -z "$CLUSTER_ADDRESS" ]; then
	echo
	echo Usage: $0 -a gcomm://ip:4567,ip:4567
	echo
	echo "  -a  Specifies the galera cluster address"
	echo
	exit 1
fi


wsrep_sst_xtrabackup-v2 \
--role joiner \
--auth replication:test \
--datadir ${DATADIR} \
--address 172.17.0.11 \
--defaults-file /etc/mysql/my.cnf \
--parent $PID >${XTRABACKUP_LOG} 2>&1 &

COUNTER=0

echo -n Waiting xtrabackup to become ready

while [ -z "$XTRABACKUP_ADDRESS" ] && [  $COUNTER -lt 30 ]; do
	let COUNTER=COUNTER+1
	echo -n "."
	sleep 1
	XTRABACKUP_ADDRESS=$(cat $XTRABACKUP_LOG | egrep "^ready " | awk '{ print $2; }')
done

echo
 
if [ -z "$XTRABACKUP_ADDRESS" ]; then
	echo Could not determine xtrabackup address, aborting!
	exit 1
fi

echo xtrabackup_address = ${XTRABACKUP_ADDRESS}

garbd -a ${CLUSTER_ADDRESS} -g test --sst xtrabackup-v2:${XTRABACKUP_ADDRESS}

echo -n Waiting SST to finish

while [ -f ${DATADIR}/sst_in_progress ]; do 
        echo -n "."
	sleep 1
done

echo

cat ${XTRABACKUP_LOG}
