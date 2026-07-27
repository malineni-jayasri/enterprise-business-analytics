-- Create clean analytics schema
CREATE SCHEMA IF NOT EXISTS analytics;

--1.Recreate Cleaned customers table
DROP TABLE IF EXISTS analytics.customers;

CREATE TABLE analytics.customers AS
SELECT DISTINCT
    TRIM(c.customer_id) AS customer_id,
    INITCAP(TRIM(c.customer_name)) AS customer_name,
    INITCAP(TRIM(c.customer_type)) AS customer_type,
    TRIM(c.region_id) AS region_id,
    TRIM(c.sales_rep_id) AS sales_rep_id,
    INITCAP(TRIM(c.city)) AS city,

    COALESCE(
        s.state_name,
        INITCAP(TRIM(c.state))
    ) AS state,

    NULLIF(TRIM(c.zip_code), '') AS zip_code,
    c.join_date,
    c.credit_limit,
    INITCAP(TRIM(c.status)) AS status

FROM buildpro.customers_raw c
LEFT JOIN analytics.state_lookup s
ON UPPER(TRIM(c.state)) = s.state_code;

--Raw Data
SELECT *
FROM buildpro.customers_raw
LIMIT 10;

--Validate cleaned data
SELECT *
FROM analytics.customers
LIMIT 10;


--2.Recreate cleaned products table
DROP TABLE IF EXISTS analytics.products;

CREATE TABLE analytics.products AS
SELECT DISTINCT
    TRIM(p.product_id) AS product_id,
    INITCAP(TRIM(p.product_name)) AS product_name,
    TRIM(p.category_id) AS category_id,

    COALESCE(
        NULLIF(INITCAP(TRIM(p.category_name)), ''),
        cl.category_name
    ) AS category_name,

    TRIM(p.supplier_id) AS supplier_id,
    p.standard_cost,
    p.list_price,
    p.weight_lbs,
    INITCAP(TRIM(p.status)) AS status

FROM buildpro.products_raw p
LEFT JOIN analytics.category_lookup cl
    ON TRIM(p.category_id) = cl.category_id;
--Compare row counts
SELECT
    (SELECT COUNT(*) FROM buildpro.products_raw) AS raw_rows,
    (SELECT COUNT(*) FROM analytics.products) AS cleaned_rows;

-- Check duplicate product IDs
SELECT
    product_id,
    COUNT(*) AS record_count
FROM analytics.products
GROUP BY product_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

-- Check missing critical values
SELECT
    COUNT(*) FILTER (
        WHERE product_id IS NULL OR product_id = ''
    ) AS missing_product_id,

    COUNT(*) FILTER (
        WHERE product_name IS NULL OR product_name = ''
    ) AS missing_product_name,

    COUNT(*) FILTER (
        WHERE category_id IS NULL OR category_id = ''
    ) AS missing_category_id,

    COUNT(*) FILTER (
        WHERE supplier_id IS NULL OR supplier_id = ''
    ) AS missing_supplier_id,

    COUNT(*) FILTER (
        WHERE standard_cost IS NULL
    ) AS missing_standard_cost,

    COUNT(*) FILTER (
        WHERE list_price IS NULL
    ) AS missing_list_price
FROM analytics.products;

-- Invalid or suspicious prices
SELECT *
FROM analytics.products
WHERE standard_cost < 0
   OR list_price < 0
   OR list_price < standard_cost;

-- Review product categories
SELECT
    category_id,
    category_name,
    COUNT(*) AS product_count
FROM analytics.products
GROUP BY category_id, category_name
ORDER BY category_id, category_name;

SELECT *
FROM analytics.products
WHERE category_name IS NULL
   OR category_name = ''
   OR category_name = 'Unknown';

--3. CLEAN AND RECREATE ORDERS TABLE

DROP TABLE IF EXISTS analytics.orders;

CREATE TABLE analytics.orders AS
SELECT DISTINCT
    TRIM(order_id) AS order_id,
    TRIM(customer_id) AS customer_id,
    TRIM(sales_rep_id) AS sales_rep_id,
    TRIM(warehouse_id) AS warehouse_id,
    TRIM(region_id) AS region_id,

