-- https://clickhouse.com/blog/clickhouse-postgresql-change-data-capture-cdc-part-2#configuring-debezium
-- https://clickhouse.com/docs/en/engines/table-engines/mergetree-family/replacingmergetree

SET allow_experimental_database_materialized_postgresql=1;

CREATE DATABASE database1
ENGINE = MaterializedPostgreSQL('postgres:5432', 'postgres', 'postgres', 'postgres')
SETTINGS materialized_postgresql_max_block_size = 65536,
        materialized_postgresql_schema = 'inventory',
        materialized_postgresql_tables_list = 'customers';
