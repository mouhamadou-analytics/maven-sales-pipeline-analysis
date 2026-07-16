-- Data Cleaning of Sales Pipeline

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

-- Update of the product name 
update maven_sales_pipeline.sales_pipeline
set product = 'GTX Pro'
	where product = 'GTXPro'; 

-- Post Update Validation
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
