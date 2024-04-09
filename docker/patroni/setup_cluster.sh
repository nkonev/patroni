#!/bin/bash
# According to https://patroni.readthedocs.io/en/latest/yaml_configuration.html#bootstrap-configuration this script receives into $1
# 'dbname=postgres user=postgres host=localhost port=5432'

# Using bash's set command, we can split the line into positional parameters like awk
set $1
for word in "$@"; do
    IFS='=' read -r key val <<< "$word"
    test -n "$val" && printf -v "$key" "$val"
done

cat /home/postgres/init.sql | psql -U ${user} -h ${host} -p ${port} -d ${dbname}
