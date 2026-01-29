# 📊 Retail Sales Analytics – Grade & Product Mix Analysis

## ⚠️ Disclaimer
This project is created purely for **learning and practice purposes**.  
All data used in this project is sourced from **publicly available US government datasets** (such as US Census / BEA–style retail data).  
This project **does not represent any real company’s confidential or proprietary data**.

---

## 📌 Project Overview
**Retail Sales Analytics – Grade & Product Mix Analysis** is an end-to-end data analytics project focused on analyzing:

- US retail sales performance  
- Product and category mix  
- Growth trends over time  
- Regional and state-wise performance  
- Sales stability and volatility  

The project demonstrates how **raw sales data** can be transformed into **business-ready insights** using **SQL, Python, Power BI, and Excel**, following an **industry-style analytics workflow**.

---

## 🎯 Business Objectives
The key business questions addressed in this project include:

- How are overall retail sales performing over time?
- Which product categories contribute the most to total sales?
- How does sales performance vary across states and regions?
- Which categories show stable vs volatile growth?
- How reliable and consistent are sales trends over time?
- What insights can leadership use for planning, forecasting, and optimization?

---

## 🧰 Tools & Technologies Used

- **SQL (MySQL)** – Data ingestion, staging, transformations, KPI preparation  
- **Python (Pandas, NumPy)** – Data cleaning, preprocessing, validation  
- **Power BI** – Interactive dashboards, DAX measures, drill-down analysis  
- **Excel** – KPI documentation, business question mapping  
- **Git & GitHub** – Version control and project documentation  

---

🗂️ Project Structure

Retail-Sales-Analytics-Grade-Product-Mix-Analysis
│
├── docs/
│   ├── data_modeling_notes.md
│   ├── kpi_views_notes.md
│   ├── python_cleaning_notes.md
│   └── project documentation files
│
├── images/
│   └── dashboard screenshots
│
├── Power BI/
│   └── Power BI dashboard (.pbix)
│
├── python/
│   ├── data_cleaning.py
│   └── bulk_load.py
│
├── sql/
│   ├── 01_raw_tables.sql
│   ├── 02_staging_transformations.sql
│   └── 03_cleaned_tables.sql
│
├── project1/
│   └── supporting Excel & documentation files
│
└── README.md

---

## 🔄 End-to-End Project Workflow

### 1️⃣ Data Collection
- Collected retail sales and benchmark data from public US datasets  
- Stored raw data into **SQL raw tables** to preserve original structure  

---

### 2️⃣ Data Cleaning & Transformation
Used **Python (Pandas)** to:
- Handle missing values  
- Standardize column formats  
- Validate data consistency  

Loaded cleaned data back into **SQL analytical tables**.

---

### 3️⃣ Data Modeling (Power BI)
- Designed a **star-schema style model**  
- Created **fact and dimension tables**  
- Ensured proper relationships for accurate filtering and aggregation  

---

### 4️⃣ KPI & DAX Development
Built business KPIs using **DAX**, including:
- Total Sales  
- YoY Growth %  
- MoM Growth %  
- Best Performing Category  
- Average Coefficient of Variation (Sales Stability)  

All KPIs and measures are **documented for transparency**.

---

### 5️⃣ Dashboard Development (Power BI)
The Power BI report contains **5 structured pages**:

#### 📄 Page 1 – Executive Summary
- Project overview and objectives  
- Key business insights and recommendations  
- Navigation buttons to detailed pages  

#### 📄 Page 2 – Sales Performance Overview
- Total Sales, YoY Growth, MoM Growth  
- Category-wise sales contribution  
- Time-series sales trends  

#### 📄 Page 3 – Geographic & Regional Analysis
- State-wise and region-wise sales  
- Best performing states  
- Regional growth comparisons  

#### 📄 Page 4 – Growth & Variability Analysis
- Growth distribution by category  
- MoM vs YoY growth trends  
- Sales stability using **Coefficient of Variation**  
- Risk vs growth matrix for categories  

#### 📄 Page 5 – Data Model & KPI Definitions
- Data model explanation  
- KPI definitions and assumptions  
- Measure documentation for analysts and reviewers  

---

## 📊 Key Insights Delivered
- Identified high-performing product categories driving most revenue  
- Highlighted regional differences in sales growth  
- Flagged volatile categories using variability metrics  
- Enabled leadership-style insights through clean and interactive dashboards  

---

## 📈 Learning Outcomes
- Hands-on experience with the end-to-end analytics lifecycle  
- Strong understanding of data modeling and filter context  
- Practical use of DAX for real business KPIs  
- Professional-grade Power BI dashboard design  
- GitHub project structuring and documentation best practices  

---

## 🚀 Future Enhancements
- Add forecasting models for sales prediction  
- Automate data refresh using scheduled pipelines  
- Enhance drill-through analysis for deeper category insights  
- Include customer-level analytics if data becomes available  

---

## 👤 Author
**Anushree Kashyap**  
Aspiring Data Analyst | SQL | Python | Power BI  

This project was built as part of **continuous learning and portfolio development**.
