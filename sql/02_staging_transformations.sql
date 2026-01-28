-- =========================================
-- 02_staging_transformations.sql
-- Purpose:
-- Create staging views with standardized
-- structure before building fact tables
-- =========================================

USE retail_analytics;

-- -------------------------------------------------
-- Staging View: State Retail Sales
-- -------------------------------------------------
-- Notes:
-- 1. Source data already cleaned in Python ETL
-- 2. This layer standardizes column names & types
-- 3. Filters rows not usable for analytics
-- -------------------------------------------------

CREATE OR REPLACE VIEW stg_state_retail_sales AS
SELECT
    TRIM(geoname) AS geoname,
    CAST(year AS INT) AS year,
    CAST(sales_amount AS DECIMAL(18,2)) AS sales_amount
FROM cleaned_state_retail_sales
WHERE year BETWEEN 2018 AND 2023;

-- “We use a staging layer to isolate raw ingestion from analytics logic.
-- Even though data is cleaned in Python, SQL staging ensures schema stability, safe type casting, and governance.”