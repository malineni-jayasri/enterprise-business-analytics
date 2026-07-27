/*--CUSTOMER ANALYSIS--*/

-- Top 10 Customers by Revenue
SELECT
    customer_name,
    total_orders,
    total_revenue,
    gross_profit,
    gross_margin_pct,
    average_order_value
FROM analytics.vw_customer_performance
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Most Profitable Customers
SELECT
    customer_name,
    total_revenue,
    gross_profit,
    gross_margin_pct
FROM analytics.vw_customer_performance
ORDER BY gross_profit DESC
LIMIT 10;

-- Customers Receiving the Highest Average Discounts
SELECT
    customer_name,
    total_revenue,
    average_discount_pct
FROM analytics.vw_customer_performance
ORDER BY average_discount_pct DESC
LIMIT 10;

/*--PRODUCT ANALYSIS--*/

-- Top 10 Products by Revenue
SELECT
    product_name,
    category_name,
    total_revenue,
    gross_profit,
    gross_margin_pct
FROM analytics.vw_product_performance
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Most Profitable Products
SELECT
    product_name,
    category_name,
    gross_profit,
    gross_margin_pct
FROM analytics.vw_product_performance
ORDER BY gross_profit DESC
LIMIT 10;

/*--CATEGORY ANALYSIS--*/

-- Category Performance
SELECT
    category,
    total_revenue,
    gross_profit,
    gross_margin_pct,
    average_discount_pct
FROM analytics.vw_category_performance
ORDER BY total_revenue DESC;

/*--TIME ANALYSIS--*/

-- Monthly Sales Trend
SELECT
    sales_month,
    total_orders,
    total_revenue,
    gross_profit,
    gross_margin_pct
FROM analytics.vw_monthly_sales_trend
ORDER BY sales_month;

-- Month-over-Month Revenue Growth
SELECT
    sales_month,
    total_revenue,
    revenue_mom_growth_pct,
    cumulative_revenue
FROM analytics.vw_monthly_sales_growth
ORDER BY sales_month;

/*--REGIONAL ANALYSIS--*/

-- Regional Performance
SELECT
    region_name,
    total_orders,
    total_revenue,
    gross_profit,
    gross_margin_pct,
    average_order_value
FROM analytics.vw_region_performance
ORDER BY total_revenue DESC;

/*--SALES REPRESENTATIVE ANALYSIS--*/

-- Top 10 Sales Representatives by Revenue
SELECT
    sales_rep_name,
	role_level,
    total_orders,
    total_revenue,
    gross_profit,
    gross_margin_pct
FROM analytics.vw_sales_rep_performance
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 10 Sales Representatives by Profit
SELECT
    sales_rep_name,
    role_level,
    gross_profit,
    gross_margin_pct
FROM analytics.vw_sales_rep_performance
ORDER BY gross_profit DESC
LIMIT 10;

/*--RETURN AND ADJUSTMENT ANALYSIS*/

-- Products with the Highest Returned Units
SELECT
    product_name,
    category_name,
    return_orders,
    total_units_returned,
    average_discount_pct
FROM analytics.vw_return_analysis
ORDER BY total_units_returned DESC;

-- Customers with the Highest Returned Units
SELECT
    customer_name,
    COUNT(DISTINCT order_id) AS return_orders,
    SUM(units_returned) AS total_units_returned
FROM analytics.vw_returns_detail
GROUP BY customer_name
ORDER BY total_units_returned DESC
LIMIT 10;

-- Regions with the Highest Returned Units

SELECT
    region_name,
    COUNT(DISTINCT order_id) AS return_orders,
    SUM(units_returned) AS total_units_returned
FROM analytics.vw_returns_detail
GROUP BY region_name
ORDER BY total_units_returned DESC;

-- Sales Representatives Associated with the Most Returns
SELECT
    sales_rep_name,
    COUNT(DISTINCT order_id) AS return_orders,
    SUM(units_returned) AS total_units_returned
FROM analytics.vw_returns_detail
GROUP BY sales_rep_name
ORDER BY total_units_returned DESC
LIMIT 10;

SELECT
    SUM(units_returned) AS total_units_returned
FROM analytics.vw_returns_detail;