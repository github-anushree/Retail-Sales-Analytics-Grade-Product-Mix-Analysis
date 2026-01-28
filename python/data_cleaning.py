#Connect Python to MySQL
import pandas as pd
from sqlalchemy import create_engine

# -----------------------------------
# MySQL connection configuration
# -----------------------------------

USERNAME = "root"
PASSWORD = "admin"
HOST = "localhost"
PORT = "3306"
DATABASE = "retail_analytics"

# -----------------------------------
# Create SQLAlchemy engine
# -----------------------------------

engine = create_engine(
    f"mysql+mysqlconnector://{USERNAME}:{PASSWORD}@{HOST}:{PORT}/{DATABASE}",
    isolation_level="AUTOCOMMIT"
)


#Add a DB verification check
db_check = pd.read_sql("SELECT DATABASE()", engine)
print("Connected to database", db_check.iloc[0, 0])

print("MySQL connection engine created successfully")

query = "SELECT * FROM retail_analytics.raw_state_retail_sales"
df_raw = pd.read_sql(query, engine)

print("Raw data loaded successfully!\n")
print(df_raw.head())
print("\nDate Info:\n")
print(df_raw.info())

server_info = pd.read_sql("""
SELECT 
    @@hostname AS hostname,
    @@port AS port,
    @@version AS version,
    @@datadir AS datadir
""", engine)

print(server_info)

#Data Profiling (NO cleaning yet)

print("\n---STEP 2:Basic Data Profilling---")

#shape
print("Shape:", df_raw.shape)

#column wise unique values
for col in df_raw.columns:
    print(f"\nUnique values in {col}")
    print(df_raw[col].unique())

## Check for suppressed values like '(D)'
print("\nRows with suppressed values (D):")
print(df_raw[df_raw.isin(['(D)']).any(axis=1)])

#step 2.1 and 2.2
print("\n---step 2.1 and step 2.2: Cleaning Data---")

# Make a copy of raw data (best practice)
df_clean = df_raw.copy()

## Identify year columns
year_columns = [col for col in df_clean.columns if col.startswith('y')]
print('Year Columns Identified:', year_columns)

## Replace '(D)' with NaN
df_clean[year_columns] = df_clean[year_columns].replace('(D)', pd.NA)

print('\n After replacing (D) with NAN:')
print(df_clean)

# Convert year columns to numeric
df_clean[year_columns] = df_clean[year_columns].apply(pd.to_numeric, errors = 'coerce')

print('\nAfter converting year column to numeric:')
print(df_clean)

print('\nUpdated data types:')
print(df_clean.dtypes)

print('\nMissing Values count per column:')
print(df_clean.isna().sum())

#STEP 2.3 Reshape Wide → Long (Unpivot)
print('\n---Step 2.3: Reshape Data (Wide--> Long)---')

## Unpivot year columns
df_long = df_clean.melt(
    id_vars=["geoname"],
    value_vars=year_columns,
    var_name="year",
    value_name="sales_amount"
)

## Clean year column (remove 'y' prefix)
df_long["year"] = df_long["year"].str.replace("y", "").astype(int)

print("\nReshaped (Long Format) Data:")
print(df_long)

print("\nLong formate Data Info:")
print(df_long.info())

print("\nMissing Values in Long Format:")
print(df_long.isna().sum())


#STEP 2.4 — Write CLEANED Data Back to MySQL
print('\n----Step 2.4: Write Cleaned Data Back to MYSQL---')

## Write cleaned long-format data to MySQL(VERIFY IN MYSQL WORKBENCH too)
# after verify keep the secttion step 2.4 commented
#Keep Step 2.4 COMMENTED for now 
#We will recreate cleaned tables using FULL data, not sample data.
#So this section stays commented until Step 3.4.

#df_long.to_sql(
    #name="cleaned_state_retail_sales",
    #con = engine,
    #if_exists= "replace",  # replace for now (safe during development)
    #index= False
#)

#print("Cleaned data successfully written to MySQL table: cleaned_state_retail_sales")
print("\n🔥🔥 REACHED STEP 3 SECTION 🔥🔥\n")


# -----------------------------------
# Till here we have tested using small data , from step 3 we will bulk load data set and perform actual operations
# -----------------------------------

#STEP 3.1.2 — Load FULL State Retail Sales (Excel → Pandas)
print("\n---Step 3.1.1: Load Full State Retail Sales Dateset---")

state_sales_path = r"C:\Users\Lenovo\Downloads\sales-performance-analytics\project1\project1_state_retail_sales_raw.xlsx"

df_state_full = pd.read_excel(state_sales_path)

print("State Retail Sales Raw Shape:", df_state_full.shape)
print("summary of a DataFrame.",df_state_full.info())
print("show first 5 records",df_state_full.head())

