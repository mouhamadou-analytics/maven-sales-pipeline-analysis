/*
===============================================================================
Project: Maven Sales Pipeline Analysis
Script:  04_exploratory_analysis.sql
Purpose: Explore deal stages, sales cycles, products, agents, regions,
         and account characteristics before building reporting views.
===============================================================================
*/

-- Distribution of opportunities by deal stage.
with total_opportunities as(
select
		count(*) as total_opport
from maven_sales_pipeline.sales_pipeline) 


select 
	deal_stage, 
	count(opportunity_id ) as number_opport_deal_stage,
	
	ROUND(100.0*count(opportunity_id )/total_opportunities.total_opport,2) as percentage_of_opport
	
from maven_sales_pipeline.sales_pipeline
cross join total_opportunities 
group by deal_stage,total_opportunities.total_opport ;



with monthly_opportunity_cte as(
SELECT 
	opportunity_id,
	engage_date, 
	EXTRACT(YEAR FROM engage_date) as Year,
	EXTRACT(MONTH FROM engage_date) as Month 	
FROM maven_sales_pipeline.sales_pipeline
	where engage_date is not null 
group by  opportunity_id, engage_date)  

select
	year,
	month,
	count(opportunity_id) as monthly_opportunity 	
from monthly_opportunity_cte 
group by year, month
order by monthly_opportunity  desc 
limit 1 ;   


--Average time deals stay open and comparison between Won and Lost
-- Business Question:
-- How long does it take to close a sales opportunity?
-- Compare Won vs Lost deals.

-- Why it matters:
-- Measures sales cycle efficiency and highlights differences
-- between successful and unsuccessful opportunities.

select
	deal_stage, 
	round(avg(close_date-engage_date),1) as days_to_close
from maven_sales_pipeline.sales_pipeline
where deal_stage in ('Won', 'Lost')
group by deal_stage;  

--percentage of deals in each stage
with total_deal as (
select 
	count(*) as total_deal
from maven_sales_pipeline.sales_pipeline)   

select 
	deal_stage,
	count(deal_stage) as deal_count,
	round(100.0*count(deal_stage)/total_deal,2) as perc_deal_stage 
from maven_sales_pipeline.sales_pipeline
cross join total_deal
group by deal_stage, total_deal.total_deal; 


-- Win rate per product 

select 
	product,
	count( case when deal_stage = 'Won' then 1 end) as Won_deals,
	count( case when deal_stage = 'Lost' then 1 end) as Lost_deals, 
	round(
		100.0*count( case when deal_stage = 'Won' then 1 end)/(count( case when deal_stage = 'Won' then 1 end) + count( case when deal_stage = 'Lost' then 1 end) ),2) as win_perc
from maven_sales_pipeline.sales_pipeline
group by product
order by win_perc desc;


--- Win rate per agent and find the top performer
-- Validation:
-- Verified that Win Rate = Won / (Won + Lost)
-- Spot-checked top performer manually.
-- Percentages are consistent with business definition

select 
	sales_agent, 
		round(
		100.0*count( case when deal_stage = 'Won' then 1 end)/(count( case when deal_stage = 'Won' then 1 end) + count( case when deal_stage = 'Lost' then 1 end) ),2) as win_rate_per_agent
from maven_sales_pipeline.sales_pipeline
group by sales_agent 
order by win_rate_per_agent desc
limit 1; 


-- Calculate the total revenue per agent and see who generated the most. 

select 
	sales_agent, 
		SUM( case when deal_stage = 'Won' then close_value  end ) as revenue_agent
from maven_sales_pipeline.sales_pipeline
group by sales_agent 
order by revenue_agent desc
limit 1;

-- Verification = Does every agent has a sales_team record: Positive
select 
	s.sales_agent,
	t.sales_agent,
	t.manager
from maven_sales_pipeline.sales_pipeline as s 
left join maven_sales_pipeline.sales_teams as t
	on s.sales_agent = t.sales_agent
	where s.sales_agent is null 
group by s.sales_agent,t.sales_agent ,t.manager  ;


