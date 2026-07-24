--Checking the Data 
SELECT 'customers_raw' AS table_name, COUNT(*) AS row_count
FROM buildpro.customers_raw

UNION ALL

SELECT 'products_raw', COUNT(*)
FROM buildpro.products_raw

UNION ALL

SELECT 'orders_raw', COUNT(*)
FROM buildpro.orders_raw

UNION ALL

SELECT 'order_items_raw', COUNT(*)
FROM buildpro.order_items_raw

UNION ALL

SELECT 'freight_raw', COUNT(*)
FROM buildpro.freight_raw

UNION ALL

SELECT 'payments_raw', COUNT(*)
FROM buildpro.payments_raw

UNION ALL

SELECT 'returns_raw', COUNT(*)
FROM buildpro.returns_raw

UNION ALL

SELECT 'inventory_raw', COUNT(*)
FROM buildpro.inventory_raw

UNION ALL

SELECT 'pricing_history_raw', COUNT(*)
FROM buildpro.pricing_history_raw

UNION ALL

SELECT 'regions', COUNT(*)
FROM buildpro.regions

UNION ALL

SELECT 'sales_representatives_raw', COUNT(*)
FROM buildpro.sales_representatives_raw

UNION ALL

SELECT 'shipments_raw', COUNT(*)
FROM buildpro.shipments_raw

UNION ALL

SELECT 'suppliers_raw', COUNT(*)
FROM buildpro.suppliers_raw

UNION ALL

SELECT 'warehouses_raw', COUNT(*)
FROM buildpro.warehouses_raw

ORDER BY table_name;

--Finding Duplicate customers
SELECT
    customer_name,
    COUNT(*) AS duplicate_count
FROM buildpro.customers_raw
GROUP BY customer_name
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

--Finding missing ZIP Codes
SELECT *
FROM buildpro.customers_raw
WHERE zip_code IS NULL
   OR zip_code = '';

--Finding inconsistent state names
SELECT DISTINCT state
FROM buildpro.customers_raw
ORDER BY state;

--Checking For Negative Quantities
SELECT *
FROM buildpro.order_items_raw
WHERE quantity < 0;

--Checking missing discounts
SELECT COUNT(*)
FROM buildpro.order_items_raw
WHERE discount_pct IS NULL;

--Checking missing product categories
SELECT COUNT(*)
FROM buildpro.products_raw
WHERE category_name IS NULL OR category_name='';

