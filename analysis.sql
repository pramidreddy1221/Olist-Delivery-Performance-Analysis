-- Query 1: Classify each order's delivery status (on time / late / never delivered)
select order_id, order_delivered_customer_date, order_estimated_delivery_date,
CASE
WHEN order_delivered_customer_date IS NULL 	THEN 'Not Delivered'
WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
ELSE 'On-Time'
END as deliverey_Status
from orders
LIMIT 20;

-- Query 2: Join orders to customers to get customer's state, alongside delivery status
select order_id , customer_state,
CASE
WHEN order_delivered_customer_date IS NULL 	THEN 'Not Delivered'
WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
ELSE 'On-Time'
END as deliverey_Status
from orders as o
JOIN customers c ON o.customer_id = c.customer_id
LIMIT 20;

-- Query 3: Late & undelivered order counts by customer state
select customer_state,
COUNT(*) AS total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END)as undelivered_orders,
SUM(CASE 
WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1
ELSE 0
END) as late_orders
from orders o 
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY customer_state;


-- Query 4: Late & undelivered rates (%) by customer state — subquery for percentage math

select *, 
(late_orders::NUMERIC / total_orders) * 100 as late_rate_pct,
(undelivered_orders::NUMERIC / total_orders) * 100 as undelivered_rate_pct
from (
    select customer_state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders
    from orders o 
    JOIN customers c ON o.customer_id = c.customer_id
    GROUP BY customer_state
) as state_summary;



-- Query 5: Late & undelivered item counts by product category (raw counts)
select product_category_name,
COUNT(*) as total_items,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders
FROM orders o 
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
GROUP BY product_category_name;


-- Query 6: Late & undelivered item counts by category (English names) — raw counts
select m.product_category_name_english,
COUNT(*) as total_items,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders
FROM orders o 
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
JOIN category_translation m ON p.product_category_name = m.product_category_name
GROUP BY m.product_category_name;


-- Query 7: Late & undelivered rates (%) by product category (English names)
select *,
(late_orders::Numeric/ total_orders)* 100 as late_rate_pct,
(undelivered_orders::NUMERIC/ total_orders)* 100 as undelivered_rate_pct
From (
select m.product_category_name_english,
COUNT(*) as total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders
FROM orders o 
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
JOIN category_translation m ON p.product_category_name = m.product_category_name
GROUP BY m.product_category_name
)as category_summary;

-- Query 8: Late & undelivered rates by category, noise-filtered (500+ orders minimum)
select *,
(late_orders::Numeric/ total_orders)* 100 as late_rate_pct,
(undelivered_orders::NUMERIC/ total_orders)* 100 as undelivered_rate_pct
From (
select m.product_category_name_english,
COUNT(*) as total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders
FROM orders o 
JOIN order_items i ON o.order_id = i.order_id
JOIN products p ON i.product_id = p.product_id
JOIN category_translation m ON p.product_category_name = m.product_category_name
GROUP BY m.product_category_name
HAVING COUNT(*) >= 500
)as category_summary;


-- Query 9: Category late rates, noise-filtered, sorted worst-to-best
select *,
(late_orders::Numeric/ total_orders)* 100 as late_rate_pct,
(undelivered_orders::NUMERIC/ total_orders)* 100 as undelivered_rate_pct
From (
    select m.product_category_name_english,
    COUNT(*) as total_orders,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
    SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders
    FROM orders o 
    JOIN order_items i ON o.order_id = i.order_id
    JOIN products p ON i.product_id = p.product_id
    JOIN category_translation m ON p.product_category_name = m.product_category_name
    GROUP BY m.product_category_name
    HAVING COUNT(*) >= 500
) as category_summary
ORDER BY late_rate_pct DESC;


-- Query 10: State-level totals with average review score alongside late/undelivered counts
select customer_state,
COUNT(*) as total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders,
AVG(review_score) as avg_review_score
FROM orders o 
JOIN customers c ON o.customer_id = c.customer_id
JOIN reviews r ON r.order_id = o.order_id
GROUP BY customer_state;


