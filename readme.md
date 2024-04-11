# Patroni
```bash
docker build -t patroni.original .
docker build -f Dockerfile.patched -t patroni .

docker exec -ti demo-patroni1 bash
etcdctl get --keys-only --prefix /service/demo
etcdctl member list


docker exec -ti demo-haproxy bash
psql -h localhost -p 5000 -U postgres -W
```

# Replication via Kafka Connect
```bash
# Start the topology as defined in https://debezium.io/documentation/reference/stable/tutorial.html
docker-compose up -d --build

# Consume messages from a Debezium topic
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh \
    --bootstrap-server kafka:9092 \
    --from-beginning \
    --property print.key=true \
    --topic dbserver1.inventory.customers

# Modify records in the database via Postgres client
docker exec -it -e PGOPTIONS="--search_path=inventory" demo-haproxy psql -U postgres -h haproxy -p 5000 -d postgres
insert into customers (first_name, last_name, email) values ('Nikita', 'Konev', 'nkonev@example.com');
update customers set first_name = 'Nikita 2' where id = 1005;
delete from customers where id = 1005;

# see in Clickhouse
docker exec -it clickhouse clickhouse client
select * from customers;

optimize table customers final cleanup;
# or
select * from customers final;
# or
select * from customers limit 1 by id;
# or - remove duplicates and hide deleted wiv limit by
select * from customers prewhere deleted = 0 order by version desc limit 1 by id;
# show updated - filter out old versions
# https://clickhouse.com/docs/en/sql-reference/statements/select/limit-by
select * from customers prewhere deleted = 0 order by version desc limit 1 by id limit 2;

# Load test
open `docker stats`

# then in haproxy
INSERT INTO customers (first_name, last_name, email)
SELECT
'generated_first_name_' || i,
'generated_last_name_' || i,
'generated_user_' || i || '@example.com'
FROM generate_series(1, 10000000) AS i;

# then in Clickhouse
select count(*) from customers;
-- the answer should be 10000000 + 4

-- results
1:32:04 - issue insert gen in PG
1:32:48 - finished insert in PG
1:41:19 - finished inserting to CH
```

-- for tests
insert into customers_mv(id, first_name, last_name, email) values (1, 'Nikita', 'Konev', 'nkonev@example.com');
insert into customers_changes(`after.id`, `after.first_name`, `after.last_name`, `after.email`) values (1, 'Nikita', 'Konev', 'nkonev@example.com');

# Shut down the cluster
docker-compose down
```


# Links
* https://github.com/zalando/patroni/tree/master/docker
* https://github.com/zalando/patroni/blob/master/Dockerfile
* https://patroni.readthedocs.io/en/latest/patroni_configuration.html
* https://patroni.readthedocs.io/en/latest/yaml_configuration.html#bootstrap-configuration
* https://github.com/debezium/debezium-examples/tree/main/tutorial#using-postgres
* https://clickhouse.com/blog/clickhouse-postgresql-change-data-capture-cdc-part-1
* https://clickhouse.com/blog/clickhouse-postgresql-change-data-capture-cdc-part-2
* https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/replacingmergetree
* https://clickhouse.com/blog/handling-updates-and-deletes-in-clickhouse
* https://itnext.io/using-postgresql-pgoutput-plugin-for-change-data-capture-with-debezium-on-azure-845d3bb2787a
* https://github.com/abhirockzz/debezium-postgres-pgoutput
