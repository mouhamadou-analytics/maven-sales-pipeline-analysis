# Maven Sales Pipeline Analysis

## Project overview

This end-to-end business intelligence project analyzes a B2B sales pipeline using PostgreSQL and Power BI. The dashboard is designed to help sales leadership understand revenue performance, pipeline health, sales-team results, product performance, and account-level revenue fluctuations.

The current analytical focus is the revenue declines observed in April, July, and October.

## Business objective

The analysis addresses five management questions:

1. How is revenue evolving month over month?
2. Is the active sales pipeline healthy enough to support future revenue?
3. Which sales agents and managers are driving performance?
4. Which products explain changes in revenue?
5. Which accounts contributed most to monthly revenue fluctuations, and were the declines concentrated or widespread?

## Tools

- PostgreSQL: data profiling, cleaning, exploratory analysis, and reporting views
- Power BI: data modeling, DAX measures, interactive analysis, and visualization
- DAX: KPI calculations and month-over-month comparisons
- GitHub: project documentation and version control

## Project workflow

```text
Source CSV files
      ↓
PostgreSQL table creation and import
      ↓
Data profiling and validation
      ↓
Data cleaning
      ↓
Exploratory analysis
      ↓
Reporting views
      ↓
Power BI data model and dashboard
```

## Repository structure

```text
01_create_and_load_tables.sql  Creates the schema and source tables
02_data_profiling.sql          Checks completeness, duplicates, validity, and relationships
03_data_cleaning.sql           Standardizes confirmed data-quality issues
04_exploratory_analysis.sql    Explores pipeline, product, team, and account patterns
05_business_analysis.sql       Creates reporting views used by Power BI
```

## Data-quality findings

- Blank account values were concentrated in Prospecting and Engaging opportunities and were treated as expected business behavior.
- No duplicate accounts, products, sales agents, or opportunity IDs were identified.
- No opportunities had an engagement date later than the close date.
- A product naming mismatch was identified: `GTXPro` in the pipeline table versus `GTX Pro` in the product table.
- The mismatch affected 1,480 opportunities and was standardized before reporting.

## Power BI model

The Power BI model uses the sales pipeline as the central fact table, supported by account, product, sales-team, and date dimensions. PostgreSQL views provide analysis-ready fields for:

- Monthly revenue
- Pipeline health
- Sales-agent performance
- Product performance
- Account performance

## Current findings

- Revenue declined in April, July, and October.
- April and October were mainly affected by fewer won deals.
- July was affected by both fewer won deals and a lower average deal value.
- Several leading products declined simultaneously, suggesting a broader sales-timing pattern rather than the failure of a single product.
- Software and technology sectors generated a higher share of revenue than their share of accounts.
- Retail represented the largest account portfolio but produced slightly lower revenue per account.

## Account contribution analysis

The account analysis compares each account's current-month revenue with its previous-month revenue. The contributions reconcile to the company-level month-over-month change.

For April 2017:

- March revenue: **$1,134,672**
- April revenue: **$721,932**
- Month-over-month change: **-$412,740**

The next analytical iteration will determine whether the April, July, and October declines were concentrated among a small number of accounts or distributed across the portfolio.

## Status

This repository represents Version 1 of an actively evolving portfolio project. The analysis, findings, recommendations, and dashboard visuals will continue to be refined.

## Data source

The project uses the Maven Analytics Sales Pipeline dataset, which contains accounts, products, sales teams, and sales opportunities for a fictional B2B company.
