create database retail_analytics;
use retail_analytics;

-- Create raw table (simulate DE work)
create table raw_state_retail_sales(
geoname varchar(255),
y2018 varchar(50),
y2019 varchar(50),
y2020 varchar(50),
y2021 varchar(50),
y2022 varchar(50),
y2023 varchar(50)
);

-- Insert sample raw data
insert into raw_state_retail_sales values
('California (Metropolitan Portion)', '850000', '870000', '820000', '880000', '910000', '940000'),
('California (Nonmetropolitan Portion)', '120000', '125000', '(D)', '130000', '135000', '140000'),
('Texas (Metropolitan Portion)', '780000', '800000', '760000', '810000', '850000', '880000');

-- Validate table exists
select * from raw_state_retail_sales;

SELECT DATABASE();

SELECT * 
FROM retail_analytics.raw_state_retail_sales;

SELECT COUNT(*) 
FROM retail_analytics.raw_state_retail_sales;

USE retail_analytics;

TRUNCATE TABLE raw_state_retail_sales;

INSERT INTO raw_state_retail_sales VALUES
('California (Metropolitan Portion)', '850000', '870000', '820000', '880000', '910000', '940000'),
('California (Nonmetropolitan Portion)', '120000', '125000', '(D)', '130000', '135000', '140000'),
('Texas (Metropolitan Portion)', '780000', '800000', '760000', '810000', '850000', '880000');

-- verify
SELECT * FROM raw_state_retail_sales;

-- show database to verify actually we are working on which database is existed or not
SHOW DATABASES;

SELECT COUNT(*) 
FROM retail_analytics.raw_state_retail_sales;

-- SELECT COUNT(*) 
-- FROM retail_analytics_project.raw_state_retail_sales;

SELECT 
    @@hostname AS hostname,
    @@port AS port,
    @@version AS version,
    @@datadir AS datadir;

-- Drop & recreate table using SQL SCRIPT (not grid)
-- because we are failed to see the rows in python file (data_cleaning.py - vs code)
-- thats why we are droping table and re-creating
-- read this:
-- we created & inserted data in MySQL Workbench using Workbench’s result-grid editor / implicit session, and MySQL 9.1 + SQLAlchemy (any driver) is not seeing those rows because of transaction + metadata caching behavior.
-- This is a known pain point with MySQL 8.4+ / 9.x, especially on Windows.
-- In simple words:
-- Workbench can see the rows, but the server is not exposing them properly to external clients yet.

-- Step 3.2 — Create RAW tables (SQL first)
-- =====================================
-- 01_raw_tables.sql
-- Purpose: Store raw, unmodified data
-- =====================================
DROP TABLE IF EXISTS raw_state_retail_sales;

CREATE TABLE raw_state_retail_sales (
    geoname VARCHAR(255),
    y2018 VARCHAR(20),
    y2019 VARCHAR(20),
    y2020 VARCHAR(20),
    y2021 VARCHAR(20),
    y2022 VARCHAR(20),
    y2023 VARCHAR(20)
);

INSERT INTO raw_state_retail_sales VALUES
('California (Metropolitan Portion)', '850000', '870000', '820000', '880000', '910000', '940000'),
('California (Nonmetropolitan Portion)', '120000', '125000', '(D)', '130000', '135000', '140000'),
('Texas (Metropolitan Portion)', '780000', '800000', '760000', '810000', '850000', '880000');

COMMIT;
-- Verify
SELECT COUNT(*) FROM raw_state_retail_sales;
SELECT * FROM raw_state_retail_sales;

-- step 2.4 (verification)
-- if show error: Run
FLUSH TABLES;
-- 
-- “During development, Python ETL was recreating tables using to_sql(replace), which caused MySQL metadata cache issues (Error 1412).
-- We resolved it by restarting the query session and later switched to append mode for production.”

select count(*) from cleaned_state_retail_sales;

select * from cleaned_state_retail_sales
order by geoname, year;

-- Step 3.3.1 — Create table schema (MySQL)
Drop table if exists cleaned_state_retail_sales;

create table cleaned_state_retail_sales (
geoname varchar(50),
year int,
sales_amount double
)

-- Step 3.3.3 — Verify in MySQL Workbench
select count(*) from cleaned_state_retail_sales;

select * from cleaned_state_retail_sales
order by geoname, year
limit 20;

flush tables;

-- Step 4.2 — Design Dimension Tables
-- (dim_date, dim_geography)

-- ===============================
-- Dimension: Date
-- ===============================

-- SQL Design — dim_date
create table dim_date (
date_id int auto_increment primary key,
year int not null,
year_label varchar(10)
);

-- Populate dim_date
insert into dim_date (year, year_label)
select distinct year, cast(year as char)
from cleaned_state_retail_sales
order by year;

-- verify
select * from dim_date;

-- Dimension 2: dim_geography
-- ===============================
-- Dimension: Geography
-- ===============================
create table dim_geography (
geo_id int auto_increment primary key,
geoname varchar (255),
state_name varchar (100),
region_type varchar (50)
);

