# Step 3: Begin here "bulk_load.py"
#Purpose of bulk_load.py
#Load FULL Excel datasets, Clean header rows, Rename columns, Convert datatypes, Bulk insert into MySQL

print("=====Step 3 starts from here: Load Full Data Set=====")

import pandas as pd
from sqlalchemy import create_engine

# DB connection
engine = create_engine(
    "mysql+mysqlconnector://root:admin@localhost:3306/retail_analytics",
    isolation_level="AUTOCOMMIT"
)

print("Conneted to mysql")

# -------------------------------
# Step 3.1 — Load FULL State Retail Sales
# -------------------------------

print("===Step 3.1===")

#file_path = r"project1/project1_state_retail_sales_raw.xlsx"

#df_raw = pd.read_excel(file_path, header=None)

#print("Raw Shape:", df_raw.shape)
#print("Show first 10 rows:", df_raw.head(10))

print("\n---Step 3.1.1: Load Full State Retail Sales Dateset---")

state_sales_path = r"C:\Users\Lenovo\Downloads\sales-performance-analytics\project1\project1_state_retail_sales_raw.xlsx"

df_state_full = pd.read_excel(state_sales_path)

print("State Retail Sales Raw Shape:", df_state_full.shape)
print("summary of a DataFrame.",df_state_full.info())
print("show first 5 records",df_state_full.head())

#NOW — Step 3.2: Clean FULL State Retail Sales Dataset
print("===Step 3.2===")

print("===Step 3.2.1 — Fix header rows===")

# -------------------------------
# Step 3.2.1 — Fix headers
# -------------------------------

# Set row 4 as header

df_state_full.columns = df_state_full.iloc[4]

# Drop metadata rows
df_state_full = df_state_full.iloc[5:].reset_index(drop=True)

print("\nAfter Fixing Headers")  #This is mandatory for Census/BEA data.
print(df_state_full.head())
print(df_state_full.info)

## Step 3.2.2 — Rename columns
# Rename columns for consistency

print("===Step 3.2.2- Rename Columns===")

df_state_full = df_state_full.rename(columns={
    "GeoName" : "geoname",
    "2018" : "y2018",
    "2019" : "y2019",
    "2020" : "y2020",
    "2021" : "y2021",
    "2022" : "y2022",
    "2023" : "y2023"
})

print("After renaming columns:")
print(df_state_full.columns)


# Step 3.2.3 — Remove empty rows
print("===Step 3.2.3 - Remove Empty Rows===")

## Drop rows where geoname is missing
df_state_full = df_state_full[df_state_full["geoname"].notna()]  #notna() : “Keep only those rows where geoname has a value.”
print("\nAfter removing empty rows")
print(df_state_full.shape)

#Step 3.2.4 — Handle suppressed values (D)
print("===Step 3.2.4 - Handle suppressed values (D)===")

year_cols = [c for c in df_state_full.columns if c.startswith('y')]
df_state_full[year_cols] = df_state_full[year_cols].replace("(D)", pd.NA)

print("\nSuppressed Value Handle:")
print(df_state_full[year_cols].isna().sum())

#Step 3.2.5 — Convert to numeric
print("===Step 3.2.5 — Convert to numeric===")

df_state_full[year_cols] = df_state_full[year_cols].apply(pd.to_numeric, errors = "coerce")
print("\nAfter Numeric Conversion")
print(df_state_full.dtypes)

# -----------------------------------
# Step 3.2.6 — Remove footer / legend rows
# -----------------------------------

# Keep rows where GeoFips is numeric (real regions)
print("===Step 3.2.6 Remove footer/legend rows===")

df_state_full = df_state_full[df_state_full["GeoFips"].astype(str).str.match(r"^\d+$", na = False)]

print("\nAfter removing footer/legend rows:")
print(df_state_full.shape)
print(df_state_full.tail())

#Step 3.2.7— Reshape (Wide → Long)
print("===Step 3.2.7- Reshape (Wide -> Long)")

df_state_long = df_state_full.melt(
    id_vars=["geoname"],
    value_vars=year_cols,
    var_name="year",
    value_name="sales_amount"
)

df_state_long["year"] = df_state_long["year"].str.replace("y", "").astype(int)

print("\nFinal Cleaned Long Dataset:")
print(df_state_long.head())
print(df_state_long.info())

print("Last 10 row of df_state_long")
print(df_state_long.tail())


#Step 3.3 — Write FULL cleaned dataset to MySQL (Bulk Insert)

### Step 3.3.2 — Bulk insert using Python

# -----------------------------------
# Step 3.3 — Bulk write to MySQL
# -----------------------------------
print("===Step 3.3- Bulk write to MySQL===")

df_state_long.to_sql(
    name = "cleaned_state_retail_sales",
    con = engine,
    if_exists="append" , # IMPORTANT (production-safe)
    index= False,
    chunksize= 1000   # BULK INSERT
)
print("FULL cleaned dataset successfully loaded to MySQL")

### Step 3.3.3 — Verify in MySQL Workbench

#Step 4 — Build STAR SCHEMA (SQL)

# STEP 5 — KPI Views & Business Metrics (SQL)

# Step 6 — Power BI Integration (Professional Way)

# Step 6.1 — Power BI to MySQL Connection

# Step 6.6 — Dashboard Design & Visual Layout (Power BI)