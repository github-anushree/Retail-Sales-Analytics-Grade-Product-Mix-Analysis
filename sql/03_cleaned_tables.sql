-- Step 3.3.1 — Create table schema (MySQL)

use retail_analytics;

drop table if exists cleaned_state_retail_sales;

create table cleaned_state_retail_sales (
geoname varchar(50),
year int,
sales_amount Double
)

-- Step 3.3.3 — Verify in MySQL Workbench
select count(*) from cleaned_state_retail_sales;

select * from cleaned_state_retail_sales
order by geoname, year
limit 20;

