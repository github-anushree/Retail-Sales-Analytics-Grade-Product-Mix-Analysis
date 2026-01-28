### Step 2: Data Profiling
Observation	                           Meaning
(D) exists	                           Suppressed / confidential value
Year columns are object	               Need numeric conversion
Data is wide (y2018–y2023)	           Not analytics-friendly
Only 1 row has (D)	                   Cleaning logic is simple & explainable

### Step 2.1 – Handling Suppressed Values
The dataset contained '(D)' values indicating suppressed data.
These were converted to NULL to avoid incorrect assumptions.

### Step 2.2 – Data Type Standardization
All yearly sales columns were converted from string to numeric
to enable aggregation and KPI calculations.

### Step 2.3 – Data Reshaping
Year-based columns were unpivoted into a long format to create
a normalized time-series structure suitable for SQL analytics
and Power BI reporting.

### Step 2.4 – Persisting Cleaned Data
The cleaned and reshaped dataset was written back to MySQL as
`cleaned_state_retail_sales`, creating a dedicated analytics-ready
table while preserving the raw source data.

***Up to Step 2, we validated logic using a small sample dataset.***
***From Step 3 onward, we transitioned to full production-scale datasets, simulating real company workflows.***

### STEP 3 — Load FULL datasets (Bulk Insert & Scaling)

We will now behave like this:

“Raw data arrived from an upstream system as Excel/CSV files.
We bulk-loaded them into raw tables and validated completeness.”

### Step 3.1 — Decide ingestion strategy
Options companies use:
Method	                               When used
LOAD DATA INFILE	                   Very large CSVs
pandas.to_sql()	                       Medium datasets
ETL tools (Airflow, Fivetran)	       Production

For this project (realistic + controllable):
We will use Python + to_sql()

This is perfectly acceptable for analyst-owned pipelines.

### Under Step 3 – Bulk Data Ingestion (Raw Layer)
-- Objective
The purpose of this step is to ingest full raw datasets into the database in a scalable and reproducible way.
This simulates a real enterprise workflow where raw data is delivered from upstream systems and loaded into a raw schema for further processing.

-- Data Sources
1.state_retail_sales_raw.xlsx
2.Contains state-level retail sales data
3.sales_transactions_raw.xlsx
4.Contains transactional sales-level data

These datasets represent upstream source systems in a real company environment.

-- Ingestion Strategy
For this project, Python + SQLAlchemy + pandas to_sql() is used for bulk ingestion.

-- Reasoning:
1.Suitable for analyst-managed pipelines
2.Easy validation of row counts
3.Allows preprocessing if required
4.Common in mid-sized analytics teams

-- Raw Data Design Principles
1.Raw tables store data as received
2.No business logic applied
3.No transformations applied
4.Raw layer is preserved for audit and traceability

-- Raw Tables Created
The following raw tables are created:
1. raw_state_retail_sales

Stores state-level retail sales data
Used later for regional and trend analysis

2. raw_sales_transactions

Stores transaction-level sales data
Used for KPI calculations and dashboard metrics

-- Validation Performed

1.After ingestion, the following validations are performed:
2.Row count comparison between source files and database
3.Sample data inspection using LIMIT
4.Schema verification

-- Outcome

1.Full datasets successfully loaded into MySQL
2.Raw layer established
3.Ready for staging and cleaning transformations

-- Interview-ready line:

“I bulk-loaded full raw datasets into SQL using Python, validated row counts, and preserved an immutable raw layer for downstream analytics.”

### FILE: bulk_load.py

bulk_load.py (NEW FILE — Step 3 starts here)

-- Purpose:
1.Load FULL Excel datasets
2.Clean header rows
3.Rename columns
4.Convert datatypes
5.Bulk insert into MySQL

### Step 3.2.1 — Fix header rows (CRITICAL)

--Your output shows:
1.Row 0–3 → metadata
2.Row 4   → actual column headers

# 📘 Data Cleaning & Bulk Load Documentation

**Project:** Sales Performance Analytics  
**Phase:** Step 3 — Full Dataset Processing  

---
### **What we have done in bulk_load.py coding section**
## 🔹 Step 3 Overview — Why This Step Exists

Up to **Step 2**, logic was validated using a **small sample dataset**.  
From **Step 3 onward**, the pipeline transitions to **full production-scale datasets**, simulating real-world company workflows.

### Objectives of Step 3

- Load full raw datasets
- Clean messy government Excel files
- Standardize schema
- Prepare analytics-ready tables
- Maintain separation of **raw**, **staging**, and **cleaned** layers

---

## 🟢 Step 3.1 — Bulk Load FULL Dataset (Excel → Pandas)

### Dataset Used

- **File:** `project1_state_retail_sales_raw.xlsx`
- **Source:** Bureau of Economic Analysis (BEA)