-- Support multiple date formats because source systems or future data
-- may provide dates in different formats.

    CASE
        WHEN NULLIF(TRIM(order_date_text), '') IS NULL
            THEN NULL
        WHEN TRIM(order_date_text) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN TO_DATE(TRIM(order_date_text), 'YYYY-MM-DD')
        WHEN TRIM(order_date_text) ~ '^\d{2}/\d{2}/\d{4}$'
            THEN TO_DATE(TRIM(order_date_text), 'MM/DD/YYYY')
        WHEN TRIM(order_date_text) ~ '^\d{2}-\d{2}-\d{4}$'
            THEN TO_DATE(TRIM(order_date_text), 'MM-DD-YYYY')
        ELSE NULL
    END AS order_date,

    required_date,

    INITCAP(TRIM(order_status)) AS order_status,
    INITCAP(TRIM(priority)) AS priority,
    INITCAP(TRIM(order_channel)) AS order_channel

FROM buildpro.orders_raw;

--compare row counts
SELECT
    (SELECT COUNT(*) FROM buildpro.orders_raw) AS raw_rows,
    (SELECT COUNT(*) FROM analytics.orders) AS cleaned_rows;

--Check duplicate order ID
SELECT
    order_id,
    COUNT(*) AS record_count
FROM analytics.orders
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

--Check Invalid Order dates
SELECT COUNT(*) AS invalid_order_dates
FROM analytics.orders
WHERE order_date IS NULL;

--Inspecting dates
SELECT DISTINCT order_date_text
FROM buildpro.orders_raw
WHERE NULLIF(TRIM(order_date_text), '') IS NOT NULL
  AND NOT (
      TRIM(order_date_text) ~ '^\d{4}-\d{2}-\d{2}$'
      OR TRIM(order_date_text) ~ '^\d{2}/\d{2}/\d{4}$'
      OR TRIM(order_date_text) ~ '^\d{2}-\d{2}-\d{4}$'
  )
ORDER BY order_date_text;

--Checking status values
SELECT
    order_status,
    COUNT(*) AS order_count
FROM analytics.orders
GROUP BY order_status
ORDER BY order_status;

--Checking priority and channel values
SELECT
    priority,
    order_channel,
    COUNT(*) AS order_count
FROM analytics.orders
GROUP BY priority, order_channel
ORDER BY priority, order_channel;

--Checking the date_format_counts
SELECT
    CASE
        WHEN TRIM(order_date_text) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN 'YYYY-MM-DD'

        WHEN TRIM(order_date_text) ~ '^\d{2}/\d{2}/\d{4}$'
            THEN 'MM/DD/YYYY'

        WHEN TRIM(order_date_text) ~ '^\d{2}-\d{2}-\d{4}$'
            THEN 'MM-DD-YYYY'

        WHEN NULLIF(TRIM(order_date_text), '') IS NULL
            THEN 'Blank'

        ELSE 'Unknown Format'
    END AS date_format,

    COUNT(*) AS row_count

FROM buildpro.orders_raw

GROUP BY
    CASE
        WHEN TRIM(order_date_text) ~ '^\d{4}-\d{2}-\d{2}$'
            THEN 'YYYY-MM-DD'

        WHEN TRIM(order_date_text) ~ '^\d{2}/\d{2}/\d{4}$'
            THEN 'MM/DD/YYYY'

        WHEN TRIM(order_date_text) ~ '^\d{2}-\d{2}-\d{4}$'
            THEN 'MM-DD-YYYY'

        WHEN NULLIF(TRIM(order_date_text), '') IS NULL
            THEN 'Blank'

        ELSE 'Unknown Format'
    END

ORDER BY date_format;

--4.Clean and recreate order items table
DROP TABLE IF EXISTS analytics.order_items;

