/*--COMPANY KPI VALIDATION--*/

-- Compare cleaned transaction data with the KPI view
SELECT
    COUNT(DISTINCT o.order_id) AS expected_total_orders,
    SUM(oi.quantity) AS expected_units_sold,
    ROUND(SUM(oi.line_revenue), 2) AS expected_total_revenue,
    ROUND(SUM(oi.line_cost), 2) AS expected_total_cost,
    ROUND(SUM(oi.line_revenue - oi.line_cost), 2)
        AS expected_gross_profit
FROM analytics.orders o
JOIN analytics.order_items oi
    ON o.order_id = oi.order_id
WHERE oi.quantity > 0;

-- Review the KPI view
SELECT *
FROM analytics.vw_business_kpis;

/*PROFIT EQUATION VALIDATION*/

SELECT
    total_revenue,
    total_cost,
    gross_profit,
    ROUND(total_revenue - total_cost, 2)
        AS calculated_gross_profit,
    ROUND(
        gross_profit - (total_revenue - total_cost),
        2
    ) AS difference
FROM analytics.vw_business_kpis;

/*REGIONAL TOTAL VALIDATION*/

SELECT
    ROUND(SUM(total_revenue), 2) AS regional_revenue,
    ROUND(SUM(total_cost), 2) AS regional_cost,
    ROUND(SUM(gross_profit), 2) AS regional_profit
FROM analytics.vw_region_performance;

--Comparing with business KPI
SELECT
    total_revenue,
    total_cost,
    gross_profit
FROM analytics.vw_business_kpis;

/*CATEGORY TOTAL VALIDATION*/

SELECT
    ROUND(SUM(total_revenue), 2) AS category_revenue,
    ROUND(SUM(total_cost), 2) AS category_cost,
    ROUND(SUM(gross_profit), 2) AS category_profit
FROM analytics.vw_category_performance;

/*MONTHLY TOTAL VALIDATION*/

SELECT
    ROUND(SUM(total_revenue), 2) AS monthly_revenue,
    ROUND(SUM(total_cost), 2) AS monthly_cost,
    ROUND(SUM(gross_profit), 2) AS monthly_profit
FROM analytics.vw_monthly_sales_trend;

/*RETURN VALIDATION*/

-- Negative rows in the cleaned table
SELECT
    COUNT(*) AS source_return_records,
    SUM(ABS(quantity)) AS source_units_returned
FROM analytics.order_items
WHERE quantity < 0;
-- Return rows exposed through the analytical view
SELECT
    COUNT(*) AS view_return_records,
    SUM(units_returned) AS view_units_returned
FROM analytics.vw_returns_detail;

/*DIMENSION MAPPING VALIDATION*/

-- Orders without a valid customer

SELECT COUNT(*) AS missing_customer_mappings
FROM analytics.orders o
LEFT JOIN analytics.customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items without a valid product

SELECT COUNT(*) AS missing_product_mappings
FROM analytics.order_items oi
LEFT JOIN analytics.products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- Orders without a valid region

SELECT COUNT(*) AS missing_region_mappings
FROM analytics.orders o
LEFT JOIN analytics.region_lookup r
    ON o.region_id = r.region_id
WHERE r.region_id IS NULL;


-- Orders without a valid sales representative

SELECT COUNT(*) AS missing_sales_rep_mappings
FROM analytics.orders o
LEFT JOIN analytics.sales_rep_lookup sr
    ON o.sales_rep_id = sr.sales_rep_id
WHERE sr.sales_rep_id IS NULL;

/*DUPLICATE IDENTIFIER CHECKS*/
--Duplicate Order check
SELECT
    order_id,
    COUNT(*) AS duplicate_count
FROM analytics.orders
GROUP BY order_id
HAVING COUNT(*) > 1;

--Duplicate customer check
SELECT
    customer_id,
    COUNT(*) AS duplicate_count
FROM analytics.customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

--Duplicate product check
SELECT
    product_id,
    COUNT(*) AS duplicate_count
FROM analytics.products
GROUP BY product_id
HAVING COUNT(*) > 1;