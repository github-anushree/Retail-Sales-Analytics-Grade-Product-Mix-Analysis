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

