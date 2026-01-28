### STEP 4 — STAR SCHEMA DESIGN & IMPLEMENTATION (SQL)

Objective:
Transform cleaned analytical data into a dimensional (star) schema to support scalable analytics, consistent KPIs, and efficient BI reporting.

### Why Step 4 Was Required
After Step 3:
1. Data was cleaned, validated, and loaded into MySQL
2. Data existed in a flat analytical table (cleaned_state_retail_sales)

However, flat tables are not optimal for:
1. Large-scale analytics
2. Reusable dimensions
3. BI tool performance
4. Consistent KPI logic

Therefore, Step 4 focuses on dimensional modeling using a Star Schema, which is the industry standard for analytics systems.

### Step 4.1 — Identify Facts & Dimensions
Fact Identification
From the cleaned dataset:

Column	                 Classification
sales_amount	         FACT (metric)
year	                 DIMENSION (time)
geoname	                 DIMENSION (geography)

## Fact Grain Definition
One row represents retail sales for one geography in one year.

This grain definition ensures:
1. Clear aggregation rules
2. No double counting
3. Predictable KPI behavior

### Step 4.2 — Design Dimension Tables
Two dimensions were identified and designed:
🟦 Dimension 1 — dim_date

Purpose:
Handle time-based analysis independently from the fact table.

Design Rationale:
1. Time attributes are reused across multiple facts
2. Supports future expansion (quarter, month, fiscal year)

Structure:
1. date_id (surrogate primary key)
2. year
3. year_label

Population Logic:
Derived from distinct years in the cleaned dataset

🟦 Dimension 2 — dim_geography

Purpose:
Provide geographic context for sales metrics.

Design Rationale:
1. Original geoname column contained multiple attributes
2. Decomposed for better filtering and scalability

Attributes Extracted:
1. state_name (e.g., Alabama, Texas)
2. region_type (Metropolitan / Nonmetropolitan)

Structure:
1. geo_id (surrogate primary key)
2. geoname
3. state_name
4. region_type

This separation aligns with enterprise data warehouse best practices.

### Step 4.3 — Create Fact Table & Relationships
Fact Table: fact_retail_sales

Purpose:
Store business metrics and link them to dimensions.

Grain:
One geography × one year

Structure:
1. fact_id (surrogate primary key)
2. geo_id (foreign key → dim_geography)
3. date_id (foreign key → dim_date)
4. sales_amount (metric)

Relationships Implemented
1. fact_retail_sales.geo_id → dim_geography.geo_id
2. fact_retail_sales.date_id → dim_date.date_id

This ensures:
1. Referential integrity
2. Clean joins
3. Reusable dimensions
4. Faster BI queries

⭐ Final Star Schema Overview
             dim_date
                |
                |
dim_geography — fact_retail_sales


1. Fact table contains only numeric metrics
2. Dimension tables contain descriptive attributes
3. No business logic duplicated in BI tools

### Business & Analytics Benefits
1. Single source of truth for sales metrics
2. Consistent KPI calculations
3. Improved Power BI performance
4. Easier maintenance and scalability

### Interview-Ready Summary (Memorize This)

“After cleaning the data, I designed a star schema by identifying retail sales as the central fact and creating separate date and geography dimensions.
The fact table stores metrics at a geography-year grain and references dimensions using surrogate keys, which improves performance, consistency, and BI usability.”

### Outcome of Step 4
1. Clean dimensional data model
2. Fully normalized star schema

## Ready for:
1. KPI views
2. SQL analytics
3. Power BI dashboards


### Step 6.1 — Power BI to MySQL Connection

- Connected Power BI Desktop to MySQL database `retail_analytics`.
- Loaded star schema tables: fact_retail_sales, dim_date, dim_geography.
- Verified one-to-many relationships between dimensions and fact table.
- Ensured transformations and KPI logic remain in SQL to maintain a thin BI layer.
- This setup enables scalable reporting and consistent business logic across tools.

### Step 6.2 — Sales Transactions Integration

- Loaded sales_transactions_raw.xlsx into Power BI.
- Identified transactional, lookup, and metadata sheets.
- Applied minimal Power Query transformations.
- Integrated Excel transactions with MySQL star schema using shared dimensions.
- Enabled hybrid reporting combining warehouse KPIs with transactional drill-down.

