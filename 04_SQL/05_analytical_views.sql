--Customer Performance
DROP VIEW IF EXISTS analytics.vw_customer_performance;
CREATE OR REPLACE VIEW analytics.vw_customer_performance AS
SELECT

    c.customer_id,
    c.customer_name,
    c.city,
    c.state,
	c.customer_type,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.quantity) AS units_purchased,

    ROUND(SUM(oi.line_revenue),2) AS total_revenue,

	ROUND
	(
    SUM(oi.line_revenue) /COUNT(DISTINCT o.order_id), 2
    ) AS average_order_value,

    ROUND(SUM(oi.line_cost),2) AS total_cost,

    ROUND(
        SUM(oi.line_revenue)-SUM(oi.line_cost),2
    ) AS gross_profit,

    ROUND(
        (
            SUM(oi.line_revenue)-SUM(oi.line_cost)
        )/
        NULLIF(SUM(oi.line_revenue),0)
        *100,
        2
    ) AS gross_margin_pct,

    ROUND(
        AVG(oi.discount_pct)*100,
        2
    ) AS average_discount_pct

FROM analytics.customers c

JOIN analytics.orders o
ON c.customer_id=o.customer_id

JOIN analytics.order_items oi
ON o.order_id=oi.order_id

WHERE oi.quantity>0

GROUP BY

    c.customer_id,
    c.customer_name,
    c.city,
    c.state,
	c.customer_type;

--Product performance
DROP VIEW IF EXISTS analytics.vw_product_performance;

CREATE VIEW analytics.vw_product_performance AS

SELECT

    p.product_id,
    p.product_name,
    p.category_name,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(SUM(oi.line_revenue),2) AS total_revenue,

    ROUND(
        SUM(oi.line_revenue) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value,

    ROUND(SUM(oi.line_cost),2) AS total_cost,

    ROUND(
        SUM(oi.line_revenue)-SUM(oi.line_cost),
        2
    ) AS gross_profit,

    ROUND(
        (
            SUM(oi.line_revenue)-SUM(oi.line_cost)
        )/
        NULLIF(SUM(oi.line_revenue),0)*100,2
    ) AS gross_margin_pct,

    ROUND(
        AVG(oi.discount_pct)*100,
        2
    ) AS average_discount_pct

FROM analytics.products p

JOIN analytics.order_items oi
ON p.product_id = oi.product_id

WHERE oi.quantity > 0

GROUP BY

    p.product_id,
    p.product_name,
    p.category_name;


--Category Performace
DROP VIEW IF EXISTS analytics.vw_category_performance;

CREATE VIEW analytics.vw_category_performance AS

SELECT

    cl.category_name AS category,

    COUNT(DISTINCT p.product_id) AS total_products,

    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(SUM(oi.line_revenue),2) AS total_revenue,

    ROUND(
        SUM(oi.line_revenue) /
        COUNT(DISTINCT oi.order_id),
        2
    ) AS average_order_value,

    ROUND(SUM(oi.line_cost),2) AS total_cost,

    ROUND(
        SUM(oi.line_revenue)-SUM(oi.line_cost),
        2
    ) AS gross_profit,

    ROUND(
        (
            SUM(oi.line_revenue)-SUM(oi.line_cost)
        ) /
        NULLIF(SUM(oi.line_revenue),0) * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        AVG(oi.discount_pct) * 100,
        2
    ) AS average_discount_pct

FROM analytics.products p

JOIN analytics.category_lookup cl
    ON p.category_id = cl.category_id

JOIN analytics.order_items oi
    ON p.product_id = oi.product_id

WHERE oi.quantity > 0

GROUP BY
    cl.category_name;


--Monthly sales trend
DROP VIEW IF EXISTS analytics.vw_monthly_sales_trend;
CREATE VIEW analytics.vw_monthly_sales_trend AS
SELECT

    DATE_TRUNC('month', o.order_date)::date AS sales_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.quantity) AS units_sold,
    ROUND(SUM(oi.line_revenue),2) AS total_revenue,
    ROUND(SUM(oi.line_cost),2) AS total_cost,
    ROUND(
        SUM(oi.line_revenue)-SUM(oi.line_cost),
        2
    ) AS gross_profit,
	
    ROUND(
        (
            SUM(oi.line_revenue)-SUM(oi.line_cost)
        )/
        NULLIF(SUM(oi.line_revenue),0)*100,
        2
    ) AS gross_margin_pct,
	
    ROUND(
        SUM(oi.line_revenue)/
        NULLIF(SUM(oi.quantity),0),
        2
    ) AS average_selling_price,

    ROUND(
        AVG(oi.discount_pct)*100,
        2
    ) AS average_discount_pct

FROM analytics.orders o

JOIN analytics.order_items oi
ON o.order_id = oi.order_id

WHERE oi.quantity > 0

GROUP BY
    DATE_TRUNC('month', o.order_date)

ORDER BY
    sales_month;

--Monthly Sales growth
DROP VIEW IF EXISTS analytics.vw_monthly_sales_growth;

CREATE VIEW analytics.vw_monthly_sales_growth AS

