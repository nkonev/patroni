#!/bin/bash

if [ -z "$(ls -A $PGDATA)" ]; then
   echo "PGDATA is empty, going to fix permissions"
   chown -R postgres:postgres $PGDATA
   chmod -R 0750 $PGDATA
else
   echo "PGDATA is not empty"
fi

exec gosu postgres /bin/bash /entrypoint.sh
