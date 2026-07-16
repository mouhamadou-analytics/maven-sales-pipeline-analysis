--Data Profiling
--Project: Sales Pipeline Analysis
--Purpose: Assess Data structure, copmpletness, uniqueness, validity, and consistency

--1. Verification of the row count table
-- 1. Row counts by table
SELECT 'accounts' AS table_name, COUNT(*) AS row_count
FROM maven_sales_pipeline.accounts
UNION ALL
SELECT 'products', COUNT(*)
FROM maven_sales_pipeline.products
UNION ALL
SELECT 'sales_teams', COUNT(*)
FROM maven_sales_pipeline.sales_teams
UNION ALL
SELECT 'sales_pipeline', COUNT(*)
FROM maven_sales_pipeline.sales_pipeline;

--2 Table structure
select 
	table_name,
	column_name,
	data_type
from information_schema.columns
where table_schema = 'maven_sales_pipeline'
order by table_name, ordinal_position;

-- Missing values detection for account table
-- Finding:
-- subsidiary_of contains 70 blank values and 15 populated values.
-- This appears to be expected business behavior rather than a data quality issue.
select 
	count(*) as total_rows, 
	count(account) as account_populated,
	count(sector)  as sector_populated,
	count(year_established ) as year_establish_populated,
	count(revenue) as revenue_populated,
	count(employees) as employees_populated,
	count(office_location ) as office_loca_pop,
	count(subsidiary_of ) as subsidary_off_pop,
	COUNT(NULLIF(subsidiary_of, '')) AS non_blank_count
from maven_sales_pipeline.accounts;

-- Missing values detection for product table

SELECT
    COUNT(*) AS total_rows,
    COUNT(product) AS product_populated,
    COUNT(series) AS series_populated,
    COUNT(sales_price) AS sales_price_populated
FROM maven_sales_pipeline.products;

-- Missing values detection for sales table
SELECT
    COUNT(*) AS total_rows,
    COUNT(sales_agent) AS sales_agent_populated,
    COUNT(manager) AS manager_populated,
    COUNT(regional_office) AS regional_office_populated
FROM maven_sales_pipeline.sales_teams;

-- Missing values detection for sales_pipeline table
/* 16.2 % missing values in the account field were 
  concentraded in early_stage opportunities (prospecting and engaging)
  this an expected business behavior rather than a data quality issue */
select 
	count(*) as total_rows,
	count(sales_agent) as sales_agent_populated,
	count(product) as product_populated,
	count(account) as account_populated,
	COUNT(NULLIF(account, '')) AS non_blank_count,
	count(deal_stage) as deal_stage_populated,
	count(engage_date) as engage_date_populated,
	count(close_date) as close_date_populated,
	count(close_value) as close_value_popuated
from maven_sales_pipeline.sales_pipeline;  

-- This extra-verification help us confirm that the missing values are concentraded
-- in the early stage prospection and won + lost are correctly populated
SELECT
    deal_stage,
    COUNT(*) AS opportunities,
    COUNT(NULLIF(account,'')) AS account_populated
FROM maven_sales_pipeline.sales_pipeline
GROUP BY deal_stage
ORDER BY opportunities DESC;

-- Check Dupilcate records
SELECT
    account,
    COUNT(*) AS occurrences
FROM maven_sales_pipeline.accounts
GROUP BY account
HAVING COUNT(*) > 1;

SELECT
    sales_agent,
    COUNT(*) AS occurrences
FROM maven_sales_pipeline.sales_teams
GROUP BY sales_agent
HAVING COUNT(*) > 1;

select 
	opportunity_id,
	COUNT(*) as occurences
from maven_sales_pipeline.sales_pipeline
group by opportunity_id
having COUNT(*) > 1 ;
-- Duplicate Checks

-- accounts
-- Result: No duplicate accounts found

-- products
-- Result: No duplicate products found

-- sales_teams
-- Result: No duplicate sales agents found

-- sales_pipeline
-- Result: No duplicate opportunities found


-- #1 Validity check: Checking if there is no non-sense values
-- eg: close_value<0 

select 
	MIN(close_value ) as min_close_value,
	MAX(close_value) as max_close_value
from maven_sales_pipeline.sales_pipeline; 

-- Let's double_check the concentration of zero per deal_stage
-- make sense lost opportunities means close_value = 0

select
	deal_stage, 
	count(*) as opportunities,
	count(case when close_value=0 then 1 end ) as zero_value_opportunities
from maven_sales_pipeline.sales_pipeline 
group by deal_stage;

-- #2 Validity check: Find the rows where engage_date>close_date
-- Finding:
-- No opportunities found where engage_date > close_date.
-- Timeline validation passed.
select 
 count(*) as invalid_timeline_count
from maven_sales_pipeline.sales_pipeline
	where engage_date > close_date ; 

-- #3 Validity check: Find deal_stage not in the accepted set
-- Domain discovery first
select
	deal_stage, 
 	count(*) as opportunities
from maven_sales_pipeline.sales_pipeline
group by deal_stage 
order by opportunities desc;
	
-- business validity all the stage are correct. 

-- Relationship integrity 
/*Relationship Integrity Check – Products

Finding:
One product value is inconsistently named.

sales_pipeline : GTXPro
products       : GTX Pro

Impact:
Product-level reporting could be inaccurate because opportunities
for GTXPro would not join to the product master table.

Recommendation:
Standardize product naming before reporting*/

-- Finding here there is on product in the sales_pipeline table that is not 
-- present in the list of product

select 
s.product as sales_pipeline_product, 
p.product as list_product
from maven_sales_pipeline.sales_pipeline as s
left join maven_sales_pipeline.products as p
	on s.product   = p.product
    where p.product is null;
-- we investigate more by comparing each product name
select distinct
 	'sales_pipeline' as source_table,
	product   
from maven_sales_pipeline.sales_pipeline 

union all

select DISTINCT
	'products' as source_table,
	product 
from maven_sales_pipeline.products  
order by product, source_table; 


-- Relationship Integrity = accounts

select distinct
 	'sales_pipeline' as source_table,
	account   
from maven_sales_pipeline.sales_pipeline 

union all

select DISTINCT
	'accounts' as source_table,
	account 
from maven_sales_pipeline.accounts  
order by account, source_table; 
-- blank account name in the sales_pipeline table
/*There are NO non-blank accounts in sales_pipeline
that are missing from accounts*/
select 
s.account as sales_pipeline_account, 
a.account as list_account
from maven_sales_pipeline.sales_pipeline as s
left join maven_sales_pipeline.accounts as a
	on s.account = a.account
    where a.account is null and s.account <> '';

-- Relationship Integrity = sales_agent 
select distinct
 	'sales_pipeline' as source_table,
	 sales_agent   
from maven_sales_pipeline.sales_pipeline 

union all

select DISTINCT
	'sales_teams' as source_table,
	 sales_agent 
from maven_sales_pipeline.sales_teams	  
order by sales_agent, source_table; 


