# Requirements Document

## Business Question

Which product categories and regions have the highest late-delivery rates, and does that correlate with customer review scores?

## Stakeholders

- **Logistics / Operations** — owns delivery performance. Uses this analysis to see where late deliveries are concentrated (by state and by category), as a first-pass signal for where to look deeper.
- **Customer Experience** — owns review and complaint fallout, not root cause. Uses this analysis to understand whether delivery problems are actually showing up in customer sentiment, or if they're separate issues.

## Decision This Analysis Informs

Where to prioritize investigation first — which states and which product categories show the worst delivery performance, and whether that performance is measurably affecting how customers rate their experience. This analysis flags *where* the problem is worst; it does not diagnose *why* (seller, warehouse, or carrier-level data isn't available in this dataset, so root-cause investigation is explicitly out of scope).

## Definition of "Done"

A 4-visual Power BI dashboard, connected live to PostgreSQL, showing:
1. Late-delivery rate by state
2. Late-delivery rate by product category
3. Late-delivery rate alongside average review score, by state
4. The worst-performing product category within each high-volume state

Supported by a statistical check (`CORR()`) confirming whether late delivery and review score are actually related, not just visually similar.
