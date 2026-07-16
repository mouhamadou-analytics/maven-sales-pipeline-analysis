/*
===============================================================================
Project: Maven Sales Pipeline Analysis
Script:  03_data_cleaning.sql
Purpose: Correct confirmed data-quality issues and validate each change.
===============================================================================
*/

/*
 Data Cleaning Rule #1
Issue:
GTXPro in sales_pipeline does not match GTX Pro in products.
Impact:
1,480 opportunities affected.
Action:
Standardize GTXPro → GTX Pro
 */
select 
	product,
	count(*) as rows_affected
from maven_sales_pipeline.sales_pipeline
	where product = 'GTXPro'
group by product ;

-- Standardize the product name in the opportunity table.
update maven_sales_pipeline.sales_pipeline
set product = 'GTX Pro'
	where product = 'GTXPro'; 

-- Post-update validation: confirm removal of the old value and presence of
-- the standardized value.
select 
	'old_value_remaining' as check_type,
	product,
	count(*) as rows_count
from maven_sales_pipeline.sales_pipeline
where product = 'GTXPro'
group by product 

union all 

select 
	'new_value_count' as check_type,
	product,
	count(*) as rows_count 
from maven_sales_pipeline.sales_pipeline
	where product = 'GTX Pro'
group by product ;
