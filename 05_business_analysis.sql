/*
===============================================================================
Project: Maven Sales Pipeline Analysis
Script:  05_business_analysis.sql
Purpose: Create reusable PostgreSQL views that supply the Power BI semantic
         model for revenue, pipeline, sales-agent, product, and account analysis.
===============================================================================
*/

-- =========================================================
-- Business Question:
-- How is revenue evolving month over month?
--
-- KPI:
-- Monthly Revenue
--
-- Description:
-- Returns total revenue from won deals aggregated by month.
-- =========================================================
create or replace view maven_sales_pipeline.vw_monthly_revenue as 
select  
	--close_date, 
	date_trunc('month', close_date)::date as revenue_month,
	sum(close_value) as monthly_revenue
from maven_sales_pipeline.sales_pipeline
	where deal_stage='Won'
group by revenue_month 
order by revenue_month;

select *
from maven_sales_pipeline.vw_monthly_revenue; 

----- =========================================================
-- Business Question:
-- How healthy is the sales pipeline ? 

-- Number of opportunites in the Active Pipeline = Prospecting, Engage

select 
deal_stage, 
count(*) as active_opportunity
from maven_sales_pipeline.sales_pipeline 
	where deal_stage IN ('Prospecting', 'Engaging')
group by deal_stage; 

-- Distribution per deal stage 

select 
	deal_stage,
	count(*) as number_deal
from maven_sales_pipeline.sales_pipeline
group by deal_stage;


-- Closing rate 
select
  count ( case when deal_stage='Won' then 1 end ) as won_deal, 
  count( case when deal_stage in ('Won','Lost') then 1 end) as won_and_lost,
 round (100.0*count ( case when deal_stage='Won' then 1 end )/count( case when deal_stage in ('Won','Lost') then 1 end),2)  as closing_rate
from maven_sales_pipeline.sales_pipeline;

/*Business Domain: Sales Pipeline Health
Business Questions:
How many active opportunities are there?
What is the distribution by deal stage?
What is the closing rate?
What is the pipeline value?
What is the average sales cycle?

Because these KPIs all belong to the same business domain, it's better to create one rich SQL view (vw_sales_pipeline_health) and let Power BI/DAX calculate the KPIs from it.
*/
create or replace view maven_sales_pipeline.vw_sales_pipeline_health as

select
    opportunity_id,
    sales_agent,
    product,
    account,
    deal_stage,
    engage_date,
    close_date,
    close_value,

    case 
        when deal_stage in ('Prospecting', 'Engaging') then 1 
        else 0 
    end as is_active_opportunity,

    case 
        when deal_stage = 'Won' then 1 
        else 0 
    end as is_won,

    case 
        when deal_stage = 'Lost' then 1 
        else 0 
    end as is_lost,

    case 
        when deal_stage in ('Won', 'Lost') then 1 
        else 0 
    end as is_closed,

    case 
        when deal_stage = 'Won' then close_value 
        else 0 
    end as won_revenue,
    
    case 
    	when deal_stage = 'Won' then close_date-engage_date 
    end as sales_cycle_days
    
from maven_sales_pipeline.sales_pipeline;


select *
from maven_sales_pipeline.vw_sales_pipeline_health
limit 5;
select
    sum(is_active_opportunity) as active_opportunities,
    sum(is_won) as won_deals,
    sum(is_lost) as lost_deals,
    sum(is_closed) as closed_deals,
    sum(won_revenue) as total_won_revenue
from maven_sales_pipeline.vw_sales_pipeline_health;

-- Sales Agent Performance 
create or replace view maven_sales_pipeline.vw_sales_agent_performance as 
select 
	sales_agent,
	opportunity_id,
	deal_stage,
	close_value,
	engage_date,
	close_date, 
	-- Active opportunities per agent
	case 
		when deal_stage in ('Prospecting', 'Engaging') then 1
		else 0 
	end as active_opportunity, 
	-- 
	case
		when deal_stage = 'Won' then 1
		else 0
	end as won_deals, 
	
	-- Value of won opportunities
	case 
		when deal_stage = 'Won' then close_value 
		else 0 
	end as won_revenue, 
	-- time to close a won 
	case 
		when deal_stage = 'Won' then close_date-engage_date
	end as sales_cycle_days, 
	-- closing ratio
	case
		when deal_stage in ('Won', 'Lost') then 1 
		else 0 
	end as closed_deals

from maven_sales_pipeline.sales_pipeline; 


select
	*
from maven_sales_pipeline.vw_sales_agent_performance 
limit 5;




-- Product Performance 
create or replace view maven_sales_pipeline.vw_product_performance as 
select 
	maven_sales_pipeline.sales_pipeline.product,
	deal_stage,
	close_value,
	engage_date,
	close_date, 
	-- Revenue per product 
	case 
		when deal_stage = 'Won' then close_value
	end as revenue, 
	
	-- active opportunity per product 
	case 
		when deal_stage in ('Prospecting', 'Engaging') then 1 
		else 0 
	end as active_opportunity, 
	
	-- Won deal per Product 
	case 
		when deal_stage = 'Won' then 1 
		else 0 
	end as won_deals, 
	
	-- Lost deal per Product 
	case 
		when deal_stage = 'Lost' then 1 
		else 0 
	end as lost_deals, 
	
	-- Average sales par cycle 
	 
	case 
		when deal_stage = 'Won' then close_date-engage_date 
		else 0 
	end as sales_cycle 
	
	

from maven_sales_pipeline.sales_pipeline;  

select
	*
from maven_sales_pipeline.vw_product_performance 
limit 5;

-- Account Performance 
create or replace view maven_sales_pipeline.vw_account_performance as 
select 
	sp.account, 
	sp.opportunity_id,
	sp.deal_stage,
	sp.engage_date,
	sp.close_date,
	a.office_location, 
	a.sector,
	a.employees,
	a.year_established, 
	a.subsidiary_of, 
	case 
		when deal_stage = 'Won' then close_value
		else 0
	end as revenue, 
	case 
		when deal_stage  = 'Won' then 1
		else 0
	end as won_deals,
	case 
		when deal_stage  = 'Lost' then 1
		else 0
	end as Lost_deals,
		-- closed deals per account
	case
		when deal_stage in ('Won', 'Lost') then 1 
		else 0 
	end as closed_deals, 
-- active deals per account 
	case 
		when deal_stage in ('Prospecting', 'Engaging') then 1 
		else 0 
	end as active_deals, 
	-- sales par cycle per account  
	 
	case 
		when deal_stage = 'Won' then close_date-engage_date 
		
	end as sales_cycle_days
	
	
from maven_sales_pipeline.sales_pipeline as sp
left join maven_sales_pipeline.accounts as a 
on sp.account = a.account;

select 
	count (*) 
from maven_sales_pipeline.vw_account_performance; 


select count(*) as sp_count
from maven_sales_pipeline.sales_pipeline;


