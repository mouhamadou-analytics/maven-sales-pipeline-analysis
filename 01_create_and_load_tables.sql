--Tables Creation
create table maven_sales_pipeline.accounts(
	account TEXT, 
	sector TEXT,
	year_established INTEGER, 
	revenue NUMERIC(10,2),
	employees INTEGER,
	office_location TEXT, 
	subsidary_of TEXT);

select count(*)
from maven_sales_pipeline.accounts;

select *
from maven_sales_pipeline.accounts
limit 10;

SELECT column_name
FROM information_schema.columns
WHERE table_schema = 'maven_sales_pipeline'
  AND table_name = 'accounts';

drop table maven_sales_pipeline.accounts;

select table_name
from information_schema.tables
where table_schema ='maven_sales_pipeline';

CREATE TABLE maven_sales_pipeline.accounts (
    account TEXT,
    sector TEXT,
    year_established INTEGER,
    revenue NUMERIC(10,2),
    employees INTEGER,
    office_location TEXT,
    subsidiary_of TEXT
);

select *
from maven_sales_pipeline.accounts
limit 10;

-- Create the table products
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'maven_sales_pipeline';



select *
from maven_sales_pipeline.accounts limit 5;

drop table if exists maven_sales_pipeline.accounts;
drop table if exists maven_sales_pipeline.products;


CREATE TABLE maven_sales_pipeline.accounts (
    account TEXT,
    sector TEXT,
    year_established INTEGER,
    revenue NUMERIC(10,2),
    employees INTEGER,
    office_location TEXT,
    subsidiary_of TEXT
);

select count(*)
from maven_sales_pipeline.accounts;

select *
from maven_sales_pipeline.accounts
limit 10;

CREATE TABLE maven_sales_pipeline.products (
    product TEXT,
    series TEXT,
    sales_price NUMERIC(10,2)
);

select *
from maven_sales_pipeline.products; 

drop table if exists maven_sales_pipeline.sales_teams;

create table maven_sales_pipeline.sales_teams(
	sales_agent TEXT,
	manager TEXT,
	regional_office TEXT
);

select *
from maven_sales_pipeline.sales_teams limit 5;

create table maven_sales_pipeline.sales_pipeline(
	opportunity_id TEXT,
	sales_agent TEXT,
	product TEXT,
	account TEXT,
	deal_stage TEXT,
	engage_date DATE,
	close_date DATE,
	close_value NUMERIC(10,2)

);

select *
from maven_sales_pipeline.sales_pipeline limit 5;

SELECT 'accounts' AS table_name, COUNT(*) FROM maven_sales_pipeline.accounts
UNION ALL
SELECT 'products', COUNT(*) FROM maven_sales_pipeline.products
UNION ALL
SELECT 'sales_teams', COUNT(*) FROM maven_sales_pipeline.sales_teams
UNION ALL
SELECT 'sales_pipeline', COUNT(*) FROM maven_sales_pipeline.sales_pipeline;




