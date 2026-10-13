# Olist E-Commerce Delivery Performance & Customer Experience Analysis

Analysis of 99,441 Brazilian e-commerce orders to identify which states and product categories have the highest late-delivery rates, and whether that correlates with customer review scores. Built end-to-end with PostgreSQL for analysis and Power BI for stakeholder-facing visualization.

## Business Question

Which product categories and regions have the highest late-delivery rates, and does that correlate with customer review scores?

This analysis is scoped to identifying **where** delivery problems are worst — not diagnosing root cause (seller, warehouse, or carrier-level data isn't available in this dataset). Intended for two stakeholder groups: Logistics/Operations (delivery performance) and Customer Experience (review/complaint fallout).

## Key Results

- Analyzed 99,441 orders across 27 Brazilian states and 70+ product categories
- Highest late-delivery rate by state: **Alagoas (AL)**, 23.0% of orders delivered late
- Highest late-delivery rate by category (500+ orders, to avoid small-sample noise): **electronics**, 9.6% of orders delivered late
- Statistically confirmed a **moderate negative correlation (-0.327)** between late delivery and customer review score using `CORR()`
- Built a window-function ranking (`RANK() OVER (PARTITION BY state ORDER BY late_rate DESC)`) to surface the worst-performing category within each state — reliable for 5 high-volume states (MG, PR, RJ, RS, SP) after filtering out categories with under 500 orders to avoid noise from small samples

## Dashboard

4-visual Power BI dashboard, built on PostgreSQL views (Import mode, refreshed from a local PostgreSQL instance):
1. Late delivery rate by state
2. Late delivery rate by product category
3. Late rate vs. average review score by state (combo chart)
4. Worst-performing category per state (high-volume states only)

See `dashboard_screenshot.png` for a preview, or open `Olist_Delivery_Dashboard.pbix` in Power BI Desktop (requires a local PostgreSQL instance with the Olist dataset loaded to refresh the data — see Setup below).

## Tools & Techniques

- **PostgreSQL**: joins across orders, customers, products, sellers, and reviews tables; `CASE WHEN` conditional flagging; `GROUP BY` aggregations; `HAVING` filters; `CORR()` statistical correlation; window functions (`RANK() OVER (PARTITION BY ... ORDER BY ...)`); SQL views (`CREATE VIEW`) as the data layer for Power BI
- **Power BI**: PostgreSQL connection (Import mode), clustered bar charts, combo (line + column) charts, table visuals

## Dataset

[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (Kaggle) — 9 relational CSV tables covering orders, customers, products, sellers, payments, reviews, and geolocation.

## Setup

1. Download the Olist dataset from Kaggle (link above)
2. Load the 9 CSVs into a local PostgreSQL database (table schemas and `\copy` commands not included here — see `analysis.sql` for the queries run against the loaded tables)
3. Run `analysis.sql` to create the underlying views (`vw_late_rate_by_state`, `vw_late_rate_by_category`, `vw_review_vs_late_by_state`, `vw_worst_category_by_state`)
4. Open `Olist_Delivery_Dashboard.pbix` in Power BI Desktop and point the PostgreSQL connection to your local database

## Files

- `requirements_doc.md` — project scope, stakeholders, and definition of "done" (written before any SQL)
- `analysis.sql` — all SQL queries and view definitions
- `Olist_Delivery_Dashboard.pbix` — Power BI dashboard file
- `dashboard_screenshot.png` — static preview of the dashboard
