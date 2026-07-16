/*
===============================================================================
Project: Maven Sales Pipeline Analysis
Script:  01_create_and_load_tables.sql
Purpose: Create the PostgreSQL schema and source tables used by the project.

Note:
- Source CSV files are loaded separately through the database import tool.
- DROP TABLE statements make this script rerunnable in a development database.
- Run this script only when rebuilding the project tables.
===============================================================================
*/

CREATE SCHEMA IF NOT EXISTS maven_sales_pipeline;

DROP TABLE IF EXISTS maven_sales_pipeline.sales_pipeline;
DROP TABLE IF EXISTS maven_sales_pipeline.sales_teams;
DROP TABLE IF EXISTS maven_sales_pipeline.products;
DROP TABLE IF EXISTS maven_sales_pipeline.accounts;

CREATE TABLE maven_sales_pipeline.accounts (
    account TEXT,
    sector TEXT,
    year_established INTEGER,
    revenue NUMERIC(10, 2),
    employees INTEGER,
    office_location TEXT,
    subsidiary_of TEXT
);

CREATE TABLE maven_sales_pipeline.products (
    product TEXT,
    series TEXT,
    sales_price NUMERIC(10, 2)
);

CREATE TABLE maven_sales_pipeline.sales_teams (
    sales_agent TEXT,
    manager TEXT,
    regional_office TEXT
);

CREATE TABLE maven_sales_pipeline.sales_pipeline (
    opportunity_id TEXT,
    sales_agent TEXT,
    product TEXT,
    account TEXT,
    deal_stage TEXT,
    engage_date DATE,
    close_date DATE,
    close_value NUMERIC(10, 2)
);

-- Run after importing the four source CSV files to validate record counts.
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
