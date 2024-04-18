# Reproduction
```bash
docker build -t patroni.original .
docker build -f Dockerfile.patched -t patroni .

docker-compose up -d

# see in Clickhouse - table isn't replicated
docker exec -it clickhouse clickhouse client
select * from database1.customers;

# see Clickhouse's logs
docker-compose exec clickhouse bash
tail -f -n 1000 /var/log/clickhouse-server/clickhouse-server.err.log

```