-- Query 11: State-level late rate, undelivered rate, and avg review score together, sorted worst-to-best
select *,
(late_orders::Numeric/ total_orders)* 100 as late_rate_pct,
(undelivered_orders::NUMERIC/ total_orders)* 100 as undelivered_rate_pct
From (
select customer_state,
COUNT(*) as total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders,
AVG(review_score) as avg_review_score
FROM orders o 
JOIN customers c ON o.customer_id = c.customer_id
JOIN reviews r ON r.order_id = o.order_id
GROUP BY customer_state
)as total_table
ORDER BY late_rate_pct DESC;


-- Query 12: State-level raw counts with avg review score (base version, unwrapped — see Query 11 for the percentage-wrapped version used in the dashboard)
select customer_state,
COUNT(*) as total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders,
AVG(review_score) as avg_review_score
FROM orders o 
JOIN customers c ON o.customer_id = c.customer_id
JOIN reviews r ON r.order_id = o.order_id
GROUP BY customer_state;


-- Query 13: Statistical check — correlation between late delivery (0/1) and review score across all individual orders
SELECT CORR(
    CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END,
    review_score
) as late_review_correlation
FROM orders o
JOIN reviews r ON o.order_id = r.order_id;



-- Rank categories by late-delivery rate within each state, return only the #1 worst category per state
Select *
FROM (
SELECT *,
RANK() OVER ( PARTITION BY customer_state ORDER BY late_rate_pct DESC) as rank_in_state
FROM (
select *,
(late_orders::Numeric/ total_orders)* 100 as late_rate_pct,
(undelivered_orders::NUMERIC/ total_orders)* 100 as undelivered_rate_pct
From (
select p.product_category_name_english, customer_state,
COUNT(*) as total_orders,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) as undelivered_orders,
SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END) as late_orders
FROM order_items o 
JOIN products m ON o.product_id = m.product_id
JOIN orders i ON o.order_id = i.order_id
JOIN customers c ON i.customer_id = c.customer_id
JOIN category_translation p ON m.product_category_name = p.product_category_name
GROUP BY p.product_category_name_english, customer_state, p.product_category_name
Having COUNT(*) >= 500
)as categories_table
ORDER BY late_rate_pct DESC
) as ranked
)as final
where rank_in_state = 1;


-- ============================================================
-- VIEWS: the 4 views below power the Power BI dashboard directly.
-- Run these after the queries above to recreate the dashboard's
-- data layer in a fresh database.
-- ============================================================

-- View 1: Late/undelivered rate by state (Dashboard Visual 1)
CREATE OR REPLACE VIEW vw_late_rate_by_state AS
SELECT customer_state,
    total_orders,
    undelivered_orders,
    late_orders,
    late_orders::numeric / total_orders::numeric * 100::numeric AS late_rate_pct,
    undelivered_orders::numeric / total_orders::numeric * 100::numeric AS undelivered_rate_pct
FROM ( SELECT c.customer_state,
        count(*) AS total_orders,
        sum(
            CASE
                WHEN o.order_delivered_customer_date IS NULL THEN 1
                ELSE 0
            END) AS undelivered_orders,
        sum(
            CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
                ELSE 0
            END) AS late_orders
       FROM orders o
         JOIN customers c ON o.customer_id::text = c.customer_id::text
      GROUP BY c.customer_state) state_summary;


-- View 2: Late/undelivered rate by product category, noise-filtered to categories
-- with 500+ orders (Dashboard Visual 2). Without this filter, tiny-sample
-- categories (e.g. 30-order categories) dominate the ranking with unreliable
-- percentages — this filter matches the same threshold used in Query 8.
CREATE OR REPLACE VIEW vw_late_rate_by_category AS
SELECT product_category_name_english,
    total_orders,
    undelivered_orders,
    late_orders,
    late_orders::numeric / total_orders::numeric * 100::numeric AS late_rate_pct,
    undelivered_orders::numeric / total_orders::numeric * 100::numeric AS undelivered_rate_pct
