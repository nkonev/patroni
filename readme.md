# Reproduction
```bash
docker-compose up -d
docker-compose exec clickhouse bash
tail -f -n 1000 /var/log/clickhouse-server/clickhouse-server.err.log

docker-compose exec clickhouse clickhouse client
# there are initial load - 4 rows
select * from database1.customers;

docker-compose exec postgres psql -U postgres
insert into inventory.customers (first_name, last_name, email) values ('Nikita', 'Konev', 'nkonev@example.com');
```