SELECT
    sales_month,
    total_orders,
    units_sold,
    total_revenue,
    total_cost,
    gross_profit,
    gross_margin_pct,
    average_selling_price,
    average_discount_pct,

    LAG(total_revenue) OVER (
        ORDER BY sales_month
    ) AS previous_month_revenue,

    ROUND(
        (
            total_revenue
            - LAG(total_revenue) OVER (ORDER BY sales_month)
        )
        /
        NULLIF(
            LAG(total_revenue) OVER (ORDER BY sales_month),
            0
        ) * 100,
        2
    ) AS revenue_mom_growth_pct,

    LAG(gross_profit) OVER (
        ORDER BY sales_month
    ) AS previous_month_profit,

    ROUND(
        (
            gross_profit
            - LAG(gross_profit) OVER (ORDER BY sales_month)
        )
        /
        NULLIF(
            LAG(gross_profit) OVER (ORDER BY sales_month),
            0
        ) * 100,
        2
    ) AS profit_mom_growth_pct,

    ROUND(
        SUM(total_revenue) OVER (
            ORDER BY sales_month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS cumulative_revenue

FROM analytics.vw_monthly_sales_trend;



--Regional Performace
DROP VIEW IF EXISTS analytics.vw_region_performance;
CREATE VIEW analytics.vw_region_performance AS
SELECT
    rl.region_id,
    rl.region_name,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(SUM(oi.line_revenue), 2) AS total_revenue,

    ROUND(
        SUM(oi.line_revenue) /
        NULLIF(COUNT(DISTINCT o.order_id), 0),
        2
    ) AS average_order_value,

    ROUND(SUM(oi.line_cost), 2) AS total_cost,

    ROUND(
        SUM(oi.line_revenue) - SUM(oi.line_cost),
        2
    ) AS gross_profit,

    ROUND(
        (
            SUM(oi.line_revenue) - SUM(oi.line_cost)
        ) /
        NULLIF(SUM(oi.line_revenue), 0) * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        AVG(oi.discount_pct) * 100,
        2
    ) AS average_discount_pct

FROM analytics.orders o

JOIN analytics.order_items oi
    ON o.order_id = oi.order_id

JOIN analytics.region_lookup rl
    ON o.region_id = rl.region_id

WHERE oi.quantity > 0

GROUP BY
    rl.region_id,
    rl.region_name;

--Sales representative performace
DROP VIEW IF EXISTS analytics.vw_sales_rep_performance;
CREATE VIEW analytics.vw_sales_rep_performance AS
SELECT

    sr.sales_rep_id,
    sr.sales_rep_name,
    sr.role_level,
    sr.status,
	sr.region_id,

    COUNT(DISTINCT o.order_id) AS total_orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(SUM(oi.line_revenue),2) AS total_revenue,

    ROUND(
        SUM(oi.line_revenue) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS average_order_value,

    ROUND(SUM(oi.line_cost),2) AS total_cost,

    ROUND(
        SUM(oi.line_revenue)-SUM(oi.line_cost),
        2
    ) AS gross_profit,

    ROUND(
        (
            SUM(oi.line_revenue)-SUM(oi.line_cost)
        )/
        NULLIF(SUM(oi.line_revenue),0)*100,
        2
    ) AS gross_margin_pct,

    ROUND(
        AVG(oi.discount_pct)*100,
        2
    ) AS average_discount_pct

FROM analytics.orders o

JOIN analytics.order_items oi
ON o.order_id = oi.order_id

JOIN analytics.sales_rep_lookup sr
ON o.sales_rep_id = sr.sales_rep_id

WHERE oi.quantity > 0

GROUP BY

    sr.sales_rep_id,
    sr.sales_rep_name,
    sr.role_level,
	sr.region_id,
    sr.status;

/*--RETURN AND ADJUSTMENT ANALYSIS--*/

--Return details
DROP VIEW IF EXISTS analytics.vw_returns_detail;
CREATE VIEW analytics.vw_returns_detail AS
SELECT
    o.order_id,
    o.order_date,

    o.customer_id,
    c.customer_name,

    o.sales_rep_id,
    sr.sales_rep_name,

    o.region_id,
    r.region_name,

    oi.product_id,
    p.product_name,

    p.category_id,
    cat.category_name,

    oi.quantity AS return_quantity,
    ABS(oi.quantity) AS units_returned,

    oi.line_revenue,
    oi.line_cost,
    oi.discount_pct

FROM analytics.orders o

JOIN analytics.order_items oi
    ON o.order_id = oi.order_id

JOIN analytics.customers c
    ON o.customer_id = c.customer_id

JOIN analytics.products p
    ON oi.product_id = p.product_id

LEFT JOIN analytics.sales_rep_lookup sr
    ON o.sales_rep_id = sr.sales_rep_id

LEFT JOIN analytics.region_lookup r
    ON o.region_id = r.region_id

LEFT JOIN analytics.category_lookup cat
    ON p.category_id = cat.category_id

WHERE oi.quantity < 0;

--Return analysis
DROP VIEW IF EXISTS analytics.vw_return_analysis;

CREATE VIEW analytics.vw_return_analysis AS
SELECT
    product_id,
    product_name,
    category_id,
    category_name,

    COUNT(*) AS return_line_items,
    COUNT(DISTINCT order_id) AS return_orders,
    SUM(units_returned) AS total_units_returned,

    ROUND(AVG(discount_pct) * 100, 2)
        AS average_discount_pct

FROM analytics.vw_returns_detail

GROUP BY
    product_id,
    product_name,
    category_id,
    category_name;