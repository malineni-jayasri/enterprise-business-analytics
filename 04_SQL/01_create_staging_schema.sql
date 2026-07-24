CREATE SCHEMA IF NOT EXISTS buildpro;

-- Load master tables first.
CREATE TABLE buildpro.regions (
    region_id VARCHAR(10) PRIMARY KEY,
    region_name VARCHAR(50)
);

CREATE TABLE buildpro.suppliers_raw (
    supplier_id VARCHAR(10),
    supplier_name VARCHAR(150),
    region_id VARCHAR(10),
    lead_time_days INTEGER,
    supplier_rating NUMERIC(3,1),
    status VARCHAR(20)
);

CREATE TABLE buildpro.warehouses_raw (
    warehouse_id VARCHAR(10),
    warehouse_name VARCHAR(150),
    region_id VARCHAR(10),
    city VARCHAR(80),
    state VARCHAR(30),
    capacity_units INTEGER,
    employee_count INTEGER,
    status VARCHAR(20)
);

CREATE TABLE buildpro.sales_representatives_raw (
    sales_rep_id VARCHAR(10),
    sales_rep_name VARCHAR(100),
    region_id VARCHAR(10),
    hire_date DATE,
    role_level VARCHAR(50),
    status VARCHAR(20)
);

CREATE TABLE buildpro.customers_raw (
    customer_id VARCHAR(20),
    customer_name VARCHAR(150),
    customer_type VARCHAR(30),
    region_id VARCHAR(10),
    sales_rep_id VARCHAR(10),
    city VARCHAR(80),
    state VARCHAR(30),
    zip_code VARCHAR(15),
    join_date DATE,
    credit_limit NUMERIC(14,2),
    status VARCHAR(20)
);

CREATE TABLE buildpro.products_raw (
    product_id VARCHAR(20),
    product_name VARCHAR(180),
    category_id VARCHAR(10),
    category_name VARCHAR(80),
    supplier_id VARCHAR(10),
    standard_cost NUMERIC(14,2),
    list_price NUMERIC(14,2),
    weight_lbs NUMERIC(14,2),
    status VARCHAR(20)
);

-- Dates are text in raw staging where mixed formats were intentionally inserted.
CREATE TABLE buildpro.orders_raw (
    order_id VARCHAR(20),
    customer_id VARCHAR(20),
    sales_rep_id VARCHAR(10),
    warehouse_id VARCHAR(10),
    region_id VARCHAR(10),
    order_date_text VARCHAR(20),
    required_date DATE,
    order_status VARCHAR(20),
    priority VARCHAR(20),
    order_channel VARCHAR(30)
);

CREATE TABLE buildpro.order_items_raw (
    order_item_id VARCHAR(20),
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    quantity INTEGER,
    unit_price NUMERIC(14,2),
    discount_pct NUMERIC(8,4),
    line_revenue NUMERIC(16,2),
    line_cost NUMERIC(16,2)
);

CREATE TABLE buildpro.freight_raw (
    freight_id VARCHAR(20),
    order_id VARCHAR(20),
    carrier VARCHAR(80),
    freight_cost NUMERIC(16,2),
    delivery_days INTEGER,
    region_id VARCHAR(10),
    warehouse_id VARCHAR(10)
);

CREATE TABLE buildpro.shipments_raw (
    shipment_id VARCHAR(20),
    order_id VARCHAR(20),
    ship_date DATE,
    actual_delivery_date DATE,
    required_delivery_date DATE,
    on_time_flag VARCHAR(5),
    carrier VARCHAR(80),
    warehouse_id VARCHAR(10)
);

CREATE TABLE buildpro.payments_raw (
    payment_id VARCHAR(20),
    order_id VARCHAR(20),
    payment_date_text VARCHAR(20),
    payment_method VARCHAR(30),
    amount_paid NUMERIC(16,2),
    outstanding_balance NUMERIC(16,2),
    payment_status VARCHAR(20)
);

CREATE TABLE buildpro.returns_raw (
    return_id VARCHAR(20),
    order_id VARCHAR(20),
    product_id VARCHAR(20),
    return_date DATE,
    return_qty INTEGER,
    return_reason VARCHAR(80),
    disposition VARCHAR(30),
    return_value NUMERIC(16,2)
);

CREATE TABLE buildpro.inventory_raw (
    inventory_id VARCHAR(20),
    warehouse_id VARCHAR(10),
    product_id VARCHAR(20),
    snapshot_date DATE,
    quantity_available INTEGER,
    reorder_point INTEGER,
    safety_stock INTEGER,
    stock_status VARCHAR(20)
);

CREATE TABLE buildpro.pricing_history_raw (
    price_history_id VARCHAR(20),
    product_id VARCHAR(20),
    effective_date DATE,
    standard_cost NUMERIC(14,2),
    list_price NUMERIC(14,2),
    change_reason VARCHAR(50)
);