FROM ( SELECT m.product_category_name_english,
        count(*) AS total_orders,
        sum(
            CASE
                WHEN o.order_delivered_customer_date IS NULL THEN 1
                ELSE 0
            END) AS undelivered_orders,
        sum(
            CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
                ELSE 0
            END) AS late_orders
       FROM orders o
         JOIN order_items i ON o.order_id::text = i.order_id::text
         JOIN products p ON i.product_id::text = p.product_id::text
         JOIN category_translation m ON p.product_category_name::text = m.product_category_name::text
      GROUP BY m.product_category_name
      HAVING count(*) >= 500) category_summary;


-- View 3: Late rate vs. avg review score by state (Dashboard Visual 3)
CREATE OR REPLACE VIEW vw_review_vs_late_by_state AS
SELECT customer_state,
    total_orders,
    undelivered_orders,
    late_orders,
    avg_review_score,
    late_orders::numeric / total_orders::numeric * 100::numeric AS late_rate_pct,
    undelivered_orders::numeric / total_orders::numeric * 100::numeric AS undelivered_rate_pct
FROM ( SELECT c.customer_state,
        count(*) AS total_orders,
        sum(
            CASE
                WHEN o.order_delivered_customer_date IS NULL THEN 1
                ELSE 0
            END) AS undelivered_orders,
        sum(
            CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 1
                ELSE 0
            END) AS late_orders,
        avg(r.review_score) AS avg_review_score
       FROM orders o
         JOIN customers c ON o.customer_id::text = c.customer_id::text
         JOIN reviews r ON r.order_id::text = o.order_id::text
      GROUP BY c.customer_state) total_table
ORDER BY (late_orders::numeric / total_orders::numeric * 100::numeric) DESC;


-- View 4: Worst-performing category per state, high-volume states only (Dashboard Visual 4)
CREATE OR REPLACE VIEW vw_worst_category_by_state AS
SELECT product_category_name_english,
    customer_state,
    total_orders,
    undelivered_orders,
    late_orders,
    late_rate_pct,
    undelivered_rate_pct,
    rank_in_state
FROM ( SELECT ranked.product_category_name_english,
        ranked.customer_state,
        ranked.total_orders,
        ranked.undelivered_orders,
        ranked.late_orders,
        ranked.late_rate_pct,
        ranked.undelivered_rate_pct,
        rank() OVER (PARTITION BY ranked.customer_state ORDER BY ranked.late_rate_pct DESC) AS rank_in_state
       FROM ( SELECT categories_table.product_category_name_english,
                categories_table.customer_state,
                categories_table.total_orders,
                categories_table.undelivered_orders,
                categories_table.late_orders,
                categories_table.late_orders::numeric / categories_table.total_orders::numeric * 100::numeric AS late_rate_pct,
                categories_table.undelivered_orders::numeric / categories_table.total_orders::numeric * 100::numeric AS undelivered_rate_pct
               FROM ( SELECT p.product_category_name_english,
                        c.customer_state,
                        count(*) AS total_orders,
                        sum(
                            CASE
                                WHEN i.order_delivered_customer_date IS NULL THEN 1
                                ELSE 0
                            END) AS undelivered_orders,
                        sum(
                            CASE
                                WHEN i.order_delivered_customer_date > i.order_estimated_delivery_date THEN 1
                                ELSE 0
                            END) AS late_orders
                       FROM order_items o
                         JOIN products m ON o.product_id::text = m.product_id::text
                         JOIN orders i ON o.order_id::text = i.order_id::text
                         JOIN customers c ON i.customer_id::text = c.customer_id::text
                         JOIN category_translation p ON m.product_category_name::text = p.product_category_name::text
                      GROUP BY p.product_category_name_english, c.customer_state, p.product_category_name
                     HAVING count(*) >= 500) categories_table) ranked) final
WHERE rank_in_state = 1;
