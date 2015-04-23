#!/bin/bash

PID=$$
XTRABACKUP_LOG=/tmp/$$-xtrabackup
DATA_DIR=/var/lib/mysql
CLUSTER_ADDRESS=
LISTEN_ADDRESS=$(hostname --ip-addr):4444

while getopts ":a:" opt; do
  case $opt in
    l)
      LISTEN_ADDRESS=$OPTARG
      ;;
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
	echo "  -l  Specifies the ip and port where to listen for the sst (default: public-ip:4444)"
	echo
	exit 1
fi

echo Using the following configuration:
echo
echo "data_dir:		${DATA_DIR}"
echo "cluster_address:	${CLUSTER_ADDRESS}"
echo "listen_address:	${LISTEN_ADDRESS}"
echo

wsrep_sst_xtrabackup-v2 \
--role joiner \
--auth replication:test \
--datadir ${DATA_DIR} \
--address ${LISTEN_ADDRESS} \
--defaults-file /etc/mysql/my.cnf \
--parent $PID >${XTRABACKUP_LOG} 2>&1 &

COUNTER=0

echo
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

echo
echo xtrabackup_address = ${XTRABACKUP_ADDRESS}

garbd -a ${CLUSTER_ADDRESS} -g test --sst xtrabackup-v2:${XTRABACKUP_ADDRESS}

echo
echo -n State Snapshot Transfer in progress 

while [ -f ${DATA_DIR}/sst_in_progress ]; do 
        echo -n "."
	sleep 1
done

echo

cat ${XTRABACKUP_LOG}

echo

if grep -q "\[ERROR\]" ${XTRABACKUP_LOG}; then
	echo Backup failed with errors!
	exit 1
else
	echo Backup finished successfully.
	exit 0 
fi


