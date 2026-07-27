--Business KPI's
-- Source: cleaned analytics tables
-- Database: buildpro_erp
CREATE OR REPLACE VIEW analytics.vw_business_kpis AS
SELECT
    COUNT(DISTINCT oi.order_id) AS total_orders,

    SUM(oi.quantity) AS units_sold,

    ROUND(
        SUM(oi.line_revenue),
        2
    ) AS total_revenue,

    ROUND(
        SUM(oi.line_cost),
        2
    ) AS total_cost,

    ROUND(
        SUM(oi.line_revenue) - SUM(oi.line_cost),
        2
    ) AS gross_profit,

    ROUND(
        (
            SUM(oi.line_revenue) - SUM(oi.line_cost)
        )
        / NULLIF(SUM(oi.line_revenue), 0)
        * 100,
        2
    ) AS gross_margin_pct,

    ROUND(
        SUM(oi.line_revenue)
        / NULLIF(SUM(oi.quantity), 0),
        2
    ) AS average_selling_price,

    ROUND(
        AVG(oi.discount_pct) * 100,
        2
    ) AS average_discount_pct

FROM analytics.order_items oi
WHERE oi.quantity > 0;

SELECT *
FROM analytics.vw_business_kpis;