-- Win rates per Manager
select 
	t.manager,
	count( case when deal_stage = 'Won' then 1 end) as Won_deals,
	count( case when deal_stage = 'Lost' then 1 end) as Lost_deals,
	count( case when deal_stage = 'Won' then 1 end) + count( case when deal_stage = 'Lost' then 1 end) as closed_deals,
	round(
		100.0*count( case when deal_stage = 'Won' then 1 end)/(count( case when deal_stage = 'Won' then 1 end) + count( case when deal_stage = 'Lost' then 1 end) ),2) as win_rate_per_manager
from maven_sales_pipeline.sales_pipeline as s 
left join maven_sales_pipeline.sales_teams as t
	on s.sales_agent = t.sales_agent 
group by t.manager 
order by win_rate_per_manager desc 
 limit 1;

-- Regional office who sold the most for the GTX Plus Pro 

select 
	st.regional_office, 
	count( case when sp.product  = 'GTX Plus Pro' and sp.deal_stage = 'Won' then 1 end ) as number_unit_sold
from maven_sales_pipeline.sales_pipeline sp 
left join maven_sales_pipeline.sales_teams st 
	on sp.sales_agent = st.sales_agent
group by st.regional_office
order by number_unit_sold desc
limit 1  ;


--Product Analysis 

select 
	product, 
	count( case when deal_stage= 'Won' then 1 end ) as unit_sold_product, 
	sum( case when deal_stage = 'Won' then close_value end) as revenue_product
from maven_sales_pipeline.sales_pipeline
	where extract(month from engage_date )= 03
group by product 
order by revenue_product desc; 

select 
	sp.product,
	--sp.close_value,
	--p2.sales_price, 
	AVG(p2.sales_price-sp.close_value) as average_diff
from maven_sales_pipeline.sales_pipeline as sp
left join maven_sales_pipeline.products as p2 
	on sp.product = p2.product
	where sp.deal_stage = 'Won'
group by sp.product 
; 


select 
	p.series, 
	sum( case when sp.deal_stage = 'Won' then sp.close_value end ) as revenue_product_series
from maven_sales_pipeline.sales_pipeline as sp
left join maven_sales_pipeline.products as p
	on sp.product = p.product
group by p.series
order by revenue_product_series desc ; 



-- Revenue by office_location 
select 
	office_location,
	sum(revenue) as revenue_office_location
from maven_sales_pipeline.accounts 
group by office_location 
order by revenue_office_location asc 
limit 1;


-- Find the gap in years between the oldest and newest customer.
select
		MAX(year_established)-MIN(year_established) as Gap_old_Newest
from maven_sales_pipeline.accounts;
-- Name those companies 
select 
	account,
	year_established
from maven_sales_pipeline.accounts
	where year_established = (select MAX(year_established) from maven_sales_pipeline.accounts) 
	or year_established = (select MIN(year_established) from maven_sales_pipeline.accounts)
;


	
-- Account that were subsidiaries with the most lost sales opportunities. 

select 
	ac.account,
	ac.subsidiary_of,
	COUNT( case when sp.deal_stage = 'Lost' then 1 end ) as lost_opportuntities
from maven_sales_pipeline.accounts as ac   
left join maven_sales_pipeline.sales_pipeline as sp
	on ac.account = sp.account 
	where ac.subsidiary_of is not null and ac.subsidiary_of <>''
group by ac.subsidiary_of, ac.account  
order by lost_opportuntities desc ; 


-- Join the companies to their subsidiaries. Find wich one had the highest revenue. 


select 
	--ac.account,
	ac.subsidiary_of,
	SUM( case when sp.deal_stage = 'Won' then sp.close_value end ) as revenue 
from maven_sales_pipeline.accounts as ac   
left join maven_sales_pipeline.sales_pipeline as sp
	on ac.account = sp.account
	where ac.subsidiary_of is not null and ac.subsidiary_of <>''
group by ac.subsidiary_of--, ac.account  
order by revenue desc ;



-- 

select 
	sum(close_value) as total_revenue_acme
from maven_sales_pipeline.sales_pipeline
	where account='Acme Corporation' or account in 
	(select 
		account
	from maven_sales_pipeline.accounts
		where subsidiary_of = 'Acme Corporation')
;
	

