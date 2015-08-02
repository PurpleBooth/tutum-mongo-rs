#!/bin/bash
set -m

mongodb_cmd="mongod --storageEngine $STORAGE_ENGINE --replSet $REPLICA_SET_NAME"
cmd="$mongodb_cmd --httpinterface --rest "
if [ "$AUTH" == "yes" ]; then
    cmd="$cmd --auth"
fi

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

$cmd &

if [ ! -f /data/db/.mongodb_password_set ]; then
    /set_mongodb_password.sh
fi

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MongoDB service startup"
    sleep 5
    mongo admin --eval "help" >/dev/null 2>&1
    RET=$?
done

mongo --eval "rs.initiate()"

for REPLICA_SET_HOST in $REPLICA_SET_HOSTS; do
    mongo admin --eval "rs.add("$REPLICA_SET_HOST")"
done

fg