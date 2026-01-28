-- Step 4.2 — Design Dimension Tables
-- (dim_date, dim_geography)

-- ===============================
-- Dimension: Date
-- ===============================

-- SQL Design — dim_date
create table dim_date (
date_id int AUTO_INCREMENT primary key,
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
    geo_id int AUTO_INCREMENT primary key,
    geoname varchar (255),
    state_name varchar (100),
    region_type varchar (50)
);

-- Populate dim_geography
-- We extract values from geoname using SQL logic.
insert into dim_geography (geoname, state_name, region_type)
select distinct geoname,
trim(substring_index(geoname, '('1)) as state_name,
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

create table fact_retail_sales (
    fact_id int AUTO_INCREMENT primary key,
    geo_id int not null,
    date_id int not null,
    sales_amount decimal(18, 2),

    constraint fk_fact_geo
    foreign key geo_id references dim_geography(geo_id),

    constraint fk_fact_date
    foreign key (date_id) references dim_date(date_id)
);

-- This is textbook star schema SQL.

-- Step 4.3.3 — Populate FACT Table
-- We now join cleaned data → dimensions → keys

-- SQL — Insert Fact Records
insert into fact_retail_sales (geo_id, date_id, sales_amount)
select g.geo_id, d.date_id, c.sales_amount
from cleaned_state_retail_sales as c
join dim_geography  as g
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