CREATE TABLE analytics.order_items AS
SELECT DISTINCT
    TRIM(order_item_id) AS order_item_id,
    TRIM(order_id) AS order_id,
    TRIM(product_id) AS product_id,
    quantity,
    unit_price,
    discount_pct,
    line_revenue,
    line_cost
FROM buildpro.order_items_raw;

--validating duplicate line-items
SELECT
    order_item_id,
    COUNT(*) AS record_count
FROM analytics.order_items
GROUP BY order_item_id
HAVING COUNT(*) > 1
ORDER BY record_count DESC;

--Cheking missed or invalid values
SELECT
    COUNT(*) FILTER (
        WHERE order_item_id IS NULL OR order_item_id = ''
    ) AS missing_order_item_id,

    COUNT(*) FILTER (
        WHERE order_id IS NULL OR order_id = ''
    ) AS missing_order_id,

    COUNT(*) FILTER (
        WHERE product_id IS NULL OR product_id = ''
    ) AS missing_product_id,

    COUNT(*) FILTER (
        WHERE quantity IS NULL OR quantity <= 0
    ) AS invalid_quantity,

    COUNT(*) FILTER (
        WHERE unit_price IS NULL OR unit_price < 0
    ) AS invalid_unit_price,

    COUNT(*) FILTER (
        WHERE discount_pct IS NULL
           OR discount_pct < 0
           OR discount_pct > 100
    ) AS invalid_discount,

    COUNT(*) FILTER (
        WHERE line_revenue IS NULL OR line_revenue < 0
    ) AS invalid_line_revenue,

    COUNT(*) FILTER (
        WHERE line_cost IS NULL OR line_cost < 0
    ) AS invalid_line_cost

FROM analytics.order_items;

--Discount values
SELECT
    MIN(discount_pct) AS minimum_discount,
    MAX(discount_pct) AS maximum_discount,
    AVG(discount_pct) AS average_discount
FROM analytics.order_items;

--line revenue
SELECT
    order_item_id,
    quantity,
    unit_price,
    discount_pct,
    line_revenue,

    ROUND(quantity * unit_price * (1 - discount_pct), 2) AS calculated_revenue,

    ROUND(
        line_revenue -
        ROUND(quantity * unit_price * (1 - discount_pct), 2),
        2
    ) AS difference

FROM analytics.order_items
WHERE discount_pct IS NOT NULL
  AND ABS(
        line_revenue -
        ROUND(quantity * unit_price * (1 - discount_pct), 2)
      ) > 0.01
ORDER BY ABS(
        line_revenue -
        ROUND(quantity * unit_price * (1 - discount_pct), 2)
      ) DESC
LIMIT 20;

SELECT
    COUNT(*) AS negative_quantity_rows
FROM analytics.order_items
WHERE quantity < 0;

/*
Business Rules Discovered

1. discount_pct is stored as a decimal
   Example:
   0.15 = 15%

2. Approximately 581 rows have NULL discount_pct.
   These rows still contain valid line_revenue values,
   so the source values are preserved.

3. Approximately 150 rows have negative quantities.
   These represent returns or inventory adjustments.
   The ERP records line_revenue = 0 for these transactions.
   Therefore line_revenue is not recalculated.
*/

--Recreate regions table
DROP TABLE IF EXISTS analytics.region_lookup;

CREATE TABLE analytics.region_lookup AS
SELECT DISTINCT
    TRIM(region_id) AS region_id,
    TRIM(region_name) AS region_name
FROM buildpro.regions
WHERE region_id IS NOT NULL;

--Validating Regions Table
SELECT *
FROM analytics.region_lookup
ORDER BY region_id;

--Recreate Sales Rep Table
DROP TABLE IF EXISTS analytics.sales_rep_lookup;
CREATE TABLE analytics.sales_rep_lookup AS
SELECT DISTINCT

    TRIM(sales_rep_id) AS sales_rep_id,
    TRIM(sales_rep_name) AS sales_rep_name,
    TRIM(region_id) AS region_id,
    hire_date,
    role_level,
    status
FROM buildpro.sales_representatives_raw;

SELECT *
FROM analytics.sales_rep_lookup
LIMIT 10;