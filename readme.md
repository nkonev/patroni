# Reproduction
```bash
docker build --no-cache -t patroni.original .
docker build --no-cache -f Dockerfile.patched -t patroni .

docker-compose up -d

# wait 1-2 minutes
# see in Clickhouse - table is replicated - it has 4 rows
docker exec -it clickhouse clickhouse client
select * from database1.customers;

# Modify records in the database via Postgres client
docker exec -it -e PGOPTIONS="--search_path=inventory" demo-haproxy psql -U postgres -h haproxy -p 5000 -d postgres
Enter password:
postgres

insert into customers (first_name, last_name, email) values ('Nikita', 'Konev', 'nkonev@example.com');

# see again in Clickhouse - the new row isn't appear

# see Clickhouse's logs
docker-compose exec clickhouse bash
tail -f -n 1000 /var/log/clickhouse-server/clickhouse-server.err.log

```