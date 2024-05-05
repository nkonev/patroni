CREATE SCHEMA inventory;

CREATE TABLE inventory.customers (
    id serial,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    country     varchar(20) NOT NULL,
    primary key (id, country)
)
PARTITION BY LIST(country);

CREATE TABLE inventory.customers_europe
    PARTITION OF inventory.customers
    FOR VALUES IN ('France', 'Italy', 'Russia');

CREATE TABLE inventory.customers_asia
    PARTITION OF inventory.customers
    FOR VALUES IN ('India', 'Pakistan');

CREATE TABLE inventory.customers_americas
    PARTITION OF inventory.customers
    FOR VALUES IN ('US', 'Canada');

ALTER TABLE ONLY inventory.customers_europe REPLICA IDENTITY FULL;
ALTER TABLE ONLY inventory.customers_asia REPLICA IDENTITY FULL;
ALTER TABLE ONLY inventory.customers_americas REPLICA IDENTITY FULL;

CREATE PUBLICATION my_dbz_publication FOR TABLE inventory.customers_europe, inventory.customers_asia, inventory.customers_americas;

INSERT INTO inventory.customers VALUES (1001, 'Sally', 'Thomas', 'sally.thomas@acme.com', 'France');
INSERT INTO inventory.customers VALUES (1002, 'George', 'Bailey', 'gbailey@foobar.com', 'India');
INSERT INTO inventory.customers VALUES (1003, 'Edward', 'Walker', 'ed@walker.com', 'US');
INSERT INTO inventory.customers VALUES (1004, 'Anne', 'Kretchmar', 'annek@noanswer.org', 'Canada');

SELECT pg_catalog.setval('inventory.customers_id_seq', 1004, true);
