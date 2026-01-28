### Step 5 — KPI Views & Business Metrics

Business KPIs were defined using SQL views to ensure consistency and governance.

- Total sales by year
- Sales by state and region type
- Year-over-year growth using window functions
- Top performing states
- Metropolitan vs non-metropolitan comparison

Defining KPIs in SQL ensures a single source of truth, reduces Power BI complexity, and improves trust in reported metrics.

### Final Interview Summary

“After building a star schema, we defined all core business KPIs using SQL views.
Power BI was used only as a visualization layer, while SQL remained the single source of truth for metrics.”

OR--

"We designed KPIs directly in SQL using fact and dimension tables.
This ensures one source of truth and allows Power BI to focus only on visualization, not business logic"

## KPI Problem Statements & Business Insights

This project defines multiple business KPIs at the SQL layer to support
executive reporting, trend analysis, and strategic decision-making.

Each KPI is implemented using optimized SQL views built on a star schema,
ensuring consistency, performance, and reusability across BI tools.