### Actions Performed

- Loaded Excel file using `pandas.read_excel`
- Verified:
  - Row count
  - Column count
  - Data types
  - Header alignment

### Observations

The dataset contained:
- Metadata rows
- Column headers not located at row 0
- Footer legends
- Suppressed values marked as `(D)`

### Outcome

- Raw data successfully loaded into Pandas
- Dataset confirmed **not analysis-ready**

---

## 🟢 Step 3.2 — Clean FULL Dataset (`bulk_load.py`)

> **Note:**  
> All transformations in this step were performed in **Python**, not SQL.

---

### Step 3.x — SQL Staging Layer

After bulk loading cleaned data via Python, a SQL staging layer was created.

The staging layer:
- Standardizes data types
- Renames columns consistently
- Filters invalid or out-of-scope records
- Acts as a safety buffer before fact table creation holding.

This design mirrors real-world warehouse practices where staging protects downstream analytics.


### ✅ Step 3.2.1 — Fix Header Rows

#### Problem
- Column headers were embedded within data rows

#### Solution
- Identified the row containing actual column names
- Reset DataFrame headers
- Dropped preceding metadata rows

#### Result
- Columns correctly aligned as:

GeoFips, GeoName, 2018, 2019, 2020, 2021, 2022, 2023


---

### ✅ Step 3.2.2 — Rename Columns (Standardization)

#### Why
- Standard naming is required for SQL compatibility and analytics consistency

#### Changes
- `GeoName` → `geoname`
- `2018` → `y2018`, … `2023` → `y2023`

#### Result
- Consistent naming across raw, staging, and cleaned layers

---

### ✅ Step 3.2.3 — Remove Empty Rows

#### Problem
- Rows contained no geographic data

#### Solution
- Dropped rows where all year values were null

#### Result
- Reduced noise
- Improved data quality

---

### ✅ Step 3.2.4 — Handle Suppressed Values `(D)`

#### Business Meaning
- `(D)` indicates data suppressed for confidentiality

#### Action
- Replaced `(D)` with `NaN`
- Preserved row integrity (no row deletion)

#### Why
- Enables numeric aggregation
- Maintains transparency of missing values

---

### ✅ Step 3.2.5 — Convert Year Columns to Numeric

#### Action
- Converted `y2018`–`y2023` to numeric
- Invalid values coerced to `NaN`

#### Result
- Dataset ready for calculations
- Correct data types enforced

---

### ✅ Step 3.2.6 — Reshape Wide → Long (Unpivot)

#### Why
- Analytics and BI tools prefer long-format data

#### Transformation

**From (Wide):**
geoname | y2018 | y2019 | y2020 | ...


**To (Long):**
geoname | year | sales_amount


#### Result
- ~720 rows (120 regions × 6 years)
- Analytics-ready structure

---

### ✅ Step 3.2.7 — Remove Footer / Legend Rows (Critical)

#### Problem
- Dataset contained explanatory footnotes at the bottom

#### Solution
- Filtered rows using `GeoFips`
- Kept only rows where `GeoFips` was numeric

```python
df = df[df["GeoFips"].astype(str).str.match(r"^\d+$", na=False)]

Removed

Notes such as:

(D) Not shown to avoid disclosure

Last updated: December 4, 2024

Result

Clean, production-grade dataset

📊 Final Output of Step 3.2
Attribute	Value
Rows	~720
Columns	geoname, year, sales_amount
Data Quality	Clean, typed, analytics-ready
Missing Values	Legitimate (from (D) suppression)


## Step 3.3 — Bulk Load Cleaned Dataset to MySQL
1. Designed final analytics-ready dataset in Python using Pandas
2. Removed metadata headers and footer legends from raw Excel source
3. Handled suppressed values (D) using business-safe null logic
4. Converted year columns to numeric and reshaped data to long format
5. Created production MySQL table cleaned_state_retail_sales
6. Performed bulk insert using to_sql() with chunking for scalability
7. Verified row counts and data integrity in MySQL Workbench

This step established the single source of truth for downstream SQL analytics and BI reporting.



### Step 4.2 — Dimension Design

We designed separate dimension tables to follow a star schema.

- dim_date was created to handle time-based analysis independently from the fact table.
- dim_geography was created by decomposing the geoname field into state_name and region_type.
- This improves scalability, reduces redundancy, and aligns with enterprise data modeling standards.

### Step 4.3 — Fact Table & Star Schema

A star schema was implemented by creating a central fact table (`fact_retail_sales`)
that stores retail sales metrics at the grain of geography-year.

- The fact table references `dim_geography` and `dim_date` using surrogate keys.
- All descriptive attributes were moved to dimensions.
- This design improves query performance, scalability, and BI integration.