-- Populate dim_geography
-- We extract values from geoname using SQL logic.
insert into dim_geography (geoname, state_name, region_type)
select distinct geoname,
trim(substring_index(geoname, '(', 1)) as state_name,
case
when geoname like '%Metropolitan%' THEN 'Metropolitan'
when geoname like '%Nonmetropolitan%' THEN 'Nonmetropolitan'
else 'Unknown'
end as region_type
from cleaned_state_retail_sales;

-- Verify Dimension Tables
select * from dim_geography;

-- ===============================
-- Fact Table: Retail Sales
-- ===============================

create table fact_retail_sales(
fact_id int auto_increment primary key,
geo_id int not null,
date_id int not null,
sales_amount decimal(18, 2),

CONSTRAINT fk_fact_geo
        FOREIGN KEY (geo_id)
        REFERENCES dim_geography(geo_id),

    CONSTRAINT fk_fact_date
        FOREIGN KEY (date_id)
        REFERENCES dim_date(date_id)
);

-- This is textbook star schema SQL.

-- Step 4.3.3 — Populate FACT Table
-- We now join cleaned data → dimensions → keys

-- SQL — Insert Fact Records
insert into fact_retail_sales (geo_id, date_id, sales_amount)
select g.geo_id, d.date_id, c.sales_amount
from cleaned_state_retail_sales as c
join dim_geography as g
on c.geoname = g.geoname
join dim_date as d
on c.year = d.year;

-- Step 4.3.4 — Verify Relationships
select count(*) from fact_retail_sales;

select * from fact_retail_sales
limit 10;

-- And test joins:
select g.state_name, g.region_type, d.year, f.sales_amount
from fact_retail_sales  as f
join dim_geography as g
on f.geo_id = g.geo_id
join dim_date as d
on f.date_id = d.date_id
order by g.state_name, d.year
limit 40;

-- STEP 5 — KPI Views & Business Metrics (SQL)

-- KPI 1 — Total Retail Sales by Year

-- Business Question
-- “How much total retail sales did we generate each year?”

-- =====================================
-- KPI 1: Total Retail Sales by Year
-- =====================================

create or replace view kpi_total_sales_by_year as 
select d.year, sum(f.sales_amount) as total_sales
from fact_retail_sales as f
join dim_date as d
on f.date_id = d.date_id
group by d.year
order by d.year;

-- Validation Query
select * from kpi_total_sales_by_year;

-- Interview Explanation
-- “This KPI aggregates retail sales annually using the fact table joined with the date dimension to ensure time consistency.”

-- KPI 2 — Total Sales by State & Region Type
-- Business Question
-- “Which states and region types are driving sales?”

-- =====================================
-- KPI 2: Sales by State & Region Type
-- =====================================
create or replace view kpi_sales_by_state_region as 
select g.state_name, g.region_type, sum(f.sales_amount) as total_sales
from fact_retail_sales as f
join dim_geography g
on f.geo_id = g.geo_id
group by g.state_name, g.region_type
order by total_sales desc;

-- validate
select * from kpi_sales_by_state_region;

-- Interview Explanation
-- “This KPI allows comparison between metropolitan and non-metropolitan performance at a state level.”

-- KPI 3 — Year-over-Year (YoY) Sales Growth
-- Business Question
-- “How fast are retail sales growing year over year?”

create or replace view kpi_yoy_sales_growth as
select total_sales, 
lag(total_sales) over (order by year) as prev_year_sales,
round(
total_sales - lag(total_sales) over (order by year)
/ lag(total_sales) over (order by year) * 100,
2
) as yoy_growth_pct
from kpi_total_sales_by_year;

-- Interview Explanation
-- “We used SQL window functions to calculate YoY growth, ensuring KPI logic stays centralized and reusable across reports.”

-- KPI 4 — Top Performing States
-- Business Question
-- “Which states contribute the most to retail sales?”

-- =====================================
-- KPI 4: Top States by Retail Sales
-- =====================================
create or replace view kpi_top_states_by_sales as 
select g.state_name , sum(f.sales_amount) as total_sales
from fact_retail_sales as f
join dim_geography as g
on f.geo_id = g.geo_id
group by g.state_name
order by g.state_name;

-- validate
select * from kpi_top_states_by_sales;

-- KPI 5 — Metropolitan vs Non-Metropolitan Comparison
-- Business Question
-- “Do metropolitan regions outperform non-metropolitan regions?”

-- =====================================
-- KPI 5: Metro vs Non-Metro Comparison
-- =====================================

create or replace view kpi_region_type_comparison as
select g.region_type, sum(f.sales_amount) as total_sales
from fact_retail_sales as f
join dim_geography as g
on f.geo_id = g.geo_id
group by g.region_type;

-- validate
select * from kpi_region_type_comparison;

-- KPI Views were created as VIEW or not ? (This got truble when connecting mysql database to power bi, nevigation window show all fact/dimension
-- table, but dont show VIEW , that'swhy we have to verify)
-- please verify
show full tables
where Table_type = 'VIEW';



